//
//  RoundedBlackView.m
//  PurplePatch
//
//  Created by Linh NGUYEN on 7/4/11.
//  Copyright 2011 Hirevietnamese Ltd. All rights reserved.
//
#import "RoundedBlackView.h"
@implementation RoundedBlackView
- (id)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
	CGRect rectBox = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();	
	rectBox = CGRectInset(rectBox, 2.0f, 2.0f);
	float radius = 7.0f;
    CGContextBeginPath(context);
	CGContextSetRGBFillColor(context,0x00/255.0,0x00/255.0,0x00/255.0, 1) ;
	CGContextMoveToPoint(context, CGRectGetMinX(rectBox) + radius, CGRectGetMinY(rectBox));
    CGContextAddArc(context, CGRectGetMaxX(rectBox) - radius, CGRectGetMinY(rectBox) + radius, radius, 3 * M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(rectBox) - radius, CGRectGetMaxY(rectBox) - radius, radius, 0, M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(rectBox) + radius, CGRectGetMaxY(rectBox) - radius, radius, M_PI / 2, M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(rectBox) + radius, CGRectGetMinY(rectBox) + radius, radius, M_PI, 3 * M_PI / 2, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

@end