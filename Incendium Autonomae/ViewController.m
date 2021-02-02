//
//  ViewController.m
//  Incendium Autonomae
//
//  Created by Rooshiv Arora on 12/28/20.
//

#import "ViewController.h"
//#import "CameraController.h"
#import <CoreML/CoreML.h>
#import <Vision/Vision.h>
#import "FIRE_DETECTION.h"
#import "DemoUtility.h"
#import "FIRE_DETECTION2.h"
#import "MachineLearningAction.h"

#define PHOTO_NUMBER 1
#define ROTATE_ANGLE 45
#define WeakSelf(__TARGET__) __weak typeof(self) __TARGET__=self
#define WeakRef(__obj) __weak typeof(self) __obj = self
#define WeakReturn(__obj) if(__obj ==nil)return;
#define ENABLE_DEBUG_MODE 1

@interface ViewController ()<DJIVideoFeedListener, DJISDKManagerDelegate, DJICameraDelegate, DJIFlightControllerDelegate>


//Camera Interface
@property (nonatomic, strong) DJICamera* camera;
@property (weak, nonatomic) IBOutlet UIView *fpvPreviewView;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *changeWorkModeSegmentControl;
@property (assign, nonatomic) BOOL isRecording;

//Camera controllers
@property (nonatomic, assign) __block int numPhotosSelected;
@property (strong,nonatomic) NSMutableArray * imageArray;
@property (strong, nonatomic) UIAlertView* downloadProgressAlert;


//Status Bar Interface
@property (weak, nonatomic) IBOutlet UIView *statusBarContainingView;
@property (strong, nonatomic) DUXStatusBarViewController *statusBarVC;
@property (strong, nonatomic) NSTimer *widgetMovingTimer;
@property (readwrite, nonatomic) DUXWidgetCollectionViewStack lastStack;


- (IBAction)captureAction:(id)sender;
- (IBAction)recordAction:(id)sender;
- (IBAction)changeWorkModeAction:(id)sender;
-(void) someCameraStuff;


//Segue Interface
@property (weak, nonatomic) IBOutlet UIButton *segueToPanels;
@property (weak, nonatomic) IBOutlet UIButton *segueToWaypoint;

//Waypoint Mission Classes
@property (strong, nonatomic) UIAlertController* prepareMissionProgressAlert;
@property (nonatomic) bool isMissionStarted;
@property (atomic) CLLocationCoordinate2D aircraftLocation;
@property (atomic) double aircraftAltitude;
@property (atomic) DJIGPSSignalLevel gpsSignalLevel;
@property (atomic) double aircraftYaw;
@property (nonatomic, strong) DJIMission* mission;
@property (strong, nonatomic) UIAlertController* uploadMissionProgressAlert;
@property (nonatomic, strong) MachineLearningAction *custom;

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.lastStack = DUXWidgetCollectionViewStackFirst;
    [[DJIVideoPreviewer instance] setView:self.fpvPreviewView];
    [[DJISDKManager videoFeeder].primaryVideoFeed addListener:self withQueue:nil];
    [[DJIVideoPreviewer instance] start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[DJIVideoPreviewer instance] setView:nil];
    [[DJISDKManager videoFeeder].primaryVideoFeed removeListener:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.segueToPanels setTitle:@"Name Changed" forState:UIControlStateNormal];
    
    //WayPoint Mission Stuff
    self.isMissionStarted = NO;
    self.aircraftLocation = kCLLocationCoordinate2DInvalid;
    
    // Do any additional setup after loading the view.
    self.statusBarVC = [[DUXStatusBarViewController alloc] init];
    // Adding our DUXStatusBarViewController to our container in code.
    // This could be done in the storyboard
    [self addChildViewController:self.statusBarVC];
    [self.statusBarContainingView addSubview:self.statusBarVC.view];
    self.statusBarVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.statusBarVC.view.topAnchor constraintEqualToAnchor:self.statusBarContainingView.topAnchor].active = YES;
    [self.statusBarVC.view.bottomAnchor constraintEqualToAnchor:self.statusBarContainingView.bottomAnchor].active = YES;
    [self.statusBarVC.view.leadingAnchor constraintEqualToAnchor:self.statusBarContainingView.leadingAnchor].active = YES;
    [self.statusBarVC.view.trailingAnchor constraintEqualToAnchor:self.statusBarContainingView.trailingAnchor].active = YES;
    [self.statusBarVC didMoveToParentViewController:self];
    
    /*
     *  Customizing a predefined widget view collection
     */
    
    // Removing a pre-defined widget you don't want.
    UIView<DUXWidgetProtocol> *preflightChecklistWidget = [self.statusBarVC widgetAtIndex:1];
    
    if (preflightChecklistWidget)
    {
        [self.statusBarVC removeWidget:preflightChecklistWidget];
    }
    
    // Changing the edgeInset of a placed widget.
    DUXWidgetItem *widgetItem = [self.statusBarVC widgetItemAtIndex:0];
    if (widgetItem) {
        widgetItem.edgeInset = UIEdgeInsetsMake(10, widgetItem.edgeInset.left, 10, widgetItem.edgeInset.right);
    }
    
    // Switch stack for widgets in stack collections
    UIView<DUXWidgetProtocol> *batteryWidget = [self.statusBarVC widgetWithClass:[DUXBatteryWidget class]];
    if (batteryWidget) {
        [self.statusBarVC.statusBarView moveWidget:batteryWidget to:DUXWidgetCollectionViewStackFirst];
    }
    
    // We need to call reloadData to adjust the rendering, but we call it at the end to avoid redundant calls
    [self.statusBarVC.statusBarView reloadData];
    
    [self performSelector:@selector(setUpFlightController) withObject:nil afterDelay:3.0 ];
}

