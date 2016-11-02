//
//  AppDelegate.m
//  Heart Beat
//
//  Created by inailuy on 2/11/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Bolts/Bolts.h>
#import <AVFoundation/AVFoundation.h>
#import "notify.h"
#import "NSTimer+Pause.h"
#import "HistoryVC.h"
#import "MainVC.h"
#import "SettingVC.h"
#import "WorkoutObject.h"
#import "CloudManager.h"
//#import <ParseTwitterUtils/ParseTwitterUtils.h>

#define HEART_RATE_SERVICE @"180D"
#define HEART_RATE_MEASUREMENT @"2A37"

#define POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID @"2A37"
#define POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID @"2A38"
#define POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID @"2A29"

#define INDEX_MAX 58

struct hrflags
{
    uint8_t _hr_format_bit:1;
    uint8_t _sensor_contact_bit:2;
    uint8_t _energy_expended_bit:1;
    uint8_t _rr_interval_bit:1;
    uint8_t _reserved:3;
};

@interface AppDelegate ()<CBCentralManagerDelegate, CBPeripheralDelegate, CloudManagerDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *activePeripheral;
@property (nonatomic) BOOL isFirstLaunch;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //test 4
    
    // Override point for customization after application launch.
    self.healthStore = [[HKHealthStore alloc] init];
    [self askPermissionForHealth];
//    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
//        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
//    }
    
    
    /*
    [ParseCrashReporting enable];
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"El3gM5720hErQgk6RYYTuFWEnuVKHlaKIvUt3IZK"
                  clientKey:@"Ts8f7Ky3Moheam6m0BHSgqs7emWDoOCtEIzZvbdU"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    */
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
       // [PFFacebookUtils initializeFacebook];
       /* [PFTwitterUtils initializeWithConsumerKey:@"rJBmCmcVldebgVvc4IKiVvTmP"
                                   consumerSecret:@"JYUCTKufdW2PebY71D7bHzOerg6rArAewwc5JdxZylL7l98RUH"];*/
    });
    //[FBAppEvents activateApp];
    self.heartBeatString = @"0 bpm";
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                               queue:nil
                                                             options:nil];
    CBUUID *myServiceUUID = [CBUUID UUIDWithString:HEART_RATE_SERVICE];
    [self.centralManager scanForPeripheralsWithServices:@[myServiceUUID] options:nil];
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"age"] &&
        ![[NSUserDefaults standardUserDefaults] valueForKey:@"weight"] &&
        ![[NSUserDefaults standardUserDefaults] valueForKey:@"sex"]){
        [[NSUserDefaults standardUserDefaults] setValue:@0 forKey:@"firstTimeUse"];
        [[NSUserDefaults standardUserDefaults] setValue:@0 forKey:@"weight"];
        [[NSUserDefaults standardUserDefaults] setValue:@0 forKey:@"sex"];
        [[NSUserDefaults standardUserDefaults] setValue:@0 forKey:@"speechUtterance"];
        [[NSUserDefaults standardUserDefaults] setObject:@[@NO, @NO, @NO, @NO] forKey:@"cuesArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //[PFUser enableAutomaticUser];
    [self refreashLocalParse];
    
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                     withOptions:AVAudioSessionCategoryOptionDuckOthers
                                           error:nil];

    self.swipeBetweenVC = [YZSwipeBetweenViewController new];
    self.swipeBetweenVC.initialViewControllerIndex = 1;
    self.swipeBetweenVC.scrollView.alwaysBounceVertical = NO;
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    HistoryVC *vc1 = [storyboard instantiateViewControllerWithIdentifier:@"historyID"];
    UINavigationController *navCon1 =
    [[UINavigationController alloc]initWithRootViewController:vc1];
    
    MainVC *vc2 = [storyboard instantiateViewControllerWithIdentifier:@"mainID"];
    UINavigationController *navCon2 =
    [[UINavigationController alloc] initWithRootViewController:vc2];
    [[navCon2 navigationBar] setTranslucent:YES];
    
    SettingVC *vc3 = [storyboard instantiateViewControllerWithIdentifier:@"settingsID"];
    UINavigationController *navCon3 =
    [[UINavigationController alloc] initWithRootViewController:vc3];
    
    self.swipeBetweenVC.viewControllers = @[navCon1, navCon2, navCon3];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    [self.window setRootViewController:self.swipeBetweenVC];
    [self.window makeKeyAndVisible];
    
    _isFirstLaunch = YES;
    NSDictionary *barButtonAppearanceDict = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
    
    [[UINavigationBar appearance]setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                        [UIFont fontWithName:@"HelveticaNeue-Light" size:24],
                                                         NSFontAttributeName, nil]];
    
    //cloudKit tests
    //CloudManager *manager = [CloudManager sharedManager];
    //CKRecord *record = [manager createRandomRecord];
    //[manager saveRecordToPublic:record];
    //[manager saveRecordToPrivate:record];
    //[manager fetchAllFromPrivateCloudwithRecordType:kWorkOutRecordType];
    //manager.delegate = self;
    
    return YES;
}

