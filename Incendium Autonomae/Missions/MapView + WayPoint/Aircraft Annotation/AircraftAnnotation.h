//
//  AircraftAnnotation.h
//  Incendium Autonomae
//
//  Created by Rushiv Arora on 1/1/21.
//

#import <MapKit/MapKit.h>
#import "AircraftAnnotationView.h"

@interface AircraftAnnotation : NSObject<MKAnnotation>

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, weak) AircraftAnnotationView* annotationView;

-(id) initWithCoordiante:(CLLocationCoordinate2D)coordinate;

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

-(void) updateHeading:(float)heading;

@end
