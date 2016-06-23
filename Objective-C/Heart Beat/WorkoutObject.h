//
//  WorkoutObject.h
//  Heart Beat
//
//  Created by inailuy on 3/18/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

#define kWorkOutRecordName @"WorkoutRecord"
#define kWorkOutRecordType @"WorkoutObject"


@interface WorkoutObject : NSObject

@property (nonatomic, strong) NSString *username;
//@property (nonatomic, assign) NSString *objectId;
@property (nonatomic, strong) NSNumber *averageBPM;
@property (nonatomic, strong) NSArray *bpmAverageArray;
@property (nonatomic, strong) NSNumber *caloriesBurned;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *calories;
@property (nonatomic, strong) NSNumber *totalTime;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSString *workoutType;
@property (nonatomic, strong) NSNumber *healthkit;
@property (nonatomic, strong) NSNumber *seconds;
@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic, strong) NSArray *locationHistory;

+(WorkoutObject *)createWorkoutObjectFromRecord:(CKRecord *)record;
-(CKRecord *)createRecordFromWorkoutObject;

-(void) descriptionValue;
@end