-(void)finishedFetchingItems:(NSArray *)results fromQuery:(CKQuery *)query{
    NSLog(@"query %@ results %lu", query, (unsigned long)results.count);
}

- (void)interruption
{
    NSLog(@"interruption");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //[FBSDKAppEvents activateApp];
    //[FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    /*
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:02.0
                                                      target:self
                                                    selector:@selector(enableLocalNotifications)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    */
    
    if (!self.isWorkoutActive){
        [self disconnectPeripheral];
    }
    
}

- (void) refreashLocalParse {

}

- (void) refreashLocalParseWith {
   
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler {
    
    // Handle actions of location notifications here. You can identify the action by using "identifier" and perform appropriate operations
    
    if ([identifier isEqualToString:@"End Workout"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"End Workout"
                                                            object:nil];
    }else if ([identifier isEqualToString:@"Pause Workout"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pause Workout"
                                                            object:nil];
    }
    
    if(completionHandler != nil)    //Finally call completion handler if its not nil
        completionHandler();
}

- (void) enableLocalNotifications{
    /*
    int notify_token;
    
    notify_register_dispatch("com.apple.springboard.lockstate", &notify_token,dispatch_get_main_queue(), ^(int token) {
        uint64_t state = UINT64_MAX;
        notify_get_state(token, &state);
        
        if(state == 0) {
            NSLog(@"unlock device");
            if (!self.timer) {
                self.timer = [NSTimer scheduledTimerWithTimeInterval:01.0
                                                              target:self
                                                            selector:@selector(enableLocalNotifications)
                                                            userInfo:nil
                                                             repeats:YES];
            }
            [self.timer resume];
            
        } else {
            if (self.timer && self.isWorkoutActive) {
                [self.timer invalidate];
                self.timer = nil;
                
//                UIMutableUserNotificationAction *notificationAction1 = [[UIMutableUserNotificationAction alloc] init];
//                notificationAction1.identifier = @"Accept";
//                notificationAction1.title = @"pause";
//                notificationAction1.activationMode = UIUserNotificationActivationModeBackground;
//                notificationAction1.destructive = NO;
//                notificationAction1.authenticationRequired = NO;
                
                UIMutableUserNotificationAction *notificationEndAction = [[UIMutableUserNotificationAction alloc] init];
                notificationEndAction.identifier = @"End Workout";
                notificationEndAction.title = @"end";
                notificationEndAction.activationMode = UIUserNotificationActivationModeForeground;
                notificationEndAction.destructive = YES;
                notificationEndAction.authenticationRequired = YES;
                
                UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc] init];
                notificationCategory.identifier = @"notification action";
                [notificationCategory setActions:@[notificationEndAction] forContext:UIUserNotificationActionContextDefault];
                [notificationCategory setActions:@[notificationEndAction] forContext:UIUserNotificationActionContextMinimal];
                
                NSSet *categories = [NSSet setWithObjects:notificationCategory, nil];
                
                UIUserNotificationType notificationType = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
                UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationType categories:categories];
                
                [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];

                
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.alertBody = @"Active Workout";
                notification.category = @"notification action";
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            }
        }
    });
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (!self.isWorkoutActive){
        [self connectPeripheral];
    }
    CloudManager *manager = [CloudManager sharedManagerWithDelegate:nil];
    [manager fetchAllFromPrivateCloudwithRecordType:kWorkOutRecordName];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

+ (AppDelegate *)instance
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

#pragma mark - CBCentralManagerDelegate -

-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    self.peripheralStatusString = [NSString stringWithFormat:@"centralManagerDidUpdateState %li", (long)central.state];
    if (central.state == 5){
        self.peripheralStatusString = @"Scanning For Peripherals";
        CBUUID *myServiceUUID = [CBUUID UUIDWithString:HEART_RATE_SERVICE];
        [self.centralManager scanForPeripheralsWithServices:@[myServiceUUID] options:nil];
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
    advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    self.peripheralStatusString = @"Did Discorver Peripheral";
    self.activePeripheral = peripheral;
    [self.peripheralArray addObject:peripheral];
    peripheral.delegate = self;
    
    if (self.isWorkoutActive || self.isFirstLaunch){
        [self.centralManager connectPeripheral:self.activePeripheral options:nil];
        self.isFirstLaunch = NO;
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    self.peripheralStatusString = @"Did Connect Peripheral";
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.peripheralStatusString = @"Did Disconnect Peripheral";
}

#pragma mark - CBPeripheralDelegate -

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        NSLog(@"Error discovering service: %@", [error localizedDescription]);
        return;
    }
    for (CBService *service in peripheral.services) {
        if  ([service.UUID isEqual:[CBUUID UUIDWithString:HEART_RATE_SERVICE]]){
            self.peripheralStatusString = @"Did Discover Service";
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering service: %@", [error localizedDescription]);
        return;
    }
    if([service.UUID isEqual:[CBUUID UUIDWithString:HEART_RATE_SERVICE]]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HEART_RATE_MEASUREMENT]]) {
                self.peripheralStatusString = @"Did Discover Characteristic For Service";
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering service: %@", [error localizedDescription]);
        return;
    }
    // Updated value for heart rate measurement received
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID]]) {
        // Get the Heart Rate Monitor BPM
        [self getHeartBPMData:characteristic error:error];
    }
}

- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error {
    // Get the Heart Rate Monitor BPM
    NSData *data = [characteristic value];      // 1
    const uint8_t *reportData = [data bytes];
    uint16_t bpm = 0;
    
    if ((reportData[0] & 0x01) == 0) {          // 2
        // Retrieve the BPM value for the Heart Rate Monitor
        bpm = reportData[1];
    }
    else {
        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));  // 3
    }
    // Display the heart rate value to the UI if no error occurred
    if( (characteristic.value)  || !error ) {   // 4
        self.peripheralStatusString = @"";
        self.heartBeatString = [NSString stringWithFormat:@"%i bpm", bpm];
        self.currentHeartBeat = bpm;
    }
    return;
}

- (void) connectPeripheral {
    if (self.activePeripheral){
        [self.centralManager connectPeripheral:self.activePeripheral options:nil];
    }
}

- (void) disconnectPeripheral {
    if (self.activePeripheral){
        [self.centralManager cancelPeripheralConnection:self.activePeripheral];
    }
}

- (BOOL) isPeripheralConnected
{
    BOOL connected = NO;
    if (self.activePeripheral.state == CBPeripheralStateConnected){
        connected = YES;
    }
    return connected;
}

#pragma mark - HealthKit -

- (void) askPermissionForHealth{
    if ([HKHealthStore isHealthDataAvailable]) {
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesToRead];
        
        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                
                return;
            }
        }];
    }
}

-(void) saveWorkoutToHealthKit:(WorkoutObject *) workoutSummary{
    NSNumber *isHealthEnabled = [[NSUserDefaults standardUserDefaults] valueForKey:@"isHealthKitEnabled"];
    //NSNumber *workoutSaved = workoutSummary[@"healthkit"];
    NSNumber *workoutSaved = workoutSummary.healthkit;
    
    if (!workoutSaved.boolValue && isHealthEnabled.boolValue){
        NSLog(@"%i, %i", workoutSaved.boolValue, isHealthEnabled.boolValue);
        workoutSummary.healthkit = @YES;
        //[workoutSummary setObject:[NSNumber numberWithBool:YES] forKey:@"healthkit"];
        //[workoutSummary saveEventually];
        
        //double seconds = ((NSNumber *)workoutSummary[@"seconds"]).doubleValue;
        //double calories = ((NSNumber *)workoutSummary[@"calories"]).doubleValue;
        double seconds = workoutSummary.seconds.doubleValue;
        double calories = workoutSummary.calories.doubleValue;
        
        calories = calories == 0 ? [self calculateVo2maxCaloriesBurned:workoutSummary] : calories; // check if 0
        //double bpm = ((NSNumber *)workoutSummary[@"averageBPM"]).doubleValue;
        //NSDate *end = workoutSummary[@"endDate"];
        NSDate *end = workoutSummary.endDate;
        NSDate *start = [end dateByAddingTimeInterval:-seconds];
        NSDictionary *metadata = @{HKMetadataKeyIndoorWorkout: @(NO)};
        //NSString *workoutType = workoutSummary[@"workoutType"];
        NSString *workoutType = workoutSummary.workoutType;
        NSUInteger index = [[self workoutTypesArraySetup] indexOfObject:workoutType];
        //double distance = ((NSNumber *)workoutSummary[@"distance"]).doubleValue;
        double distance = workoutSummary.distance.doubleValue;
        
        // array instances for healthkit
        HKQuantitySample *energyBurnedSample = nil;
        //HKQuantitySample *heartRateSample = nil;
        HKWorkout *workout = nil;
        HKQuantitySample *distanceSample = nil;
        NSMutableArray *saveObjects = [NSMutableArray array];
        
        // Calories
        HKQuantityType *energyBurnedType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
        HKQuantity *energyBurnedQuantity = [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit]
                                                            doubleValue:calories];
        energyBurnedSample = [HKQuantitySample quantitySampleWithType:energyBurnedType
                                                                               quantity:energyBurnedQuantity
                                                                              startDate:start
                                                                                endDate:end];
        
        // Heart beat
        /*
        HKQuantityType *rateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
        HKUnit *heartBeatsPerMinuteUnit = [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
        HKQuantity *rateQuantity = [HKQuantity quantityWithUnit:heartBeatsPerMinuteUnit
                                                    doubleValue:bpm];
        heartRateSample = [HKQuantitySample quantitySampleWithType:rateType
                                                                           quantity:rateQuantity
                                                                          startDate:start
                                                                            endDate:end];
         */
        
        // Run or Walk
        if (index == HKWorkoutActivityTypeWalking || index == HKWorkoutActivityTypeRunning ||
            index ==  HKWorkoutActivityTypeHiking ||index ==  HKWorkoutActivityTypeCycling){
            HKQuantityType *distanceType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
            HKUnit *distanceUnit = [HKUnit meterUnit];
            HKQuantity *distanceQuantity = [HKQuantity quantityWithUnit:distanceUnit
                                                            doubleValue:distance];
            distanceSample = [HKQuantitySample quantitySampleWithType:distanceType
                                                             quantity:distanceQuantity
                                                            startDate:start
                                                              endDate:end];
            [saveObjects addObject:distanceSample];
        }
        
        // Workout
        index = (index == HKWorkoutActivityTypeYoga + 1) ? HKWorkoutActivityTypeRunning : index;
        workout = [HKWorkout workoutWithActivityType:index
                                           startDate:start
                                             endDate:end
                                            duration:seconds
                                   totalEnergyBurned:energyBurnedQuantity
                                       totalDistance:nil
                                            metadata:metadata];
        
        // adding objects to save into healthkit
        [saveObjects addObjectsFromArray:@[workout, energyBurnedSample]];
        if (index > 0 && index < INDEX_MAX){
//            [self.healthStore saveObjects:saveObjects
//                           withCompletion:^(BOOL success, NSError *error) {
//                 // Perform proper error handling here...
//                 /*
//                  [workoutSummary setObject:[NSNumber numberWithBool:success] forKey:@"healthkit"];
//                  [workoutSummary saveEventually];
//                  if (!success){
//                  NSLog(@"*** An error occurred while saving this "
//                  @"workout: %@ ***", error.localizedDescription);
//                  }else{
//                  NSLog(@"healthkit was .. %i workout %@", success, workoutSummary[@"workoutType"]);
//                  }
//                  */
//             }];
        }
        
    }
}

