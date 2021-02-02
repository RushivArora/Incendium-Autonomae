//
//  MapController.h
//  Incendium Autonomae
//
//  Created by Rooshiv Arora on 12/31/20.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AircraftAnnotation.h"

@interface MapController : NSObject

@property (nonatomic, strong) AircraftAnnotation* aircraftAnnotation;
@property (strong, nonatomic) NSMutableArray *editPoints;

/**
 *  Add Waypoints in Map View
 */
- (void)addPoint:(CGPoint)point withMapView:(MKMapView *)mapView;

/**
 *  Clean All Waypoints in Map View
 */
- (void)cleanAllPointsWithMapView:(MKMapView *)mapView;

/**
 *  Current Edit Points
 *
 *  @return Return an NSArray contains multiple CCLocation objects
 */
- (NSArray *)wayPoints;

/**
 *  Update Aircraft's location in Map View
 */
-(void)updateAircraftLocation:(CLLocationCoordinate2D)location withMapView:(MKMapView *)mapView;

/**
 *  Update Aircraft's heading in Map View
 */
-(void)updateAircraftHeading:(float)heading;

@end
