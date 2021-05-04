//
//  Autonomous_Utiliy.h
//  Incendium Autonomae
//
//  Created by Rooshiv Arora on 2/3/21.
//

#ifndef Autonomous_Utiliy_h
#define Autonomous_Utiliy_h

#define WeakRef(__obj) __weak typeof(self) __obj = self
#define WeakReturn(__obj) if(__obj ==nil)return;

#endif /* Autonomous_Utiliy_h */

#import <Foundation/Foundation.h>

@interface AutonomousController : NSObject

@property (strong, nonatomic) NSArray *boundary;
@property (strong, nonatomic) NSMutableArray *path;
@property (atomic) double error_margin;
@property(nonatomic, readwrite) double height;

-(instancetype) initWithBoundary:(NSArray *)boundary;

-(void)setBoundary:(NSArray *)boundary;

-(void)setHeight:(int) height;

/**
 *  Current  Path Points
 *
 *  @return Return an NSArray contains multiple CCLocation objects
 */
- (NSArray *)getPath;

@end
