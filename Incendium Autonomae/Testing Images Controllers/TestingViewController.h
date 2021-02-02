//
//  StitchingViewController.h
//  PanoDemo
//
//  Created by DJI on 15/7/30.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIRE_DETECTION2.h"

@interface TestingViewController : UIViewController

@property (strong,nonatomic) NSMutableArray* imageArray;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet FIRE_DETECTION2Input *input;
@property (strong, nonatomic) IBOutlet FIRE_DETECTION2Output *output;
@property (strong, nonatomic) IBOutlet MLModel *model;

@end
