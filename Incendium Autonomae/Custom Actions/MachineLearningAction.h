//
//  MachineLearningAction.h
//  Incendium Autonomae
//
//  Created by Rooshiv Arora on 1/20/21.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIMissionAction.h>
#import <DJISDK/DJISDK.h>
#import "FIRE_DETECTION2.h"
#import "FIRE_DETECTION3.h"

NS_ASSUME_NONNULL_BEGIN


/**
 *  The error domain used to describe errors produced by the `AircraftAction`
 *  object.
 */
extern const NSErrorDomain DJIAircraftYawActionErrorDomain;


/**
 *  Error codes for errors specific to `DJIAircraftYawActionErrorDomain`.
 */
typedef NS_ENUM(NSInteger, AircraftActionError) {

    /**
     *  Default value when no other value is appropriate.
     */
    AircraftActionErrorUnknown = -1,
    

    /**
     *  Set rotation speed is not within valid range [0, 100].
     */
    DJIAircraftYawActionErrorInvalidImage = 100,
    

    /**
     *  Set angle value is not within valid range [-180, 180].
     */
    DJIAircraftYawActionErrorDownloadFailed = 101,
};


/**
 *  This class represents an aircraft yaw rotation action to be scheduled on the
 *  Mission  Control timeline. By creating an object of this class and adding it to
 *  the timeline,  an aircraft will rotate around yaw by the specified angle with
 *  the specified speed  when the Timeline reaches the action.
 */
@interface MachineLearningAction : DJIMissionAction

@property(nonatomic, readonly) int numImages;
@property(nonatomic, readwrite) int label;
@property (strong,nonatomic) NSMutableArray * imageArray;
@property (strong, nonatomic) IBOutlet FIRE_DETECTION3Input *input;
@property (strong, nonatomic) IBOutlet FIRE_DETECTION3Output *output;
@property (strong, nonatomic) IBOutlet MLModel *model;

/**
 *  Initialize with a yaw angle relative to current heading and an angular velocity.
 *  The angular velocity has a range of [0, 100] degrees/s and a default value of 20
 *  degrees/s.
 *
 *  @param numImages The number of images to run the ML model on
 */
- (instancetype _Nullable)initWithNumberOfImages:(int)numImages;

@end

NS_ASSUME_NONNULL_END
