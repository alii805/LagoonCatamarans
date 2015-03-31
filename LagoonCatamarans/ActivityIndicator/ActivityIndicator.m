//
//  ActivityIndicator.m
//  PurplePatch
//
//  Created by Linh NGUYEN on 7/4/11.
//  Copyright 2011 Hirevietnamese Ltd. All rights reserved.
//


#import "ActivityIndicator.h"
#import "RoundedBlackView.h"

#define TIME_OUT_ACTIVITYINDICATOR 30

static ActivityIndicator *sharedView = nil;
@interface ActivityIndicator (Private)
- (void) initView;
- (void) doLayout;
@end
@implementation ActivityIndicator (Private)
- (void) initView {
	self.backgroundColor = [UIColor clearColor];
	bgView = [[RoundedBlackView alloc] initWithFrame:CGRectZero];
	bgView.alpha = 0.8f;
	bgView.backgroundColor = [UIColor clearColor];
	[self addSubview:bgView];
	indView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[self addSubview:indView];
	label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.backgroundColor = [UIColor clearColor];
	label.text = @"";
	[self addSubview:label];
	label.textColor = [UIColor lightGrayColor];
	label.textAlignment = NSTextAlignmentCenter;
}
- (void) doLayout {
	[bgView setNeedsDisplay];
	UIWindow* window = [UIApplication sharedApplication].keyWindow;
	if (!window) {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
	BOOL isLineMustWrap = NO;
	label.textAlignment =  NSTextAlignmentLeft;
	label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	NSArray *tmpCharArray = [label.text componentsSeparatedByString:@" "];				
	NSString *tmpStr = [[NSString alloc] init];
	tmpStr = [tmpCharArray objectAtIndex:([tmpCharArray count] - 1)];
	CGSize tmpLabelSize = [tmpStr sizeWithFont:label.font forWidth:(window.frame.size.width-60.0f) lineBreakMode:NSLineBreakByWordWrapping];
	NSRange textRange = [label.text rangeOfString:tmpStr];
	BOOL isSpaceTrimming = NO;
	if (textRange.location != NSNotFound)
	{
		NSString *tmp = [label.text substringToIndex:textRange.location];
		CGSize tmpLabelSize1 = [tmp sizeWithFont:label.font forWidth:(window.frame.size.width-60.0f) lineBreakMode:NSLineBreakByWordWrapping];
		float preText = tmpLabelSize1.width;
		float nxtText = tmpLabelSize.width;
		float disText = (window.frame.size.width-60.0f) - preText;
		if ((nxtText - 10.0f) <= disText)
		{
			isSpaceTrimming = YES;
		}		
	}	
	CGSize labelSize = [label.text sizeWithFont:label.font forWidth:(window.frame.size.width-20.0f) lineBreakMode:NSLineBreakByWordWrapping];
	//CGSize indSize = indView.frame.size;
	if (labelSize.width > 180)
	{		
		isLineMustWrap = YES;
		label.numberOfLines = 2;
		label.lineBreakMode = NSLineBreakByWordWrapping;
	}	
	CGRect bgFrame = bgView.frame;	
	bgFrame.size.width = 60.0f;//labelSize.width + indSize.width + 60.0f;
	if (isLineMustWrap)
	{
		bgFrame.size.height = 60.0f;
		if (isSpaceTrimming)
			bgFrame.size.width = 60.0f;//labelSize.width + indSize.width - 30.0f;
	}
	else
	{
		bgFrame.size.height = 60.0f;
	}
	bgView.frame = bgFrame;
	bgView.center = self.center;
	CGRect indFrame = indView.frame;
	if (isLineMustWrap)
	{
		indFrame.origin.x = bgView.frame.origin.x + bgView.frame.size.width/3;
		indFrame.origin.y = bgView.frame.origin.y + bgView.frame.size.height/3;		
	}
	else
	{
		indFrame.origin.x = bgView.frame.origin.x + bgView.frame.size.width/3;
		indFrame.origin.y = bgView.frame.origin.y + bgView.frame.size.height/3;
	}
	indView.frame = indFrame;
	CGRect labelFrame = label.frame;
	if (isLineMustWrap)
	{
		labelFrame.origin.x = indFrame.origin.x + indFrame.size.width + 5.0f;
		labelFrame.origin.y = indFrame.origin.y;
		labelFrame.size.width = labelSize.width - 20.0f;
		labelFrame.size.height = labelSize.height + 22.0f;
	}
	else
	{
		labelFrame.origin.x = indFrame.origin.x + indFrame.size.width + 5.0f;
		labelFrame.origin.y = indFrame.origin.y;
		labelFrame.size = labelSize;
	}
	label.frame = labelFrame;	
}
@end
@implementation ActivityIndicator
@synthesize isShowedBOOL;
- (id) init {
	indView = nil;
	UIWindow* window = [UIApplication sharedApplication].keyWindow;
	if (!window) {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
	CGRect frame =  window.frame;
	if (self == [super initWithFrame:frame]) {
		[self initView];
	}	
	return self;
}

- (void) countdownTime{
    if (!sharedView) {
        sharedView = [[ActivityIndicator alloc] init];
    }	
    [sharedView hide];
}


- (void) show {	
	isShowedBOOL = YES;
	if ([self superview]) {
		[self removeFromSuperview];
	} 	
	//label.text = @"Loading";
	[self doLayout];
	UIWindow* window = [UIApplication sharedApplication].keyWindow;
	if (!window) {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
	[window addSubview:self];
    
//    [NSTimer scheduledTimerWithTimeInterval:TIME_OUT_ACTIVITYINDICATOR
//                                     target:self
//                                   selector:@selector(countdownTime)
//                                   userInfo:nil
//                                    repeats:NO];

}
- (void) showWithLabel: (NSString *)labelStr {	
	isShowedBOOL = YES;
	if ([self superview]) {
		[self removeFromSuperview];
	} 
	label.text = labelStr;
	[self doLayout];
	UIWindow* window = [UIApplication sharedApplication].keyWindow;
	if (!window) {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
	[window addSubview:self];
}
- (void) hide {
	isShowedBOOL = NO;
	if ([self superview]) {
		[self removeFromSuperview];
	}	
}
- (id) initWithFrame:(CGRect)frame {
	indView = nil;
	if (self == [super initWithFrame:frame]) {
		[self initView];
	}	
	return self;
}
- (id) initWithCoder:(NSCoder *)decoder {
	indView = nil;
	if (self == [super initWithCoder:decoder]) {
		[self initView];
	}
	return self;
}
- (void) didMoveToSuperview {
	if (self.superview != nil) {
		[indView startAnimating];
	} else {
		[indView stopAnimating];
	}
}
- (void)drawRect:(CGRect)rect {
}

#pragma mark class method
+ (void) show {
	if (!sharedView) {
		sharedView = [[ActivityIndicator alloc] init];
	}
	[sharedView show];
}
+ (void) showWithLabel: (NSString *)labelStr {
	if (!sharedView) {
		sharedView = [[ActivityIndicator alloc] init];
	}	
	[sharedView showWithLabel:labelStr];
}
+ (void) hide {
	if (!sharedView) {
		sharedView = [[ActivityIndicator alloc] init];
	}	
	[sharedView hide];	
}
+ (id) sharedInstance {
	if (!sharedView) {
		sharedView = [[ActivityIndicator alloc] init];
	}
	return sharedView;
}
@end