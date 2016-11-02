//
//  WorkoutObject.m
//  Heart Beat
//
//  Created by inailuy on 3/18/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import "WorkoutObject.h"

@implementation WorkoutObject

+(WorkoutObject *)createWorkoutObjectFromRecord:(CKRecord *)record{
    WorkoutObject *object = [[WorkoutObject alloc] init];
    
    object.username = record[@"username"];
    object.averageBPM = record[@"averageBPM"];
    object.bpmAverageArray = record[@"bpmAverageArray"];
    object.caloriesBurned = record[@"caloriesBurned"];
    object.createdAt = record[@"createdAt"];
    object.updatedAt = record[@"updatedAt"];
    object.date = record[@"date"];
    object.calories = record[@"calories"];
    object.totalTime = record[@"totalTime"];
    object.endDate = record[@"endDate"];
    object.workoutType = record[@"workoutType"];
    object.healthkit = record[@"healthkit"];
    object.seconds = record[@"seconds"];
    object.distance = record[@"distance"];
    object.locationHistory = record[@"locationHistory"];
    
    return object;
}

-(CKRecord *)createRecordFromWorkoutObject{
    CKRecord *record = [[CKRecord alloc] initWithRecordType:kWorkOutRecordName];
   
    record[@"averageBPM"] = self.averageBPM;
    record[@"bpmAverageArray"] = self.bpmAverageArray;
    record[@"calories"] = self.calories;
    record[@"caloriesBurned"] = self.caloriesBurned;
    record[@"createdAt"] = self.createdAt;
    record[@"date"] = self.date;
    record[@"distance"] = self.distance;
    record[@"endDate"] = self.endDate;
    record[@"healthkit"] = self.healthkit;
    record[@"locationHistory"] = self.locationHistory;
    record[@"seconds"] = self.seconds;
    record[@"totalTime"] = self.totalTime;
    record[@"username"] = self.username;
    record[@"updatedAt"] = self.updatedAt;
    record[@"workoutType"] = self.workoutType;

    return record;
}

-(void)descriptionValue{
    NSLog(@"WorkoutObject %@\n", self);
    NSLog(@"averageBPM %f ", self.averageBPM.floatValue);
    NSLog(@"bpmAverageArray %@ ", self.bpmAverageArray);
    NSLog(@"caloriesBurned %@ ", self.caloriesBurned);
    NSLog(@"createdAt %@ ", self.createdAt);
    NSLog(@"updatedAt %@ ", self.updatedAt);
    NSLog(@"date %@ ", self.date);
    NSLog(@"calories %@ ", self.calories);
    NSLog(@"totalTime %@ ", self.totalTime);
    NSLog(@"endDate %@ ", self.endDate);
    NSLog(@"workoutType %@ ", self.workoutType);
    NSLog(@"healthkit %@ ", self.healthkit);
    NSLog(@"seconds %@ ", self.seconds);
    NSLog(@"distance %@ ", self.distance);
    NSLog(@"locationHistory %@ ", self.locationHistory);
}

@end
