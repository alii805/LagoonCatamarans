//
//  ActivityIndicator.h
//  PurplePatch
//
//  Created by Linh NGUYEN on 7/4/11.
//  Copyright 2011 Hirevietnamese Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundedBlackView.h"
@interface ActivityIndicator : UIView {
	UIActivityIndicatorView *indView;
	UILabel *label;
	RoundedBlackView *bgView;
	BOOL isShowedBOOL;
}
@property(nonatomic) BOOL isShowedBOOL;

- (id) init;
- (void) show;
- (void) showWithLabel: (NSString *)labelStr;
- (void) hide;
+ (void) show;
+ (void) showWithLabel: (NSString *)labelStr;
+ (void) hide;
+ (id) sharedInstance;
@end