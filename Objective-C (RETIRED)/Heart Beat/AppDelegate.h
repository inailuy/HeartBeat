//
//  AppDelegate.h
//  Heart Beat
//
//  Created by inailuy on 2/11/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "YZSwipeBetweenViewController.h"
@import HealthKit;

#define MALE 0
#define FEMALE 1

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) YZSwipeBetweenViewController *swipeBetweenVC;
@property (nonatomic) HKHealthStore *healthStore;

@property (strong, nonatomic) NSString *heartBeatString;
@property (nonatomic) int currentHeartBeat;
@property (strong, nonatomic) NSString *peripheralStatusString;

@property (strong, nonatomic) NSMutableArray *peripheralArray;

@property (nonatomic) BOOL isPeripheralConnected;
@property (nonatomic) BOOL isWorkoutActive;


+ (AppDelegate *)instance;

- (void) connectPeripheral;
- (void) disconnectPeripheral;

- (void) refreashLocalParse;
- (void) saveWorkoutToHealthKit:(NSObject *) workoutSummary;

@end

