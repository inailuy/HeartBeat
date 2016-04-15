//
//  BaseVC.h
//  Heart Beat
//
//  Created by inailuy on 2/21/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@import HealthKit;

@interface BaseVC : UIViewController

@property (nonatomic) HKHealthStore *healthStore;
@property (nonatomic, strong) NSArray *workoutTypesArray;

- (NSArray *)workoutTypesArraySetup;
- (void) updateWorkoutType;
@end
