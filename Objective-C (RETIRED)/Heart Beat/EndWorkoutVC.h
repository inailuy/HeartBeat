//
//  EndWorkoutVC.h
//  Heart Beat
//
//  Created by inailuy on 3/6/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "WorkoutObject.h"

@interface EndWorkoutVC : UIViewController

@property (nonatomic, strong)  WorkoutObject *workoutSummary;
@property (nonatomic) MKCoordinateRegion region;
@property (nonatomic, strong) NSString *timeString;

@end
