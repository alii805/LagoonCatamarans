//
//  MainViewController.m
//  LagoonCatamarans
//
//  Created by apple on 1/22/15.
//  Copyright (c) 2015 LC. All rights reserved.
//

#import "Reachability.h"
#import "EventAPICall.h"
#import "ActivityIndicator.h"
#import "MainViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CommonCrypto/CommonDigest.h>

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


@interface MainViewController () <CLLocationManagerDelegate,UITextFieldDelegate,NSURLConnectionDataDelegate>{
    BOOL autRetry;
    float latitude;
    float longitude;
    NSMutableArray *queuedData;
    BOOL goneForAutoRefresh;
}

@property (weak, nonatomic) IBOutlet UILabel *lblLocationCoordinates;
@property (weak, nonatomic) IBOutlet UITextField *txtFPlacename;
@property (weak, nonatomic) IBOutlet UITextField *txtFText;
@property (weak, nonatomic) IBOutlet UILabel *lblQueuedInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckbox;

@property (strong, nonatomic) CLLocationManager *locationManager;
@end


@implementation MainViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNetwork];
    goneForAutoRefresh = NO;
    
    _txtFPlacename.delegate = self;
    _txtFText.delegate= self;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isSettingSaved"]) {
        autRetry = [[NSUserDefaults standardUserDefaults] boolForKey:@"autoRetry"];
        queuedData = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"queue"]];
        if (autRetry) {
            _btnCheckbox.selected = YES;
        }
        else {
            
            _btnCheckbox.selected = NO;
            
        }
        
        [self updateLable];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isSettingSaved"];
        autRetry = NO;
        [[NSUserDefaults standardUserDefaults] setBool:autRetry forKey:@"autoRetry"];
        queuedData = [[NSMutableArray alloc] init];
        [[NSUserDefaults standardUserDefaults] setObject:queuedData forKey:@"queue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self startSearchingLocation];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    singleTap.numberOfTapsRequired = 1;
    
    [self.view addGestureRecognizer:singleTap];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)tapDetected:(UIGestureRecognizer *) sender
{
    UIGestureRecognizer *recognizer = (UIGestureRecognizer*)sender;
    if (![recognizer.view isKindOfClass:[UITextField class]]) {
        
        [_txtFText resignFirstResponder];
        [_txtFPlacename resignFirstResponder];
        
    }
}


#pragma mark UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}


#pragma mark - Actions
- (void)updateLable {
    
    _lblQueuedInfo.text = [NSString stringWithFormat:@"You currently have %i position queued, waiting for network access. These can be uploaded when you connected to network.",(int)[queuedData count]];
}

