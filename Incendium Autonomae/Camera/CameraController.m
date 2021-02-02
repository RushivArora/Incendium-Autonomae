//
//  CameraController.m
//  Incendium Autonomae
//
//  Created by Rooshiv Arora on 12/29/20.
//

#import "CameraController.h"

#define WeakRef(__obj) __weak typeof(self) __obj = self
#define WeakReturn(__obj) if(__obj ==nil)return;

@interface CameraController ()

@end

@implementation CameraController

+ (instancetype)sharedInstance {
    static CameraController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CameraController alloc] init];
    });
    return sharedInstance;
}

- (void)setupVideoPreviewer:(UIView*) fpvPreviewView {
    [[DJIVideoPreviewer instance] setView:fpvPreviewView];
    DJIBaseProduct *product = [DJISDKManager product];
    if ([product.model isEqual:DJIAircraftModelNameA3] ||
        [product.model isEqual:DJIAircraftModelNameN3] ||
        [product.model isEqual:DJIAircraftModelNameMatrice600] ||
        [product.model isEqual:DJIAircraftModelNameMatrice600Pro]){
        [[DJISDKManager videoFeeder].secondaryVideoFeed addListener:self withQueue:nil];

    }else{
        [[DJISDKManager videoFeeder].primaryVideoFeed addListener:self withQueue:nil];
    }
    [[DJIVideoPreviewer instance] start];
}

- (void)resetVideoPreview {
    [[DJIVideoPreviewer instance] unSetView];
    DJIBaseProduct *product = [DJISDKManager product];
    if ([product.model isEqual:DJIAircraftModelNameA3] ||
        [product.model isEqual:DJIAircraftModelNameN3] ||
        [product.model isEqual:DJIAircraftModelNameMatrice600] ||
        [product.model isEqual:DJIAircraftModelNameMatrice600Pro]){
        [[DJISDKManager videoFeeder].secondaryVideoFeed removeListener:self];
    }else{
        [[DJISDKManager videoFeeder].primaryVideoFeed removeListener:self];
    }
}

#pragma mark Custom Methods
- (DJICamera*) fetchCamera {
    
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).camera;
    }else if ([[DJISDKManager product] isKindOfClass:[DJIHandheld class]]){
        return ((DJIHandheld *)[DJISDKManager product]).camera;
    }
    
    return nil;
}

#pragma mark - DJIVideoFeedListener

-(void)videoFeed:(DJIVideoFeed *)videoFeed didUpdateVideoData:(NSData *)videoData {
    [[DJIVideoPreviewer instance] push:(uint8_t *)videoData.bytes length:(int)videoData.length];
}

#pragma mark - DJICameraDelegate

-(void) camera:(DJICamera*)camera didUpdateSystemState:(DJICameraSystemState*)systemState
{
}

#pragma mark DJISDKManagerDelegate Method
- (void)productConnected:(DJIBaseProduct *)product
{
    if(product){
        DJICamera *camera = [self fetchCamera];
        if (camera != nil) {
            camera.delegate = self;
        }
       // [self setupVideoPreviewer];
    }

}

- (void)productDisconnected
{
    DJICamera *camera = [self fetchCamera];
    if (camera && camera.delegate == self) {
        [camera setDelegate:nil];
    }
    [self resetVideoPreview];
    
}

@end

