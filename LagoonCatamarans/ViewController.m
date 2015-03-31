//
//  ViewController.m
//  LagoonCatamarans
//
//  Created by Yosmite on 1/21/15.
//  Copyright (c) 2015 LC. All rights reserved.
//
#import "MainViewController.h"
#import "ActivityIndicator.h"
#import "ViewController.h"
#import "EventAPICall.h"
#import "AppDelegate.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtFUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtFPassword;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    singleTap.numberOfTapsRequired = 1;
    
    [self.view addGestureRecognizer:singleTap];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loginDone"]) {
        
        _txtFPassword.text =  [[NSUserDefaults standardUserDefaults] valueForKey:@"password"];
        _txtFUsername.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
        
        [self performSelector:@selector(callApi) withObject:nil afterDelay:0.2];
        
    }
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)tapDetected:(UIGestureRecognizer *) sender
{
    UIGestureRecognizer *recognizer = (UIGestureRecognizer*)sender;
    if (![recognizer.view isKindOfClass:[UITextField class]]) {
        [_txtFUsername resignFirstResponder];
        [_txtFPassword resignFirstResponder];
        
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnAction:(id)sender {
    
    [_txtFPassword resignFirstResponder];
    [_txtFUsername resignFirstResponder];
    
    if (_txtFPassword.text.length && _txtFUsername.text.length) {
        [self callApi];
    }
    else if (!_txtFUsername.text.length) {
        
        [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please enter your username" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];

    }
    else
        [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please enter your password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

#pragma mark UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if (textField == _txtFUsername) {
        if(!_txtFPassword.text.length)
            [_txtFPassword becomeFirstResponder];
        else
            [textField resignFirstResponder];
    }
    else if (textField == _txtFPassword) {
        if (_txtFPassword.text.length && _txtFUsername.text.length) {
            // call sign-in API
            
            [self performSelector:@selector(callApi) withObject:nil afterDelay:0.3];
        }
        
        [textField resignFirstResponder];
        
    }
    
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

#pragma mark - API

- (void) callApi
{
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:_txtFUsername.text, @"username", _txtFPassword.text, @"password", nil];
    [ActivityIndicator show];
    
    [EventAPICall apiCallWithName:@"authenticate" parameters:param success:^(id response){
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKeyPath:@"response.status"] isEqualToString:@"success"]) {
                // login success
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"loginDone"];
                [[NSUserDefaults standardUserDefaults] setValue:_txtFPassword.text forKey:@"password"];
                [[NSUserDefaults standardUserDefaults] setValue:_txtFUsername.text forKey:@"username"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self performSelector:@selector(goFurther) withObject:nil afterDelay:0.2];
            }
            
            else {
                // login fail
                
                @try {
                    [[[UIAlertView alloc] initWithTitle:@"Error!" message:[NSString stringWithFormat:@"Your login unsuccessfull\n%@",[response valueForKeyPath:@"response.reason"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];

                }
                @catch (NSException *exception) {
                    NSLog(@"%@",exception.description);
                }
                @finally {
                    //do nothing
                }
                
            }
            
        }
        [ActivityIndicator hide];
        
    }failure:^(id error){
        
        [ActivityIndicator hide];
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"There is network issue\nPlease try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];

        
    }];
}

- (void)goFurther {
    
    MainViewController *mVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mainVC"];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = mVC;
    [appDelegate.window setNeedsDisplay];
}

@end
