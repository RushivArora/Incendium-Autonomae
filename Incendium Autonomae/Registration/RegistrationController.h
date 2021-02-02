//
//  RegistrationController.h
//  Incendium Autonomae
//
//  Created by Rooshiv Arora on 12/28/20.
//

#import <DJIUXSDK/DJIUXSDK.h>

@interface RegistrationController : NSObject <DJISDKManagerDelegate>

+ (instancetype)sharedInstance;

- (void)registerApp;

@end