// Returns the types of data that App wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite {
//    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    //HKQuantityType *distanceCyclingType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
    HKQuantityType *walkingRunningType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    //HKQuantityType *heartRateType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKObjectType *workoutType = [HKObjectType workoutType];
    
    return [NSSet setWithObjects:activeEnergyBurnType, workoutType, walkingRunningType, nil];
}

// Returns the types of data that App wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKCharacteristicType *biologicalSexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    
    return [NSSet setWithObjects:weightType, birthdayType, biologicalSexType, nil];
}

- (int) calculateVo2maxCaloriesBurned:(WorkoutObject *)workoutSummary {
    NSNumber *ageNum = [[NSUserDefaults standardUserDefaults] valueForKey:@"age"];
    NSNumber *wieghtNum = [[NSUserDefaults standardUserDefaults] valueForKey:@"wieght"];
    NSNumber *sex = [[NSUserDefaults standardUserDefaults] valueForKey:@"sex"];
    float caloriesBurned = 0;
    float age = ageNum.floatValue;
    //float VO2MAX = 15 * ((208 - 0.7 * age)/65);
    float weight = wieghtNum.floatValue;
    //float minutes = ((NSNumber *)workoutSummary[@"totalTime"]).floatValue;
    float minutes = workoutSummary.totalTime.floatValue;
    //float bpm = ((NSNumber *)workoutSummary[@"averageBPM"]).floatValue;
    float bpm = workoutSummary.averageBPM.floatValue;
    if (sex.boolValue == MALE){
        //caloriesBurned = ((-59.3954 + (-36.3781 + 0.271 * age + 0.394 * weight + 0.404 * VO2MAX + 0.634 * bpm))/4.184)* minutes;// V02 max
        caloriesBurned = ((age * 0.2017) + (weight * 0.1988)+ (bpm * 0.6309) - 55.0969) * minutes / 4.184;
    }else if (sex.boolValue == FEMALE){
        //caloriesBurned = ((-20.4022 + 0.4472 * bpm + 0.1263 * weight + 0.074 * age) / 4.184) * minutes;// V02 max
        caloriesBurned = ( (age * 0.074) + (weight * 0.1263) + (bpm * 0.4472) - 20.4022) * minutes / 4.184;
    }
    return (int)caloriesBurned;
}

