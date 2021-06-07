//
//  StitchingViewController.mm
//  PanoDemo
//
//  Created by DJI on 15/7/30.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "TestingViewController.h"
#import "FIRE_DETECTION2.h"
#import <CoreML/CoreML.h>
#import <Vision/Vision.h>
#import "FIRE_DETECTION_Big.h"

@implementation TestingViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak TestingViewController *weakSelf = self;
    __weak NSMutableArray *weakImageArray = self.imageArray;
    
    //NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://ca-times.brightspotcdn.com/dims4/default/37810d3/2147483647/strip/true/crop/6048x4024+0+0/resize/1486x989!/quality/90/?url=https%3A%2F%2Fcalifornia-times-brightspot.s3.amazonaws.com%2Fb3%2Fb1%2F07070a4ff33561a9038ce2183020%2Fde46030f6bb74c2284bb9bd316b0b757"]];
    
    UIImage *temp = [weakImageArray objectAtIndex:0];
    //UIImage *temp = [UIImage imageWithData: imageData];
    UIImage *myIcon = [weakSelf imageWithImage:temp scaledToSize:CGSizeMake(512, 256)];
    CGFloat width = myIcon.size.width;
    CGFloat height = myIcon.size.height;
    NSLog(@"Width: %0.2f, Height: %0.2f", width, height);

    
    NSLog(@"About to show downloaded image");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        weakSelf.imageView.image = myIcon;
    });
    NSLog(@"Done showing downloaded image");
    
    NSError *error;
    weakSelf.model = [[[FIRE_DETECTION_Big alloc] init] model];
    weakSelf.input = [[FIRE_DETECTION_BigInput alloc] initWithMy_inputFromCGImage:myIcon.CGImage error:&error];
    //NSLog(@"Input Error Message: %@",error);
    weakSelf.output = ((FIRE_DETECTION_BigOutput *)[weakSelf.model predictionFromFeatures:weakSelf.input error:&error]);
    //NSLog(@"Output Error Message: %@",error);
    if (_output == nil){
        NSLog(@"nil output");
    }
    else{
        NSLog(@"Not nil output");
    }
    NSLog(@"output: %@", _output);
    NSLog(@"model output: %@", [_output featureValueForName:@"my_outputs"]);
    MLMultiArray *arr = [[_output featureValueForName:@"my_outputs"] multiArrayValue];
    Float32 *ptr = (Float32 *)[arr dataPointer];
    NSLog(@"MultiArrayValue output: %@", [[_output featureValueForName:@"my_outputs"] multiArrayValue]);
    NSLog(@"sequence size output  : %0.2f", arr[1,0,0,0,0]);
    NSLog(@"batch size output     : %0.2f", arr[0,1,0,0,0]);
    NSLog(@"fire probability output  : %0.2f", arr[0,0,1,0,0]);
    NSLog(@"smoke probability output : %0.2f", arr[0,0,2,0,0]);
    NSLog(@"spare probability output : %0.2f", arr[0,0,3,0,0]);
    NSLog(@"All probs output : %@", [[_output featureValueForName:@"my_outputs"] multiArrayValue]);
    //NSArray *index = [NSArray arrayWithObjects:[NSNumber numberWithInt:0],[NSNumber numberWithInt:1],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0], nil];
    //NSLog(@"output[index] : %@", [arr objectForKeyedSubscript:index]);
    NSLog(@"output[0] : %@", arr[0]);
    NSLog(@"output[1] : %@", arr[1]);
    NSLog(@"output[2] : %@", arr[2]);
    NSLog(@"output[3] : %@", arr[3]);
    NSLog(@"output[4] : %@", arr[4]);
    NSLog(@"All probs output  shape: %@", [arr shape]);

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
    NSLog(@"I hope this works");
    NSLog(@"Fire Probability output offset: %0.2f",ptr[offset]);
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
    NSLog(@"Smoke Probability output offset: %0.2f",ptr[offset]);
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
    NSLog(@"Spare Probability output offset: %0.2f",ptr[offset]);
    dim1 = 1;
    dim2 = 0;
    dim3 = 0;
    dim4 = 0;
    dim5 = 0;
    offset = 0;
    offset = dim1*arr.strides[0].intValue;
    offset = offset + dim2*arr.strides[1].intValue;
    offset = offset + dim3*arr.strides[2].intValue;
    offset = offset + dim4*arr.strides[3].intValue;
    offset = offset + dim5*arr.strides[4].intValue;
    NSLog(@"Sequence Size output offset: %0.2f",ptr[offset]);
    dim1 = 0;
    dim2 = 1;
    dim3 = 0;
    dim4 = 0;
    dim5 = 0;
    offset = 0;
    offset = dim1*arr.strides[0].intValue;
    offset = offset + dim2*arr.strides[1].intValue;
    offset = offset + dim3*arr.strides[2].intValue;
    offset = offset + dim4*arr.strides[3].intValue;
    offset = offset + dim5*arr.strides[4].intValue;
    NSLog(@"Batch Size output offset: %0.2f",ptr[offset]);
    

    VNCoreMLModel *m;
    VNCoreMLRequest *request;
                
    m = [VNCoreMLModel modelForMLModel: _model error:nil];
    request = [[VNCoreMLRequest alloc] initWithModel: m completionHandler: (VNRequestCompletionHandler) ^(VNRequest *request, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(error){
                NSLog(@"Vision Error: %@", error);
            }
            NSInteger numberOfResults = request.results.count;
            NSLog(@"Number of results log: %ld", (long)numberOfResults);
            NSArray *results = [request.results copy];
            VNClassificationObservation *topResult = ((VNClassificationObservation *)(results[0]));
            NSLog(@"%@",results);
            NSLog(@"%@",topResult);
            //NSString *messageLabel = [NSString stringWithFormat: @"%f: %@", topResult.confidence, topResult.identifier];
            //NSLog(@"%@", messageLabel);

            });
    }];
    
    request.imageCropAndScaleOption = VNImageCropAndScaleOptionCenterCrop;
    CIImage *coreGraphicsImage = [[CIImage alloc] initWithImage:temp];

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCIImage:coreGraphicsImage  options:@{}];
            [handler performRequests:@[request] error:nil];
    });
     
}

#pragma mark Custom Methods
- (void)showAlertViewWithTitle:(NSString *)title withMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
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
