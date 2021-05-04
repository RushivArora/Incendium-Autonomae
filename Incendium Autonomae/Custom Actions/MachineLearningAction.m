//
//  MachineLearningAction.m
//  Incendium Autonomae
//
//  Created by Rooshiv Arora on 1/20/21.
//

#import <Foundation/Foundation.h>
#import "MachineLearningAction.h"

#define WeakSelf(__TARGET__) __weak typeof(self) __TARGET__=self
#define WeakRef(__obj) __weak typeof(self) __obj = self
#define WeakReturn(__obj) if(__obj ==nil)return;

@implementation MachineLearningAction

- (instancetype _Nullable)initWithNumberOfImages:(int)numImages{
    self = [super init];
    if (self) {
        _numImages = numImages;
        _label = 10;
    }
    return self;
}

- (void) willRun{
    if(self.numImages > 0){
        NSLog(@"Timeline ML: Object was instantiated correctly. It should run as expected");
    }
}

- (void) run{
    [[DJISDKManager missionControl] elementDidStartRunning:self];
    [self printAction];
    [self loadMediaListsForMediaDownloadMode];
}

- (void) didRun {
    NSLog(@"Timeline ML: Was the Machine Learning Model output and running message printed? If so it ran");
}

- (void) stopRun {
    //do nothing
    NSLog(@"Timeline ML: Stopping");
}

- (bool) isPausable{
    NSLog(@"Timeline ML: isPausable");
    return false;
}

- (void) resumeRun{
    NSLog(@"Timeline ML: Resume Run");
}

- (void) pauseRun {
    NSLog(@"Timeline ML: In Pause");
}

- (NSError *_Nullable)checkValidity {
    NSLog(@"Timeline ML: Checking Validity");
    return nil;
}

- (void) printAction {
    NSLog(@"Timeline ML: I am in the custom aircraft action");
}

#pragma mark Custom Methods
- (DJICamera*) fetchCamera {
    
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        NSLog(@"Timeline: Fetching camera in MLAction");
        return ((DJIAircraft*)[DJISDKManager product]).camera;
    }else if ([[DJISDKManager product] isKindOfClass:[DJIHandheld class]]){
        return ((DJIHandheld *)[DJISDKManager product]).camera;
    }
    
    return nil;
}

-(void)loadMediaListsForMediaDownloadMode {
    DJICamera *camera = [self fetchCamera];

    WeakSelf(target);
    [camera.mediaManager refreshFileListOfStorageLocation:DJICameraStorageLocationSDCard withCompletion:^(NSError * _Nullable error) {
        WeakReturn(target);
        if (error) {
            NSLog(@"Timeline: Refresh file list failed: %@", error.description);
            NSLog(@"Timeline: Download List Refresh error");
        }
        else {
            NSLog(@"Timeline: Download List Refresh Success");
            [target downloadPhotosForMediaDownloadMode];
        }
    }];
}

-(void)downloadPhotosForMediaDownloadMode {
    __block int finishedFileCount = 0;

    self.imageArray=[NSMutableArray new];


    DJICamera *camera = [self fetchCamera];
    [camera setMode:DJICameraModeMediaDownload withCompletion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Timeline: Enter Media Download mode failed on second time: %@", error.description);
        }
        else {
            NSLog(@"Timeline: Entered media download mode success for second time");

            if(camera.isInternalStorageSupported){
                NSLog(@"Timeline: Internal storage supported");
            }else{
                NSLog(@"Timeline: Only SD card storage supported");
            }
            
            NSArray<DJIMediaFile *> *files = [camera.mediaManager sdCardFileListSnapshot];
            NSLog(@"Timeline: About to print download files. File count: %d", (int)files.count);
            if (files.count < self.numImages) {
                NSLog(@"Timeline: Number of files less than number of photos. Not enough photos are taken");
                return;
            }
    
            NSLog(@"Timeline: Enough photos are taken");
            [camera.mediaManager.taskScheduler resumeWithCompletion:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Timeline: Download failed. Resume file task scheduler failed");
                }
            }];
            

            WeakSelf(target);
            for (int i = (int)files.count - [target numImages]; i < files.count; i++) {
                DJIMediaFile *file = files[i];
                
                DJIFetchMediaTask *task = [DJIFetchMediaTask taskWithFile:file content:DJIFetchMediaTaskContentPreview andCompletion:^(DJIMediaFile * _Nonnull file, DJIFetchMediaTaskContent content, NSError * _Nullable error) {
                    WeakReturn(target);
                    if (error) {
                        NSLog(@"Timeline: Download failed");
                    }
                    else {
                        [target.imageArray addObject:file.preview];
                        [target.imageArray addObject:file.preview];
                        finishedFileCount++;

                        if (finishedFileCount == [target numImages]) {

                            NSLog(@"Timeline: Download complete");
                            [self MLMachineLearning];
                            [camera setMode:DJICameraModeShootPhoto withCompletion:^(NSError * _Nullable error) {
                                if (error) {
                                    NSLog(@"Timeline: Download done, set CameraMode to ShootPhoto Failed");
                                    double delayInSeconds = 2.0;
                                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                        NSLog(@"About to stop");
                                        [[DJISDKManager missionControl] element:self didFinishRunningWithError:nil];
                                    });
                                }
                                else{
                                    NSLog(@"Timeline: Download done, set CameraMode to ShootPhoto success");
                                    double delayInSeconds = 2.0;
                                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                        NSLog(@"About to stop");
                                        [[DJISDKManager missionControl] element:self didFinishRunningWithError:nil];
                                    });
                                }
                            }];
                        }
                    }
                }];
                [camera.mediaManager.taskScheduler moveTaskToEnd:task];
            }
        }
    }];
}

