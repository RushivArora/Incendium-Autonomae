//
//  CameraController.h
//  Incendium Autonomae
//
//  Created by Rooshiv Arora on 12/29/20.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import <DJIUXSDK/DJIUXSDK.h>
#import <DJIWidget/DJIVideoPreviewer.h>

@interface CameraController : NSObject <DJIVideoFeedListener, DJISDKManagerDelegate, DJICameraDelegate>

+ (instancetype)sharedInstance;

- (void)setupVideoPreviewer:(UIView *) fpvPreviewView;

- (void)resetVideoPreview;

- (DJICamera*) fetchCamera;

-(void)videoFeed:(DJIVideoFeed *)videoFeed didUpdateVideoData:(NSData *)videoData;

-(void) camera:(DJICamera*)camera didUpdateSystemState:(DJICameraSystemState*)systemState;

- (void)productConnected:(DJIBaseProduct *)product;

- (void)productDisconnected;


@end
