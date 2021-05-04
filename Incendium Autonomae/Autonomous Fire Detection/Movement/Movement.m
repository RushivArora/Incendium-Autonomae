//
//  movement.m
//  Incendium Autonomae
//
//  Created by Rooshiv Arora on 2/3/21.
//

#import <Foundation/Foundation.h>
#import "Movement.h"

@implementation MovementController

//Converts Distance in meters to geographical degrees
+ (double)distanceToLatitudeDisplacement:(int)distance
{
    double R = 6378137;
    double displacement_degrees = ((double)distance/(double)R);
    return displacement_degrees;
}

//Converts Distance in meters to geographical degrees
+ (double)distanceToLongitudeDisplacement:(int)distance withLatitude:(double)latitude
{
    double R = 6378137;
    double displacement_degrees = ((double)distance/((double)R*cos(M_PI*latitude/180)));
    return displacement_degrees;
}

+(CLLocation *)moveNorth:(int)distance fromLocation:(CLLocationCoordinate2D)location
{
    NSLog(@"Moving North");
    double degree_displacement = [self distanceToLatitudeDisplacement:distance];
    double newLatitude = location.latitude + degree_displacement*(180/M_PI);
    CLLocation *newPoint = [[CLLocation alloc] initWithLatitude:newLatitude longitude:location.longitude];
    return newPoint;
}

+ (CLLocation *)moveSouth:(int)distance fromLocation:(CLLocationCoordinate2D)location
{
    NSLog(@"Moving South");
    double degree_displacement = [self distanceToLatitudeDisplacement:distance];
    double newLatitude = location.latitude - degree_displacement*(180/M_PI);
    CLLocation *newPoint = [[CLLocation alloc] initWithLatitude:newLatitude longitude:location.longitude];
    return newPoint;
}

+ (CLLocation *)moveEast:(int)distance fromLocation:(CLLocationCoordinate2D)location
{
    NSLog(@"Moving East");
    double degree_displacement = [self distanceToLongitudeDisplacement:distance withLatitude:location.latitude];
    double newLongitude = location.longitude + degree_displacement*(180/M_PI);
    CLLocation *newPoint = [[CLLocation alloc] initWithLatitude:location.latitude longitude:newLongitude];
    return newPoint;
}

+ (CLLocation *)moveWest:(int)distance fromLocation:(CLLocationCoordinate2D)location
{
    NSLog(@"Moving West");
    double degree_displacement = [self distanceToLongitudeDisplacement:distance withLatitude:location.latitude];
    double newLongitude = location.longitude - degree_displacement*(180/M_PI);
    CLLocation *newPoint = [[CLLocation alloc] initWithLatitude:location.latitude longitude:newLongitude];
    return newPoint;
}

//https://www.movable-type.co.uk/scripts/latlong.html
+(double)calculateDistanceBetweenPointA:(CLLocationCoordinate2D)PointA andPointB:(CLLocationCoordinate2D)PointB
{
    NSLog(@"Calculating distance between points");
    double R = 6378137; // metres
    double phi1 = PointA.latitude*M_PI/180; //degrees to radians
    double phi2 = PointB.latitude*M_PI/180;
    double delta_lat = (PointB.latitude - PointA.latitude)*M_PI/180;
    double delta_long = (PointB.longitude - PointA.longitude)*M_PI/180;
    double a = sin(delta_lat/2)*sin(delta_lat/2) + cos(phi1)*cos(phi2)*sin(delta_long/2)*sin(delta_long/2);
    double c = 2*atan2(sqrt(a), sqrt(1-a));
    NSLog(@"C value is: %0.05f",c);
    double distance = R*c; //Distance in metres
    return distance;
}

@end