- (void) setUpFlightController {
    DJIFlightController* flightController = [DemoUtility fetchFlightController];
    if (flightController) {
        NSLog(@"Successfully set ViewController as Flight Controller Delegate");
        flightController.delegate = self;
    }
    else{
        NSLog(@"Couldn't set ViewController as Flight Controller Delegate");
    }
}

/*
 ******************************************************************************
 
 STATUS BAR METHODS IMPLEMENTED HERE
 
 ******************************************************************************
 */

- (void)moveWidget
{
    // Switch stack for widgets in stack collections

    UIView<DUXWidgetProtocol> *batteryWidget = [self.statusBarVC widgetWithClass:[DUXBatteryWidget class]];
    
    if (self.lastStack == DUXWidgetCollectionViewStackFirst) {
        self.lastStack = DUXWidgetCollectionViewStackLast;
    }else
    {
        self.lastStack = DUXWidgetCollectionViewStackFirst;
    }
    
    if (batteryWidget) {
        [self.statusBarVC.statusBarView moveWidget:batteryWidget to:self.lastStack];
    }
    
    WeakRef(target);
    dispatch_async(dispatch_get_main_queue(),^ {
        WeakReturn(target);
        [target.statusBarVC.statusBarView reloadData];
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)DisplayPanelsButtonClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"DisplayPanels" sender:self];
}


/*
 ******************************************************************************
 
 CAMERA METHODS IMPLEMENTED HERE
 
 ******************************************************************************
 */

- (void)setupVideoPreviewer {
    [[DJIVideoPreviewer instance] setView:self.fpvPreviewView];
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
- (void)showAlertViewWithTitle:(NSString *)title withMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}


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
    self.isRecording = systemState.isRecording;
    
    //[self.currentRecordTimeLabel setHidden:!self.isRecording];
    //[self.currentRecordTimeLabel setText:[self formattingSeconds:systemState.currentVideoRecordingTimeInSeconds]];
    
    if (self.isRecording) {
        [self.recordBtn setTitle:@"Stop Record" forState:UIControlStateNormal];
    }else
    {
        [self.recordBtn setTitle:@"Start Record" forState:UIControlStateNormal];
    }
    
    //Update UISegmented Control's state
    if (systemState.mode == DJICameraModeShootPhoto) {
        [self.changeWorkModeSegmentControl setSelectedSegmentIndex:0];
    }else if (systemState.mode == DJICameraModeRecordVideo){
        [self.changeWorkModeSegmentControl setSelectedSegmentIndex:1];
    }
    
}


