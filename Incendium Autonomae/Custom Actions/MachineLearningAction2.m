//
//  AircraftAction.m
//  Incendium Autonomae
//
//  Created by Rooshiv Arora on 1/20/21.
//

#import <Foundation/Foundation.h>
#import "MachineLearningAction.h"

@implementation MachineLearningAction

- (instancetype _Nullable)initWithNumberOfImages:(int)numImages{
    self = [super init];
    if (self) {
        _numImages = numImages;
    }
    return self;
}

- (void) willRun{
    if(self.numImages > 0){
        NSLog(@"Object was instantiated correctly. It should run as expected");
    }
}

- (void) run{
    [self printAction];
}

- (void) didRun {
    NSLog(@"Was the Machine Learning Model output and running message printed? If so it ran");
}

- (void) stop{
    //do nothing
}

- (bool) isPausable{
    return false;
}

- (void) printAction {
    NSLog(@"Timeline: I am in the custom aircraft action");
}




@end