- (int) MLMachineLearning {
    NSLog(@"Timeline: In Machine Learning detection method.");
    __weak MachineLearningAction *weakSelf = self;
    __weak NSMutableArray *weakImageArray = self.imageArray;
    
    UIImage *temp = [weakImageArray objectAtIndex:0];
    UIImage *myIcon = [weakSelf imageWithImage:temp scaledToSize:CGSizeMake(512, 256)];
    CGFloat width = myIcon.size.width;
    CGFloat height = myIcon.size.height;
    NSLog(@"Timeline: Width: %0.2f, Height: %0.2f", width, height);
    
    NSError *error;
    weakSelf.model = [[[FIRE_DETECTION3 alloc] init] model];
    weakSelf.input = [[FIRE_DETECTION3Input alloc] initWithMy_inputFromCGImage:myIcon.CGImage error:&error];
    NSLog(@"Timeline: Input Error Message for ML model: %@",error);
    weakSelf.output = ((FIRE_DETECTION3Output *)[weakSelf.model predictionFromFeatures:weakSelf.input error:&error]);
    NSLog(@"Timeline: Output Error Message for ML model: %@",error);
    if (_output == nil){
        NSLog(@"Timeline: nil output from ML model");
    }
    else{
        NSLog(@"Timeline: Not nil output from ML model");
    }
    MLMultiArray *arr = [[_output featureValueForName:@"my_outputs"] multiArrayValue];
    Float32 *ptr = (Float32 *)[arr dataPointer];
    NSLog(@"Timeline: Fire Probability  : %@", arr[0]);
    NSLog(@"Timeline: Smoke Probability : %@", arr[1]);
    NSLog(@"Timeline: Spare Probability : %@", arr[2]);
    weakSelf.label = 5;
    float max = 0.0;
    if(arr[0].floatValue >= max){
        weakSelf.label = 0;
        max = arr[0].floatValue;
        NSLog(@"Probability in Fire set to %0.05f", max);
    }
    if(arr[1].floatValue >= max){
        weakSelf.label = 1;
        max = arr[1].floatValue;
        NSLog(@"Probability in Smoke set to %0.05f", max);
    }
    if(arr[2].floatValue >= max){
        weakSelf.label = 2;
        max = arr[2].floatValue;
        NSLog(@"Probability in Spare set to %0.05f", max);
    }
    
    NSLog(@"Check : %0.005f", arr[0].floatValue);
    NSLog(@"Check : %0.005f", arr[1].floatValue);
    NSLog(@"Check : %0.005f", arr[2].floatValue);

    int dim1 = 0;
    int dim2 = 0;
    int dim3 = 0;
    int dim4 = 0;
    int dim5 = 0;
    int offset = 0;
    offset = dim1*arr.strides[0].intValue;
    offset = offset + dim2*arr.strides[1].intValue;
    offset = offset + dim3*arr.strides[2].intValue;
    offset = offset + dim4*arr.strides[3].intValue;
    offset = offset + dim5*arr.strides[4].intValue;
    NSLog(@"Timeline: Fire Probability output offset: %0.2f",ptr[offset]);
    dim1 = 0;
    dim2 = 0;
    dim3 = 1;
    dim4 = 0;
    dim5 = 0;
    offset = 0;
    offset = dim1*arr.strides[0].intValue;
    offset = offset + dim2*arr.strides[1].intValue;
    offset = offset + dim3*arr.strides[2].intValue;
    offset = offset + dim4*arr.strides[3].intValue;
    offset = offset + dim5*arr.strides[4].intValue;
    NSLog(@"Timeline: Smoke Probability output offset: %0.2f",ptr[offset]);
    dim1 = 0;
    dim2 = 0;
    dim3 = 2;
    dim4 = 0;
    dim5 = 0;
    offset = 0;
    offset = dim1*arr.strides[0].intValue;
    offset = offset + dim2*arr.strides[1].intValue;
    offset = offset + dim3*arr.strides[2].intValue;
    offset = offset + dim4*arr.strides[3].intValue;
    offset = offset + dim5*arr.strides[4].intValue;
    NSLog(@"Timeline: Spare Probability output offset: %0.2f",ptr[offset]);
    return 0;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end