- (IBAction)changeWorkModeAction:(id)sender {
    
    
    NSLog(@"Work Mode Changed");
  
    UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
    __weak DJICamera* camera = [self fetchCamera];
    
    if (camera) {
        NSLog(@"Camera Detected");
        WeakRef(target);
        if (segmentControl.selectedSegmentIndex == 0) { //Take photo
            
            [camera setMode:DJICameraModeShootPhoto withCompletion:^(NSError * _Nullable error) {
                WeakReturn(target);
                if (error) {
                    [target showAlertViewWithTitle:@"Set DJICameraModeShootPhoto Failed" withMessage:error.description];
                }
            }];
            
        }else if (segmentControl.selectedSegmentIndex == 1){ //Record video
            
            [camera setMode:DJICameraModeRecordVideo withCompletion:^(NSError * _Nullable error) {
                WeakReturn(target);
                if (error) {
                    [target showAlertViewWithTitle:@"Set DJICameraModeRecordVideo Failed" withMessage:error.description];
                }
            }];
            
        }
    }

}


- (IBAction)DisplayWaypointClicked:(id)sender {
    [self performSegueWithIdentifier:@"DisplayWaypoint" sender:self];
}

- (IBAction)captureAction:(id)sender {
    [self someCameraStuff];
}

- (void)someCameraStuff {
    
    WeakSelf(target);

    DJICamera *camera = [target fetchCamera];
    if(camera.isPlaybackSupported){
        NSLog(@"PlayBack supported");
    }
    else{
        NSLog(@"PlayBack not supported");
    }
    [camera setShootPhotoMode:DJICameraShootPhotoModeSingle withCompletion:^(NSError * _Nullable error) {
        WeakReturn(target);
        if (!error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSLog(@"Set Capture mode success");
                NSLog(@"About to shoot a photo");
                [camera startShootPhotoWithCompletion:^(NSError * _Nullable error) {
                    WeakReturn(target);
                    if (error) {
                        NSLog(@"Capture error");
                        [target showAlertViewWithTitle:@"Take Photo Error" withMessage:error.description];
                    }
                    else {
                        [target showAlertViewWithTitle:@"Capture Photos Success" withMessage:@"Capture finished"];
                        NSLog(@"Capture Success");
                        [target playbackAndDownload];
                    }
                }];
                sleep(2);
            
            
            });
        }
    }];
    
}

- (void)playbackManager:(DJIPlaybackManager *)playbackManager didUpdatePlaybackState:(DJICameraPlaybackState *)playbackState
{
    self.numPhotosSelected = playbackState.selectedFileCount;
}

- (void)playbackAndDownload {
    
    WeakSelf(target);
    DJICamera *camera = [self fetchCamera];
    if (camera.isPlaybackSupported) {
        NSLog(@"Using Playback Mode");
        [camera setMode:DJICameraModePlayback withCompletion:^(NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                NSLog(@"Enter playback mode failed: %@", error.description);
            }else {
                [target selectPhotosPlaybackMode];
            }
        }];
    }
    else if (camera.isMediaDownloadModeSupported) {
        NSLog(@"Using Media Mode");
        [camera setMode:DJICameraModeMediaDownload withCompletion:^(NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                NSLog(@"Enter Media Download mode failed: %@", error.description);
            } else {
                NSLog(@"Entered media download mode success");
                [target loadMediaListsForMediaDownloadMode];
            }
        }];
    }
}

-(void)selectPhotosPlaybackMode {
    
    WeakSelf(target);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        WeakReturn(target);
        DJICamera *camera = [target fetchCamera];
        [camera.playbackManager enterMultiplePreviewMode];
        sleep(1);
        [camera.playbackManager enterMultipleEditMode];
        sleep(1);
        NSLog(@"Enter playback multiple preview and edit success");
        
        while (self.numPhotosSelected != PHOTO_NUMBER) {
            [camera.playbackManager selectAllFilesInPage];
            sleep(1);
            
            if(self.numPhotosSelected > PHOTO_NUMBER){
                for(int unselectFileIndex = 0; self.numPhotosSelected != PHOTO_NUMBER; unselectFileIndex++){
                    [camera.playbackManager toggleFileSelectionAtIndex:unselectFileIndex];
                    sleep(1);
                }
                break;
            }
            else if(self.numPhotosSelected < PHOTO_NUMBER) {
                [camera.playbackManager goToPreviousMultiplePreviewPage];
                sleep(1);
            }
        }
        NSLog(@"Select Photos success");
        NSLog(@"Number of photos selected is %d", self.numPhotosSelected);
        [target downloadPhotosPlaybackMode];
    });
}