- (IBAction)btnAction:(id)sender {
    

    if ([sender tag] == 1) {
        // sign out
    }
    else if ([sender tag] == 2) {
        // upload
        [self makeAPIDictionary];
    }
    else if ([sender tag] == 3) {
        // retry
        if (queuedData.count) {
            [self callApi];
        }
        else
            [[[UIAlertView alloc] initWithTitle:@"ALert!" message:@"You don't have any update loaction on queue to send to server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else if ([sender tag] == 4) {
        // check box
        _btnCheckbox.selected = !_btnCheckbox.selected;
        autRetry = _btnCheckbox.selected;
        [[NSUserDefaults standardUserDefaults] setBool:autRetry forKey:@"autoRetry"];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
}

#pragma mark -

- (void)startSearchingLocation
{
    //locationManager is ivar of CLLocationManager
    self.locationManager = [[CLLocationManager alloc] init];
    //release it when you stop the location manager!
    
    // make self the delegate of the location manager
    [self.locationManager setDelegate:self];
    
    //Note that this settings will have a huge impact on battery life!
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    //And finally start the location manager.
    
    if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    
    
    if (IS_OS_8_OR_LATER) {
        //
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    _lblLocationCoordinates.text = [NSString stringWithFormat:@"%f   %f",newLocation.coordinate.latitude,newLocation.coordinate.longitude];
    latitude = newLocation.coordinate.latitude;
    longitude = newLocation.coordinate.longitude;
    
}

//update location
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    _lblLocationCoordinates.text = [NSString stringWithFormat:@"%f   %f",newLocation.coordinate.latitude,newLocation.coordinate.longitude];
    
//    NSLog(@"Location: %f, %f", newLocation.coordinates.longtitude, newLocation.coordinates.latitude);
}

#pragma mark - API

- (void) makeAPIDictionary {
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *dateStr = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *timeStr = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"ZZZ"];
    NSString *timeZone = [dateFormatter stringFromDate:date];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",latitude], @"latitude", [NSString stringWithFormat:@"%f",longitude],@"longitude", _txtFPlacename.text, @"placename", dateStr, @"date", timeStr, @"time", timeZone, @"timezone", _txtFText.text, @"note", [self sha1:timeStr], @"secretcode", nil];
    
    [queuedData addObject:dic];
    [[NSUserDefaults standardUserDefaults] setObject:queuedData forKey:@"queue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateLable];
    [self callApi];
    
}

- (NSString *)sha1 : (NSString*)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

// uploading with NSURLConnection
/*
- (void) callApiOtherWay {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"ios2",@"app", nil];
    
    
    for (int i = 0; i < [queuedData count]; i++) {
        [dic setObject:[queuedData objectAtIndex:i] forKey:[NSString stringWithFormat:@"%i",i+1]];
    }
    
    
    
    NSURL *url = [NSURL URLWithString:@"http://lagooncatamarans.org/mylocations_upload.php"];
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

    [request setHTTPBody:postdata];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [postdata length]] forHTTPHeaderField:@"Content-Length"];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data
                          
                          options:kNilOptions
                          error:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error: %@",error.description);
}
*/

- (void) callApi {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"ios2",@"app", nil];

    
    for (int i = 0; i < [queuedData count]; i++) {
        [dic setObject:[queuedData objectAtIndex:i] forKey:[NSString stringWithFormat:@"%i",i+1]];
    }
    
    if (self.wifiOn || self.cellularOn || self.interNetOn) {
        [ActivityIndicator show];
        
        [EventAPICall apiCallWithName:@"mylocations_upload" parameters:dic success:^(id response){
            
            if ([response isKindOfClass:[NSDictionary class]]) {
                /*{response:{ "status":"Success", "updates":"'.$successes.'", "duration":"'.$TimeTaken.'"}}
                 {response:{ "status":"failed", "reason_code": "203", "reason":"no date"}}  */
                
                if ([[response valueForKeyPath:@"response.status"] isEqualToString:@"Success"]) {
                    // data sent success
                    [queuedData removeAllObjects];
                    [[NSUserDefaults standardUserDefaults] setObject:queuedData forKey:@"queue"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self updateLable];
                    [[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your location successfully updated" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                }
                
                else {
                    // login fail
                    
                    @try {
                        [[[UIAlertView alloc] initWithTitle:@"Error!" message:[NSString stringWithFormat:@"Your location update unsuccessfull\n%@",[response valueForKeyPath:@"response.reason"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                        
                    }
                    @catch (NSException *exception) {
                        NSLog(@"%@",exception.description);
                    }
                    @finally {
                        //do nothing
                    }
                    
                }
                
            }
            goneForAutoRefresh = NO;
            [ActivityIndicator hide];
            
        }failure:^(id error){
            
            [ActivityIndicator hide];
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"There is network issue\nPlease try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            
            
        }];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Internet down" message:@"Your internet connection is down\nYour location update is added to pending queue" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    
    
}

#pragma mark - Network utility

- (void)initNetwork {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    __weak __block typeof(self) weakself = self;
    
    
    
    //////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////
    //
    // create a Reachability object for www.google.com
    
    self.googleReach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    self.googleReach.reachableBlock = ^(Reachability * reachability)
    {
        
        
        weakself.cellularOn = YES;
        
        // to update UI components from a block callback
        // you need to dipatch this to the main thread
        // this uses NSOperationQueue mainQueue
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
        }];
    };
    
    self.googleReach.unreachableBlock = ^(Reachability * reachability)
    {
        weakself.cellularOn = NO;
        
        // to update UI components from a block callback
        // you need to dipatch this to the main thread
        // this one uses dispatch_async they do the same thing (as above)
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    };
    
    [self.googleReach startNotifier];
    
    
    
    //////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////
    //
    // create a reachability for the local WiFi
    
    self.localWiFiReach = [Reachability reachabilityForLocalWiFi];
    
    // we ONLY want to be reachable on WIFI - cellular is NOT an acceptable connectivity
    self.localWiFiReach.reachableOnWWAN = NO;
    
    self.localWiFiReach.reachableBlock = ^(Reachability * reachability)
    {
        weakself.wifiOn = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    };
    
    self.localWiFiReach.unreachableBlock = ^(Reachability * reachability)
    {
        weakself.wifiOn = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    };
    
    [self.localWiFiReach startNotifier];
    
    
    
    //////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////
    //
    // create a Reachability object for the internet
    
    self.internetConnectionReach = [Reachability reachabilityForInternetConnection];
    
    self.internetConnectionReach.reachableBlock = ^(Reachability * reachability)
    {
        weakself.interNetOn = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    };
    
    self.internetConnectionReach.unreachableBlock = ^(Reachability * reachability)
    {
        weakself.interNetOn = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    };
    
    [self.internetConnectionReach startNotifier];
    
}

-(void)reachabilityChanged:(NSNotification*)note {
    Reachability * reach = [note object];
    
    if(reach == self.googleReach)
    {
        if([reach isReachable])
        {
            NSString * temp = [NSString stringWithFormat:@"GOOGLE Notification Says Reachable(%@)", reach.currentReachabilityString];
            NSLog(@"%@", temp);
            self.cellularOn = YES;
            if (autRetry && [queuedData count]) {
                [self autoRefresh];
            }
            
        }
        else
        {
            NSString * temp = [NSString stringWithFormat:@"GOOGLE Notification Says Unreachable(%@)", reach.currentReachabilityString];
            NSLog(@"temp%@",temp);
            self.cellularOn = NO;
            
        }
    }
    else if (reach == self.localWiFiReach)
    {
        if([reach isReachable])
        {
            NSString * temp = [NSString stringWithFormat:@"LocalWIFI Notification Says Reachable(%@)", reach.currentReachabilityString];
            NSLog(@"%@", temp);
            self.wifiOn = YES;
            if (autRetry && [queuedData count]) {
                [self autoRefresh];
            }
            
            
        }
        else
        {
            NSString * temp = [NSString stringWithFormat:@"LocalWIFI Notification Says Unreachable(%@)", reach.currentReachabilityString];
            NSLog(@"%@", temp);
            self.wifiOn = NO;
            
            
        }
    }
    else if (reach == self.internetConnectionReach)
    {
        if([reach isReachable])
        {
            NSString * temp = [NSString stringWithFormat:@"InternetConnection Notification Says Reachable(%@)", reach.currentReachabilityString];
            NSLog(@"%@", temp);
            self.interNetOn = YES;
            if (autRetry && [queuedData count]) {
                [self autoRefresh];
            }
            
            
        }
        else
        {
            NSString * temp = [NSString stringWithFormat:@"InternetConnection Notification Says Unreachable(%@)", reach.currentReachabilityString];
            NSLog(@"%@", temp);
            self.interNetOn = NO;
            
            
        }
    }
    
}

- (void)autoRefresh {
    
    if (!goneForAutoRefresh) {
        goneForAutoRefresh = YES;
        [self callApi];
    }
    
}

@end
