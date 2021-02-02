//
//  DefaultLayoutViewController.m
//  UILibraryDemo
//
//  Created by DJI on 16/4/2017.
//  Copyright © 2017 DJI. All rights reserved.
//

#import "RegistrationController.h"

/*
 
 THIS IS THE APP REGISTRATION
 
 THE APP NEEDS TO REGISTER WITH DJI IN ORDER TO BE ACTIVATED AND AUTHORISED TO USE FEATURES SUCH AS MAPS, CAMERA, AND SO ON
 
 */

@interface RegistrationController ()

@end

@implementation RegistrationController

- (void)viewDidLoad
{
    //Please enter your App Key in the info.plist file.
    //[DJISDKManager registerAppWithDelegate:self];
}

+ (instancetype)sharedInstance {
    static RegistrationController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RegistrationController alloc] init];
    });
    return sharedInstance;
}

- (void)registerApp {
    
    [DJISDKManager registerAppWithDelegate:self];
}

- (void)showAlertViewWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alertViewController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertViewController addAction:okAction];
        UIViewController *rootViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
        [rootViewController presentViewController:alertViewController animated:YES completion:nil];
    });

}

#pragma mark DJISDKManager Delegate Methods
- (void)appRegisteredWithError:(NSError *)error
{
    if (!error) {
        [self showAlertViewWithMessage:@"Registration Success"];
        //[DJISDKManager startConnectionToProduct];
        [DJISDKManager enableBridgeModeWithBridgeAppIP:@"10.0.0.2"];
    }else
    {
        [self showAlertViewWithMessage:[NSString stringWithFormat:@"Registration Error:%@", error]];
    }
}

/*
- (void)productConnected:(DJIBaseProduct *)product
{
    NSLog(@"Product Connected");
    //[self showAlertViewWithMessage:@"Product Connected"];
    /*
    //If this demo is used in China, it's required to login to your DJI account to activate the application. Also you need to use DJI Go app to bind the aircraft to your DJI account. For more details, please check this demo's tutorial.
    [[DJISDKManager userAccountManager] logIntoDJIUserAccountWithAuthorizationRequired:NO withCompletion:^(DJIUserAccountState state, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Login failed: %@", error.description);
        }
    }];

}
*/

 

@end