-(void)downloadPhotosPlaybackMode {
    __block int finishedFileCount = 0;
    __block NSMutableData* downloadedFileData;
    __block long totalFileSize;
    __block NSString* targetFileName;
    
    self.imageArray=[NSMutableArray new];
    
    DJICamera *camera = [self fetchCamera];
    if (camera == nil) return;

    WeakSelf(target);
    [camera.playbackManager downloadSelectedFilesWithPreparation:^(NSString * _Nullable fileName, DJIDownloadFileType fileType, NSUInteger fileSize, BOOL * _Nonnull skip) {

        totalFileSize=(long)fileSize;
        downloadedFileData=[NSMutableData new];
        targetFileName=fileName;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            WeakReturn(target);
            [target showDownloadProgressAlert];
            [target.downloadProgressAlert setTitle:[NSString stringWithFormat:@"Download (%d/%d)", finishedFileCount + 1, PHOTO_NUMBER]];
            [target.downloadProgressAlert setMessage:[NSString stringWithFormat:@"FileName:%@ FileSize:%0.1fKB Downloaded:0.0KB", fileName, fileSize / 1024.0]];
        });
            
    } process:^(NSData * _Nullable data, NSError * _Nullable error) {
        
        WeakReturn(target);
        [downloadedFileData appendData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [target.downloadProgressAlert setMessage:[NSString stringWithFormat:@"FileName:%@ FileSize:%0.1fKB Downloaded:%0.1fKB", targetFileName, totalFileSize / 1024.0, downloadedFileData.length / 1024.0]];
        });
        
    } fileCompletion:^{
        WeakReturn(target);
        finishedFileCount++;

        UIImage *downloadPhoto=[UIImage imageWithData:downloadedFileData];
        [target.imageArray addObject:downloadPhoto];
        
    } overallCompletion:^(NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [target.downloadProgressAlert dismissWithClickedButtonIndex:0 animated:YES];
            target.downloadProgressAlert = nil;
            
            if (error) {
                
                [target showAlertViewWithTitle:@"Download Failed" withMessage:error.description];
            }else
            {
                // UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Download (%d/%d)", finishedFileCount, PHOTO_NUMBER] message:@"download finished" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alertView show];
                NSLog(@"Downloading File Success");
            }
            
            DJICamera *camera = [target fetchCamera];
            [camera setShootPhotoMode:DJICameraShootPhotoModeSingle withCompletion:^(NSError * _Nullable error) {
                if (error) {
                    
                    [target showAlertViewWithTitle:@"Set CameraMode to ShootPhoto Failed" withMessage:error.description];
                    
                }
            }];

        });
        
    }];
}

-(void)loadMediaListsForMediaDownloadMode {
    DJICamera *camera = [self fetchCamera];
    [self showDownloadProgressAlert];
    [self.downloadProgressAlert setTitle:[NSString stringWithFormat:@"Refreshing file list. "]];
    [self.downloadProgressAlert setMessage:[NSString stringWithFormat:@"Loading..."]];

    WeakSelf(target);
    [camera.mediaManager refreshFileListOfStorageLocation:DJICameraStorageLocationSDCard withCompletion:^(NSError * _Nullable error) {
        WeakReturn(target);
        if (error) {
            [target.downloadProgressAlert dismissWithClickedButtonIndex:0 animated:YES];
            target.downloadProgressAlert = nil;
            NSLog(@"Refresh file list failed: %@", error.description);
            NSLog(@"Download List Refresh error");
        }
        else {
            [target downloadPhotosForMediaDownloadMode];
            NSLog(@"Download List Refresh Success");
        }
    }];
}

