//
//  Waypoint.h
//  Incendium Autonomae
//
//  Created by Rushiv Arora on 12/31/20.
//

#import <UIKit/UIKit.h>
#import "MapController.h"
#import "WaypointConfigViewController.h"

@interface WaypointController : UIViewController

@property (nonatomic, strong) MapController *mapController;
@property (nonatomic, strong) WaypointConfigViewController *waypointConfigVC;

@end

