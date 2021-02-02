//
//  DemoUtility.h
//  Incendium Autonomae
//
//  Created by Rooshiv Arora on 1/1/21.
//

#ifndef DemoUtility_h
#define DemoUtility_h

#define WeakRef(__obj) __weak typeof(self) __obj = self
#define WeakReturn(__obj) if(__obj ==nil)return;

#define DEGREE(x) ((x)*180.0/M_PI)
#define RADIAN(x) ((x)*M_PI/180.0)

#endif

#import <Foundation/Foundation.h>

extern void ShowMessage(NSString *title, NSString *message, id target, NSString *cancleBtnTitle);

@class DJIFlightController;

@interface DemoUtility : NSObject

+(DJIFlightController*) fetchFlightController;

@end