-(void)downloadPhotosForMediaDownloadMode {
    __block int finishedFileCount = 0;

    self.imageArray=[NSMutableArray new];


    DJICamera *camera = [self fetchCamera];
    [camera setMode:DJICameraModeMediaDownload withCompletion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Enter Media Download mode failed on second time: %@", error.description);
        }
        else {
            NSLog(@"Entered media download mode success for second time");

            if(camera.isInternalStorageSupported){
                NSLog(@"Internal storage supported");
            }else{
                NSLog(@"Only SD card storage supported");
            }
            
            NSArray<DJIMediaFile *> *files = [camera.mediaManager sdCardFileListSnapshot];
            NSLog(@"About to print download files. File count: %d", (int)files.count);
            if (files.count < PHOTO_NUMBER) {
                [self.downloadProgressAlert dismissWithClickedButtonIndex:0 animated:YES];
                self.downloadProgressAlert = nil;
                [self showAlertViewWithTitle:@"Download failed" withMessage:@"Not enough photos are taken."];
                NSLog(@"Number of files less than number of photos. Not enough photos are taken");
                return;
            }
    
            NSLog(@"Enough photos are taken");
            [camera.mediaManager.taskScheduler resumeWithCompletion:^(NSError * _Nullable error) {
                if (error) {
                    [self.downloadProgressAlert dismissWithClickedButtonIndex:0 animated:YES];
                    self.downloadProgressAlert = nil;
                    [self showAlertViewWithTitle:@"Download failed" withMessage:@"Resume file task scheduler failed."];
                    NSLog(@"Download failed. Resume file task scheduler failed");
                }
            }];

            [self.downloadProgressAlert setTitle:[NSString stringWithFormat:@"Downloading..."]];
            [self.downloadProgressAlert setMessage:[NSString stringWithFormat:@"Download (%d/%d)", 0, PHOTO_NUMBER]];

            WeakSelf(target);
            for (int i = (int)files.count - PHOTO_NUMBER; i < files.count; i++) {
                DJIMediaFile *file = files[i];
                
                DJIFetchMediaTask *task = [DJIFetchMediaTask taskWithFile:file content:DJIFetchMediaTaskContentPreview andCompletion:^(DJIMediaFile * _Nonnull file, DJIFetchMediaTaskContent content, NSError * _Nullable error) {
                    WeakReturn(target);
                    if (error) {
                        [target.downloadProgressAlert dismissWithClickedButtonIndex:0 animated:YES];
                        target.downloadProgressAlert = nil;
                        [target showAlertViewWithTitle:@"Download Failed" withMessage:error.description];
                        NSLog(@"Download failed");
                    }
                    else {
                        [target.imageArray addObject:file.preview];
                        [target.imageArray addObject:file.preview];
                        finishedFileCount++;
                        [target.downloadProgressAlert setMessage:[NSString stringWithFormat:@"Download (%d/%d)", finishedFileCount, PHOTO_NUMBER]];

                        if (finishedFileCount == PHOTO_NUMBER) {

                            [target.downloadProgressAlert dismissWithClickedButtonIndex:0 animated:YES];
                            target.downloadProgressAlert = nil;
                            [self showAlertViewWithTitle:@"Download Complete" withMessage:[NSString stringWithFormat:@"%d files have been downloaded. ", PHOTO_NUMBER]];
                            NSLog(@"Download complete");
                    
                            [camera setMode:DJICameraModeShootPhoto withCompletion:^(NSError * _Nullable error) {
                                if (error) {
                                    [self showAlertViewWithTitle:@"Set CameraMode to ShootPhoto Failed" withMessage:@""];
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

-(void) showDownloadProgressAlert {
    if (self.downloadProgressAlert == nil) {
        NSLog(@"Showing Download Progress Alert");
        //self.downloadProgressAlert = [[UIAlertController alloc] itle:@"" message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        //[self.downloadProgressAlert show];
    }
}

//Pass the downloaded photos to TestingViewController
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"Testing"]) {
        self.imageArray = self.custom.imageArray;
        [segue.destinationViewController setValue:self.imageArray forKey:@"imageArray"];
    }
}

- (void) temp {
    NSLog(@"In Temp");
    VNCoreMLModel *m;
    VNCoreMLRequest *request;
    MLModel *model;
    
    model = [[[FIRE_DETECTION alloc] init] model];
                
    m = [VNCoreMLModel modelForMLModel: model error:nil];
    request = [[VNCoreMLRequest alloc] initWithModel: m completionHandler: (VNRequestCompletionHandler) ^(VNRequest *request, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(error){
                NSLog(@"VN Vision Error: %@", error);
            }
            NSInteger numberOfResults = request.results.count;
            NSLog(@"VN: Number of results log: %ld", (long)numberOfResults);
            NSArray *results = [request.results copy];
            if(results == nil){
                NSLog(@"VN: Results is nil");
            }
            else{
                NSLog(@"VN: Results is not nil");
                NSLog(@"VN: %@", results);
            }
            VNClassificationObservation *topResult = ((VNClassificationObservation *)(results[0]));
            if(topResult == nil){
                NSLog(@"VN: topResult is nil");
            }
            else{
                NSLog(@"VN: topResult is not nil");
                NSLog(@"VN: %@", topResult);
            }
            //NSString *messageLabel = [NSString stringWithFormat: @"%f: %@", topResult.confidence, topResult.identifier];
            //NSLog(@"%@", messageLabel);

            });
    }];
    
    request.imageCropAndScaleOption = VNImageCropAndScaleOptionCenterCrop;
    CIImage *coreGraphicsImage = [[CIImage alloc] initWithImage:self.imageArray[0]];

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCIImage:coreGraphicsImage  options:@{}];
            [handler performRequests:@[request] error:nil];
    });
}


- (IBAction)recordAction:(id)sender {
    NSLog(@"In Record Action");
    [self letsTrythis];
}

/*
 
 
 WAYPOINT MISSION CODE
 
 
 */

#pragma mark - DJIFlightControllerDelegate Method
- (void)flightController:(DJIFlightController *)fc didUpdateState:(DJIFlightControllerState *)state
{
    NSLog(@"Updating flight controller state data");
    //self.aircraftLocation = CLLocationCoordinate2DMake(state.aircraftLocation.coordinate.latitude, state.aircraftLocation.coordinate.longitude);
    self.aircraftLocation = state.aircraftLocation.coordinate;
    self.gpsSignalLevel = state.GPSSignalLevel;
    self.aircraftAltitude = state.altitude;
    self.aircraftYaw = state.attitude.yaw;
}

- (DJIWaypointMissionOperator *)missionOperator {
    return [[DJISDKManager missionControl] waypointMissionOperator];
}

- (void) initializeMission {

    DJIMutableWaypointMission *mission = [[DJIMutableWaypointMission alloc] init];
    mission.maxFlightSpeed = 15.0;
    mission.autoFlightSpeed = 4.0;
    
    DJIWaypoint *wp1 = [[DJIWaypoint alloc] initWithCoordinate:self.aircraftLocation];
    wp1.altitude = self.aircraftAltitude;

    for (int i = 0; i < PHOTO_NUMBER ; i++) {

        double rotateAngle = ROTATE_ANGLE*i;

        if (rotateAngle > 180) { //Filter the angle between -180 ~ 0, 0 ~ 180
            rotateAngle = rotateAngle - 360;
        }

        DJIWaypointAction *action1 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeShootPhoto param:0];
        DJIWaypointAction *action2 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeRotateAircraft param:rotateAngle];
        [wp1 addAction:action1];
        [wp1 addAction:action2];
    }

    DJIWaypoint *wp2 = [[DJIWaypoint alloc] initWithCoordinate:self.aircraftLocation];
    wp2.altitude = self.aircraftAltitude + 1;

    [mission addWaypoint:wp1];
    [mission addWaypoint:wp2];
    [mission setFinishedAction:DJIWaypointMissionFinishedNoAction]; //Change the default action of Go Home to None

    [[self missionOperator] loadMission:mission];

    WeakSelf(target);

    [[self missionOperator] addListenerToUploadEvent:self withQueue:dispatch_get_main_queue() andBlock:^(DJIWaypointMissionUploadEvent * _Nonnull event) {

        WeakReturn(target);
        if (event.currentState == DJIWaypointMissionStateUploading) {

            NSString *message = [NSString stringWithFormat:@"Uploaded Waypoint Index: %ld, Total Waypoints: %ld" ,event.progress.uploadedWaypointIndex + 1, event.progress.totalWaypointCount];

            if (target.uploadMissionProgressAlert == nil) {
                //target.uploadMissionProgressAlert = [[UIAlertController alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
                //[target presentViewController:self->_uploadMissionProgressAlert animated:YES completion:nil];
                
            }
            else {
                [target.uploadMissionProgressAlert setMessage:message];
            }

        }else if (event.currentState == DJIWaypointMissionStateReadyToExecute){

            [target.uploadMissionProgressAlert dismissViewControllerAnimated:0 completion:nil];
            target.uploadMissionProgressAlert = nil;

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Upload Mission Finished" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *startMissionAction = [UIAlertAction actionWithTitle:@"Start Mission" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [target startWaypointMission];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:cancelAction];
            [alert addAction:startMissionAction];
            [target presentViewController:alert animated:YES completion:nil];

        }

    }];

    [[self missionOperator] addListenerToFinished:self withQueue:dispatch_get_main_queue() andBlock:^(NSError * _Nullable error) {

        WeakReturn(target);

        if (error) {
            [target showAlertViewWithTitle:@"Mission Execution Failed" withMessage:[NSString stringWithFormat:@"%@", error.description]];
        }
        else {
            [target showAlertViewWithTitle:@"Mission Execution Finished" withMessage:nil];
        }
    }];

}

