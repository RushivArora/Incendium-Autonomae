//
//  Autonomous_Utility.m
//  Incendium Autonomae
//
//  Created by Rooshiv Arora on 2/3/21.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJISDK.h>
#import "Autonomous_Utiliy.h"
#import "Movement.h"

@implementation AutonomousController

-(instancetype) initWithBoundary:(NSArray *)boundary
{
    self = [super init];
    if (self) {
        _boundary = boundary;
        _path = nil;
        _error_margin = 0.90;
        _height = 5;
    }
    return self;
}

- (void)setBoundary:(NSArray *)boundary
{
    _boundary = boundary;
}

- (void)setHeight:(int) height
{
    _height = height;
}

//Using this table for conversion: http://vrguy.blogspot.com/2013/04/converting-diagonal-field-of-view-and.html
- (double) areaCoverage: (int) code
{
    double DiagFOV = 83;
    double assumed_DiagFOV = 80;
    double HorFOV = 67.7;
    double VertFOV = 53.4;
    //This is FOV is measured across the diagonal
    double diagonal = 2*(self.height*tan((assumed_DiagFOV/2) *M_PI/180));
    double Horizontal = 2*(self.height*tan((HorFOV/2)*M_PI/180));
    double Vertical = 2*(self.height*tan((VertFOV/2)* M_PI/180));
    if(code == 0){
        return Horizontal;
    }
    else{
        return Vertical;
    }
}

- (double) VerticalDistancePerMovement:(CLLocationCoordinate2D)PointA and:(CLLocationCoordinate2D)PointB
{
    WeakRef(target);
    double dist = [MovementController calculateDistanceBetweenPointA:PointA andPointB:PointB];
    double verticalMovement = [target areaCoverage:0];
    double distancePerMovement = self.error_margin*verticalMovement;
    return dist/distancePerMovement;
}

- (double) HorizontalDistancePerMovement:(CLLocationCoordinate2D)PointA and:(CLLocationCoordinate2D)PointB
{
    WeakRef(target);
    double dist = [MovementController calculateDistanceBetweenPointA:PointA andPointB:PointB];
    NSLog(@"Horizontal Dist: %0.02f", dist);
    double horizontalMovement = [target areaCoverage:1];
    double distancePerMovement = self.error_margin*horizontalMovement;
    return dist/distancePerMovement;
}


-(NSArray *)getPath
{
    WeakRef(target);
    self.path = [target generatePath];
    NSLog(@"Returning Path");
    NSLog(@"Timeline: Height of the Path Generation is %0.02f", self.height);
    return self.path;
}

-(NSArray *)generatePath
{
    WeakRef(target);
    NSMutableArray<CLLocation *> *currPath = [[NSMutableArray alloc] init];
    [currPath addObject:target.boundary[0]];
    NSArray<CLLocation *> *localBoundary = target.boundary;
    NSLog(@"generating path");
    double numVerticalMovements = [target VerticalDistancePerMovement:localBoundary[0].coordinate and:localBoundary[1].coordinate];
    double numHorizontalMovements = [target HorizontalDistancePerMovement:localBoundary[0].coordinate and:localBoundary[3].coordinate];
    double verticalDistance = [target areaCoverage:0];
    double horizontalDistance = [target areaCoverage:1];
    NSLog(@"Vertical Distance is: %0.02f", verticalDistance);
    NSLog(@"Horiztonal Distance is: %0.02f", horizontalDistance);
    NSLog(@"Number of Vertical Movement is : %0.02f", numVerticalMovements);
    NSLog(@"Number of Horizontal Movement is : %0.02f", numHorizontalMovements);
    

    int count = 0; //counter of number of points
    for(int i = 0; i < numHorizontalMovements + 1; i++){
        for(int j = 0; j < numVerticalMovements + 1; j++){
            CLLocation *temp = [[CLLocation alloc] init];
            temp = [MovementController moveNorth:verticalDistance fromLocation:currPath[count].coordinate];
            count ++;
            [currPath addObject:temp];
        }
        CLLocation *temp = [[CLLocation alloc] init];
        temp = [MovementController moveEast:horizontalDistance fromLocation:currPath[count - (int)numVerticalMovements - 1 - 1].coordinate];
        count ++;
        [currPath addObject:temp];
    }
    count ++;

    NSLog(@"Path Generated has %d points", currPath.count);
    return currPath;
}



@end