- (NSArray *)workoutTypesArraySetup{
    NSString * const kWorkout = @"workout type";
    NSString * const kWorkoutAmericaFootbal = @"american footbal";
    NSString * const kWorkoutArchery = @"archery";
    NSString * const kWorkoutAustralianFootball = @"australian football";
    NSString * const kWorkoutBadminton = @"badminton";
    NSString * const kWorkoutBaseball = @"baseball";
    NSString * const kWorkoutBasketball = @"basketball";
    NSString * const kWorkoutBowling = @"bowling";
    NSString * const kWorkoutBoxing = @"boxing";
    NSString * const kWorkoutClimbing = @"climbing";
    NSString * const kWorkoutCricket = @"cricket";
    NSString * const kWorkoutCrossTraining = @"cross training";
    NSString * const kWorkoutCurling = @"curling";
    NSString * const kWorkoutCycling = @"cycling";
    NSString * const kWorkoutDance = @"dance";
    NSString * const kWorkoutDanceInspiredTraining = @"inspired dancing";
    NSString * const kWorkoutElliptical = @"elliptical";
    NSString * const kWorkoutEquestrianSports = @"polo";
    NSString * const kWorkoutFencing = @"fencing";
    NSString * const kWorkoutFishing = @"fishing";
    NSString * const kWorkoutFunctionalStrengthTraining = @"calisthenics";
    NSString * const kWorkoutGolf = @"golf";
    NSString * const kWorkoutGymnastics = @"gymnastics";
    NSString * const kWorkoutHandball = @"handball";
    NSString * const kWorkoutHiking = @"hiking";
    NSString * const kWorkoutHockey = @"hockey";
    NSString * const kWorkoutHunting = @"hunting";
    NSString * const kWorkoutLacrosse = @"lacrosse";
    NSString * const kWorkoutMartialArts = @"martial arts";
    NSString * const kWorkoutMindAndBody = @"meditation";
    NSString * const kWorkoutMixedMetabolicCardioTraining = @"cardio exercises";
    NSString * const kWorkoutPaddleSports = @"canoeing";
    NSString * const kWorkoutPlay = @"dodge ball, tetherball";
    NSString * const kWorkoutPreparationAndRecovery = @"stretching";
    NSString * const kWorkoutRacquetball = @"racquetball";
    NSString * const kWorkoutRowing = @"rowing";
    NSString * const kWorkoutRugby = @"rugby";
    NSString * const kWorkoutRunning = @"running";
    NSString * const kWorkoutSailing = @"sailing";
    NSString * const kWorkoutSkatingSports = @"skating";
    NSString * const kWorkoutSnowSports = @"snow sports";
    NSString * const kWorkoutSoccer = @"soccer";
    NSString * const kWorkoutSoftball = @"Softball";
    NSString * const kWorkoutSquash = @"squash";
    NSString * const kWorkoutStairClimbing = @"stair climbing";
    NSString * const kWorkoutSurfingSports = @"surfing";
    NSString * const kWorkoutSwimming = @"swimming";
    NSString * const kWorkoutTableTennis = @"table tennis";
    NSString * const kWorkoutTennis = @"tennis";
    NSString * const kWorkoutTrackAndField = @"track & field";
    NSString * const kWorkoutTraditionalStrengthTraining = @"strength training";
    NSString * const kWorkoutVolleyball = @"volleyball";
    NSString * const kWorkoutWalking = @"walking";
    NSString * const kWorkoutWaterFitness = @"water fitness";
    NSString * const kWorkoutWaterPolo = @"waterpolo";
    NSString * const kWorkoutWaterSports = @"water Skiing";
    NSString * const kWorkoutWrestling = @"wrestling";
    NSString * const kWorkoutYoga = @"yoga";
    NSString * const kWorkoutTreadmill = @"treadmill";
    
    NSArray *array = @[kWorkout, kWorkoutAmericaFootbal, kWorkoutArchery, kWorkoutAustralianFootball, kWorkoutBadminton, kWorkoutBaseball, kWorkoutBasketball, kWorkoutBowling, kWorkoutBoxing, kWorkoutClimbing, kWorkoutCricket, kWorkoutCrossTraining, kWorkoutCurling, kWorkoutCycling, kWorkoutDance, kWorkoutDanceInspiredTraining, kWorkoutElliptical, kWorkoutEquestrianSports, kWorkoutFencing, kWorkoutFishing, kWorkoutFunctionalStrengthTraining, kWorkoutGolf, kWorkoutGymnastics, kWorkoutHandball, kWorkoutHiking, kWorkoutHockey, kWorkoutHunting, kWorkoutLacrosse, kWorkoutMartialArts, kWorkoutMindAndBody, kWorkoutMixedMetabolicCardioTraining, kWorkoutPaddleSports, kWorkoutPlay, kWorkoutPreparationAndRecovery, kWorkoutRacquetball, kWorkoutRowing, kWorkoutRugby, kWorkoutRunning, kWorkoutSailing, kWorkoutSkatingSports, kWorkoutSnowSports, kWorkoutSoccer, kWorkoutSoftball, kWorkoutSquash, kWorkoutStairClimbing, kWorkoutSurfingSports, kWorkoutSwimming, kWorkoutTableTennis, kWorkoutTennis, kWorkoutTrackAndField, kWorkoutTraditionalStrengthTraining, kWorkoutVolleyball, kWorkoutWalking, kWorkoutWaterFitness, kWorkoutWaterPolo, kWorkoutWaterSports, kWorkoutWrestling, kWorkoutYoga, kWorkoutTreadmill];
    return array;
}

@end