- (void)uploadWaypointMission {

    [self initializeMission];

    WeakSelf(target);

    [[self missionOperator] uploadMissionWithCompletion:^(NSError * _Nullable error) {

        WeakReturn(target);

        if (error) {
            NSLog(@"%@", [NSString stringWithFormat:@"Upload Mission Failed: %@", [NSString stringWithFormat:@"%@", error.description]]);
        }else
        {
            NSLog(@"Upload Mission Finished");
        }
    }];
}

- (void)startWaypointMission
{
    WeakSelf(target);
    //Start Mission
    [[self missionOperator] startMissionWithCompletion:^(NSError * _Nullable error) {

        WeakReturn(target);

        if (error) {
            [target showAlertViewWithTitle:@"Start Mission Failed" withMessage:[NSString stringWithFormat:@"%@", error.description]];
        }
        else {
            [target showAlertViewWithTitle:@"Start Mission Success" withMessage:nil];
        }

    }];
}

- (DJIMission *) initializeMission2 {

    DJIMutableWaypointMission *mission = [[DJIMutableWaypointMission alloc] init];
    mission.maxFlightSpeed = 10.0;
    mission.autoFlightSpeed = 4.0;
    mission.rotateGimbalPitch = true;
    mission.flightPathMode = DJIWaypointMissionFlightPathNormal;

    DJIWaypoint *wp1 = [[DJIWaypoint alloc] initWithCoordinate:self.aircraftLocation];
    wp1.altitude = self.aircraftAltitude;
    
    double initialAltitude = self.aircraftAltitude;
    
    DJIWaypointAction *action1 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeRotateGimbalPitch param:0];
    DJIWaypointAction *action2 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeRotateGimbalPitch param:-90];
    DJIWaypointAction *action3 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeShootPhoto param:0];
    DJIWaypointAction *action4 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeRotateGimbalPitch param:0];
    
    [wp1 addAction:action1];
    [wp1 addAction:action2];
    [wp1 addAction:action3];
    [wp1 addAction:action4];
    
    DJIWaypoint *wp2 = [[DJIWaypoint alloc] initWithCoordinate:self.aircraftLocation];
    wp2.altitude = initialAltitude + 1;
    
    DJIWaypoint *wp3 = [[DJIWaypoint alloc] initWithCoordinate:self.aircraftLocation];
    wp3.altitude = initialAltitude + 0.5;


    [mission addWaypoint:wp1];
    [mission addWaypoint:wp2];
    [mission addWaypoint:wp3];
    [mission setFinishedAction:DJIWaypointMissionFinishedNoAction]; //Change the default action of Go Home to None
    
    NSLog(@"Timeline, rotate gimbal pitch: %d",[mission rotateGimbalPitch]);
    
    return mission;
}

