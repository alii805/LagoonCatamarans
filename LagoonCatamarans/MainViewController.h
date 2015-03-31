//
//  MainViewController.h
//  LagoonCatamarans
//
//  Created by apple on 1/22/15.
//  Copyright (c) 2015 LC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface MainViewController : UIViewController

@property(strong) Reachability * googleReach;
@property(strong) Reachability * localWiFiReach;
@property(strong) Reachability * internetConnectionReach;

@property (assign) BOOL cellularOn;
@property (assign) BOOL wifiOn;
@property (assign) BOOL interNetOn;

@end
