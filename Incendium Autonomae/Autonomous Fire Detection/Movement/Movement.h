//
//  movement.h
//  Incendium Autonomae
//
//  Created by Rooshiv Arora on 2/3/21.
//

#ifndef movement_h
#define movement_h


#endif /* movement_h */

#import <MapKit/MapKit.h>

@interface MovementController : NSObject

+(CLLocation *)moveNorth:(int)distance fromLocation:(CLLocationCoordinate2D)CLLocationCoordinate2D;

+(CLLocation *)moveSouth:(int)distance fromLocation:(CLLocationCoordinate2D)location;

+(CLLocation *)moveEast:(int)distance fromLocation:(CLLocationCoordinate2D)location;

+(CLLocation *)moveWest:(int)distance fromLocation:(CLLocationCoordinate2D)location;

+(double)calculateDistanceBetweenPointA:(CLLocationCoordinate2D)PointA andPointB:(CLLocationCoordinate2D)PointB;

@end