- (void) letsTrythis {
    WeakSelf(target);
    
    NSLog(@"Is Timeline Running: %d",[[DJISDKManager missionControl] isTimelineRunning]);
    NSLog(@"Is Timeline Paused: %d",[[DJISDKManager missionControl] isTimelinePaused]);
    
    //Clearning the TimeLine. Preparing to reset timeline
    [[DJISDKManager missionControl] pauseTimeline];
    [[DJISDKManager missionControl] stopTimeline];
    [[DJISDKManager missionControl] removeAllListeners];
    [[DJISDKManager missionControl] unscheduleEverything];
    
    
    //Setting up the waypoint mission
    if (CLLocationCoordinate2DIsValid(target.aircraftLocation)) {
        NSLog(@"Timeline: Location is Valid");
    }
    else{
        NSLog(@"Timeline: Location is InValid");
    }
    DJIMission *element = [self initializeMission2];
    NSError *error = [[DJISDKManager missionControl] scheduleElement:element];
    //NSError *error3 = [[DJISDKManager missionControl] scheduleElement:element];
    //NSError *error4 = [[DJISDKManager missionControl] scheduleElement:element];
    if(error == nil){
        NSLog(@"Timeline: No error settiing up waypoint mission");
    }else{
        NSLog(@"Timeline: Error setting up waypoint mission: %@",error);
    }
    NSLog(@"Timeline: Aircraft Altitude: %f", [target aircraftAltitude]);
    
    /*
    //Setting up the trigger
    DJIWaypointReachedMissionTrigger *trigger = [[DJIWaypointReachedMissionTrigger alloc] init];
    [trigger setWaypointIndex:2];
    [trigger setAction:[self printTrigger]];
    [trigger addListener:self toTimelineProgressWithBlock:^(DJIMissionTrigger * _Nonnull trigger, DJIMissionTriggerEvent event, NSError * _Nullable error) {
        if(event == DJIMissionTriggerEventStarted){
            NSLog(@"Timeline: Trigger Event Started");
        }
        if(event == DJIMissionTriggerEventActionTriggered){
            NSLog(@"Timeline: Trigger has been triggered");
            [trigger triggerAction];
            [self printTrigger];
        }
        if(event == DJIMissionTriggerEventStopped){
            NSLog(@"Timeline: Trigger has been stopped");
        }
    }];
    //[trigger notifyListenersOfEvent:DJIMissionTriggerEventStarted error:nil];
    //[trigger notifyListenersOfEvent:DJIMissionTriggerEventActionTriggered error:nil];
    [trigger start];
    NSArray *triggerArray = @[trigger];
    [[DJISDKManager missionControl] scheduleTriggers:triggerArray];
    NSLog(@"Timeline: Number of triggers: %lu",(unsigned long)[[DJISDKManager missionControl] scheduledTriggersCount]);
    */
    
    self.custom = [[MachineLearningAction alloc] initWithNumberOfImages:1];
    NSError *error2 = [[DJISDKManager missionControl] scheduleElement:self.custom];
    NSLog(@"Timeline: Error setting up custom action: %@",error2);
    
    
    //Starting the Timeline
    __block int numEvents = 0;
    [DJISDKManager.missionControl addListener:self toTimelineProgressWithBlock:^(DJIMissionControlTimelineEvent event, id<DJIMissionControlTimelineElement>  _Nullable element, NSError * _Nullable error, id  _Nullable info) {
        if (event == DJIMissionControlTimelineEventStarted){
            NSLog(@"Timeline: Event started");
        }
        if (event == DJIMissionControlTimelineEventFinished){
            NSLog(@"Timeline: Event finished");
            numEvents = numEvents + 1;
            NSLog(@"Number of completed events in timeline: %d", numEvents);
        }
    }];
    [[DJISDKManager missionControl] startTimeline];
    //NSLog(@"Timeline: is trigger active: %d",[trigger isActive]);
    NSLog(@"Is Timeline Running: %d",[[DJISDKManager missionControl] isTimelineRunning]);
    NSLog(@"Is Timeline Paused: %d",[[DJISDKManager missionControl] isTimelinePaused]);
    NSLog(@"Timeline: Timeline is done");
}

- (DJIFlightController*) fetchFlightController {
    if (![DJISDKManager product]) {
        NSLog(@"Product not detected. Can't return flight controller");
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        NSLog(@"Aircraft detected. Return FLight controller");
        return ((DJIAircraft*)[DJISDKManager product]).flightController;
    }
    
    return nil;
}

- (DJIMissionTriggerAction) printTrigger {
    NSLog(@"Timeline: I AM IN THE TRIGGER");
    return nil;
}

- (void) printTrigger2 {
    NSLog(@"Timeline: I AM IN THE TRIGGER");
}

- (DJIMission *) generateHotPointMission {
    DJIHotpointMission *mission = [[DJIHotpointMission alloc] init];
    mission.altitude = 7;
    mission.radius = DJIHotpointMinRadius;
    mission.hotpoint = self.aircraftLocation;
    mission.heading = DJIHotpointHeadingAlongCircleLookingForward;
    mission.startPoint = DJIHotpointStartPointNorth;
    NSError *error = [mission checkParameters];
    if(error == nil){
        NSLog(@"Timeline: No error in setting up hotpoint mission");
    }else{
        NSLog(@"Timeline Error in Hotspot: %@",error);
    }
    return mission;
}

@end
