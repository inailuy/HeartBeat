//
//  WorkoutVC.m
//  Heart Beat
//
//  Created by inailuy on 2/11/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import "WorkoutVC.h"
#import "NSTimer+Pause.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "BEMSimpleLineGraphView.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Pin.h"
#import "EndWorkoutVC.h"
#import "WorkoutTypeVC.h"
#import "WorkoutObject.h"

#define kDistanceCalculationInterval 10 // the interval (seconds) at which we calculate the user's distance
#define kNumLocationHistoriesToKeep 5 // the number of locations to store in history so that we can look back at them and determine which is most accurate
#define kValidLocationHistoryDeltaInterval 3 // the maximum valid age in seconds of a location stored in the location history
#define kMinLocationsNeededToUpdateDistance 3 // the number of locations needed in history before we will even update the current distance
#define kRequiredHorizontalAccuracy 40.0f // the required accuracy in meters for a location.  anything above this number will be discarded
#define SECONDS_IN_MINUTES 60

#define UTTERANCE_RATE 0.5 // Speed in which to speak values

@interface WorkoutVC ()<UIActionSheetDelegate, AVSpeechSynthesizerDelegate, BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource, CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageBpmLabel;
@property (weak, nonatomic) IBOutlet UILabel *bpmLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloriesBurnedLabel;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIButton *workoutTypeButton;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (nonatomic) int count;
@property (nonatomic) int seconds;
@property (nonatomic) int additionOfAllBeats;
@property (nonatomic) float averageBPM;
@property (nonatomic) float minutes;
@property (nonatomic) float caloriesBurned;
@property (strong, nonatomic) NSMutableArray *originalBpmAverage;
@property (strong, nonatomic) NSMutableArray *modifiedBpmAverage;
@property (nonatomic) float minuteAverageBpm;
@property (nonatomic, strong) WorkoutObject *currentWorkoutSummary;

@property (nonatomic) int debugValue;

@property (nonatomic) BOOL isPaused;
@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *lineGraphView;

@property (nonatomic, strong) AVSpeechSynthesizer *speechSynthesizer;
@property (nonatomic, strong) AVSpeechUtterance *speechUtterance;
@property (nonatomic, strong) NSNumber *speechInterval;

// CLLocation/Mapkit
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locationHistory;
@property (nonatomic, strong) NSMutableArray *allPins;
@property (nonatomic) CLLocationDistance distance;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *blurView;
@property (nonatomic) BOOL firstTimeLoading;
@property (weak, nonatomic) IBOutlet UIButton *disclosureButton;
@property (nonatomic, strong) NSDate *locationDate;
@property (nonatomic, strong) MKPolyline *polyline;
@property (nonatomic, strong) MKPolylineView *lineView;

@end

@implementation WorkoutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.timer = [NSTimer scheduledTimerWithTimeInterval:01.0
                                                  target:self
                                                selector:@selector(secondsInterval)
                                                userInfo:nil
                                                 repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(endWorkout)
                                                 name:@"End Workout"
                                               object:nil];
    
    [self calculatedCaloriesBurned];
    
    NSNumber *debugMode = [[NSUserDefaults standardUserDefaults] valueForKey:@"debugMode"];
    _debugValue = 0;
    if (debugMode.boolValue) _debugValue = 90;
    
    if (!_speechInterval) _speechInterval = [[NSUserDefaults standardUserDefaults] valueForKey:@"speechUtterance"];
    if (!_speechSynthesizer) _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    if (!_speechUtterance){
        _speechUtterance = [AVSpeechUtterance speechUtteranceWithString:nil];
    }
    _speechSynthesizer.delegate = self;
    
    self.lineGraphView.enableBezierCurve = YES;
    self.lineGraphView.enablePopUpReport = YES;
    self.lineGraphView.enableTouchReport = YES;
    self.lineGraphView.enableXAxisLabel = YES;
    self.lineGraphView.enableYAxisLabel = YES;
    self.lineGraphView.enableReferenceXAxisLines = YES;
    self.lineGraphView.enableReferenceYAxisLines = YES;
    self.lineGraphView.animationGraphStyle = BEMLineAnimationNone;
    
    self.muteButton.selected = ((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"mute"]).boolValue;
    self.locationManager = [[CLLocationManager alloc] init];
    [self updateWorkoutType];
    
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        self.locationManager.distanceFilter = 5; // specified in meters
    }
    
    self.locationHistory = [NSMutableArray array];
    
    self.mapView.showsUserLocation = YES;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.view.bounds];
    self.blurView.backgroundColor = [UIColor clearColor];
    self.blurView.alpha = .62;
    [self.blurView addSubview:blurEffectView];
    
    self.lineGraphView.alpha = .8;
    //self.lineGraphView.colorBottom = [UIColor colorWithWhite:1.0 alpha:.5];
    self.lineGraphView.backgroundColor = [UIColor colorWithRed:.0 green:.0 blue:.2 alpha:.1];
    self.lineGraphView.alpha = .6;

    [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self
                                   selector:@selector(updateWorkoutType)
                                   userInfo:nil
                                    repeats:NO];
    
    self.distanceLabel.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)secondsInterval
{
    if (!self.isPaused)
        self.seconds++;
    self.timerLabel.text =  [self getTimeStr:self.seconds];
    self.averageBpmLabel.text = [self calculateAverageBpm];
    
    
    self.bpmLabel.text = [NSString stringWithFormat:@"%i Current bpm",[AppDelegate instance].currentHeartBeat+_debugValue];

    [self calculatedCaloriesBurned];
    
    [self speechIntervalWork:NO];
    
    [self calculatemodifiedBpmAverage];
    
    if (self.mapView.showsUserLocation){
        [self drawMap];
    }
    
}

- (void) speechIntervalWork:(BOOL)finsihedWorkout{
    if (!self.muteButton.selected){
        int minutes = self.seconds / 60;
        int averageBPM = (self.additionOfAllBeats/self.seconds)+_debugValue;
        int currentBPM = [AppDelegate instance].currentHeartBeat+_debugValue;
        NSString *utterance;
        if (self.speechInterval.integerValue != 0 &&
            (self.seconds/60) % self.speechInterval.intValue == 0 &&
            self.seconds % 60 == 0){
            utterance = [NSString stringWithFormat:@"Time, %i minutes, Current Heart beat %i, Average Heart Rate %i",
                         minutes, currentBPM, averageBPM];
            _speechUtterance = [AVSpeechUtterance speechUtteranceWithString:utterance];
            _speechUtterance.rate = UTTERANCE_RATE;
            [_speechSynthesizer  speakUtterance:_speechUtterance];
        }
        else if (self.seconds == 1){
            NSString *utterance = @"Starting Workout";
            _speechUtterance = [AVSpeechUtterance speechUtteranceWithString:utterance];
            _speechUtterance.rate = UTTERANCE_RATE;
            [_speechSynthesizer  speakUtterance:_speechUtterance];
        }else if (finsihedWorkout){
            utterance = [NSString stringWithFormat:@"Workout Complete, Workout Summary %i minutes, Average Heart Rate %i, calories burned %i",
                         minutes, averageBPM, (int)self.caloriesBurned];
            _speechUtterance = [AVSpeechUtterance speechUtteranceWithString:utterance];
            _speechUtterance.rate = UTTERANCE_RATE;
            [_speechSynthesizer  speakUtterance:_speechUtterance];
        }
    }
}

- (NSString*)getTimeStr : (int) secondsElapsed {
    int seconds = secondsElapsed % 60;
    int minutes = secondsElapsed / 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (NSString *)calculateAverageBpm{
    if (!self.additionOfAllBeats) self.additionOfAllBeats = 0;
    
    self.additionOfAllBeats += [AppDelegate instance].currentHeartBeat;
    //NSLog(@"%i - %i", self.additionOfAllBeats, self.additionOfAllBeats/self.seconds);
    
    return [NSString stringWithFormat:@"%i Average bpm", (self.additionOfAllBeats/self.seconds)+_debugValue];
}

- (void) calculatedCaloriesBurned{
    if (!self.minuteAverageBpm) self.minuteAverageBpm = 0;
    if (!self.originalBpmAverage) self.originalBpmAverage = self.modifiedBpmAverage = [NSMutableArray array];
    
    NSNumber *ageNum = [[NSUserDefaults standardUserDefaults] valueForKey:@"age"];
    NSNumber *weightNum = [[NSUserDefaults standardUserDefaults] valueForKey:@"wieght"];
    NSNumber *sex = [[NSUserDefaults standardUserDefaults] valueForKey:@"sex"];
    NSNumber *debugMode = [[NSUserDefaults standardUserDefaults] valueForKey:@"debugMode"];
    
    float age = ageNum.floatValue;
    float weight = weightNum.floatValue;
    float minutes = self.minutes;
    float bpm = self.averageBPM;
    //float VO2MAX = 15.0 * ((208.0 - 0.7 * age)/65.0);
    
    int debugValue = 0;
    if (debugMode.boolValue) debugValue = 80;
    
    self.averageBPM = ((float)self.additionOfAllBeats/(float)self.seconds)+debugValue;
    self.minutes = ((float)self.seconds/60);
    self.caloriesBurned = 0.0;
    
    self.minuteAverageBpm += [AppDelegate instance].currentHeartBeat+debugValue;
    int var = 10;
    if (self.seconds % var == 0 && self.seconds != 0){
        [self.originalBpmAverage addObject:[NSNumber numberWithFloat:self.minuteAverageBpm/var]];
        self.minuteAverageBpm = 0;
        if (!self.lineGraphView.hidden || self.originalBpmAverage.count == 2){
            [self.lineGraphView reloadGraph];
        }
    }

    if (sex.boolValue == MALE){
        //self.caloriesBurned = ((-59.3954 + (-36.3781 + 0.271 * age + 0.394 * weight + 0.404 * VO2MAX + 0.634 * bpm))/4.184)* minutes;// V02 max
        self.caloriesBurned = ((age * 0.2017) + (weight * 0.1988)+ (bpm * 0.6309) - 55.0969) * minutes / 4.184;
    }else if (sex.boolValue == FEMALE){
        //self.4caloriesBurned = ((-20.4022 + 0.4472 * bpm + 0.1263 * weight + 0.074 * age) / 4.184) * minutes;// V02 max
        self.caloriesBurned = ( (age * 0.074) + (weight * 0.1263) + (bpm * 0.4472) - 20.4022) * minutes / 4.184;
    }
    
    self.caloriesBurnedLabel.hidden = self.averageBPM > 90 ? NO : YES;
    self.caloriesBurnedLabel.text = [NSString stringWithFormat:@"%i Calories burned", (int)self.caloriesBurned];
}

- (void) calculatemodifiedBpmAverage{
    if (self.originalBpmAverage.count < 36){        // under 6 minutes
        [self originalBpmAverage];
    }else if (self.originalBpmAverage.count < 72){  // 6 - 12 minutes
        [self thirdMinuteAverage];
    }else if (self.originalBpmAverage.count < 270){ // 12 - 45 minutes
        [self halfMinuteAverage];
    }else{                                          // 45 + minutes
        [self minuteAverage];
    }
    
}

- (void) originalAverage { //ten second average
    self.modifiedBpmAverage = self.originalBpmAverage;
}

- (void) thirdMinuteAverage { // 20 second average
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (int i = 0; i+1 < self.originalBpmAverage.count; i = i+2) {
        NSNumber *one = self.originalBpmAverage[i];
        NSNumber *two = self.originalBpmAverage[i+1];
        int num = (one.intValue + two.intValue)/2;
        [tmpArray addObject:[NSNumber numberWithInt:num]];
    }
    self.modifiedBpmAverage = tmpArray;
}

- (void) halfMinuteAverage { // 30 second average
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (int i = 0; i+2 < self.originalBpmAverage.count; i = i+3) {
        NSNumber *one = self.originalBpmAverage[i];
        NSNumber *two = self.originalBpmAverage[i+1];
        NSNumber *three = self.originalBpmAverage[i+2];
        int num = (one.intValue + two.intValue + three.intValue)/3;
        [tmpArray addObject:[NSNumber numberWithInt:num]];
    }
    self.modifiedBpmAverage = tmpArray;
}

- (void) minuteAverage { // 60 second average
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (int i = 0; i+5 < self.originalBpmAverage.count; i = i+6) {
        NSNumber *one = self.originalBpmAverage[i];
        NSNumber *two = self.originalBpmAverage[i+1];
        NSNumber *three = self.originalBpmAverage[i+2];
        NSNumber *four = self.originalBpmAverage[i+3];
        NSNumber *five = self.originalBpmAverage[i+4];
        NSNumber *six = self.originalBpmAverage[i+5];
        int num = (one.intValue + two.intValue + three.intValue + four.intValue + five.intValue + six.intValue)/6;
        [tmpArray addObject:[NSNumber numberWithInt:num]];
    }
    self.modifiedBpmAverage = tmpArray;
}

- (void) endWorkout {
    [self.timer pause];
    [self speechIntervalWork:YES];
    
    WorkoutObject *workout = [[WorkoutObject alloc] init];
    workout.averageBPM = [NSNumber numberWithFloat:self.averageBPM];
    workout.calories = [NSNumber numberWithFloat:self.caloriesBurned];
    workout.totalTime = [NSNumber numberWithFloat:self.minutes];
    workout.seconds = [NSNumber numberWithInt:self.seconds];
    workout.healthkit = @NO;
    workout.endDate = [NSDate date];
    workout.bpmAverageArray = self.originalBpmAverage;

    NSNumber *indexNum = [[NSUserDefaults standardUserDefaults] valueForKey:@"workoutType"];
    NSUInteger index = indexNum.intValue;
    NSString *workoutType = self.workoutTypesArray[index];
    if (workoutType){
        workout.workoutType = workoutType;
    }
    
    // if workout equals run/walking save distance/location history
    if (index == HKWorkoutActivityTypeWalking || index == HKWorkoutActivityTypeRunning ||
        index ==  HKWorkoutActivityTypeHiking ||index ==  HKWorkoutActivityTypeCycling){
        workout.distance = [NSNumber numberWithDouble:self.distance];
        workout.locationHistory = self.locationHistory;
    }
    
    [[AppDelegate instance] saveWorkoutToHealthKit:workout];
    [AppDelegate instance].isWorkoutActive = NO;
    [self.timer pause];
    [self.timer invalidate];
    self.timer = nil;
    
    self.currentWorkoutSummary = workout;
    [workout descriptionValue];
    
    [self performSegueWithIdentifier:@"endWorkoutSegue" sender:self];
}

#pragma mark - Button & Gesture Activated -

- (IBAction)gestureRecognized:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Save"
                                                    otherButtonTitles:@"Don't Save", nil];
    [actionSheet showInView:self.view];
}
- (IBAction)timerButtonPressed:(UIButton *)sender {
    if (!self.muteButton.selected){
        int minutes = self.seconds / 60;
        int averageBPM = (self.additionOfAllBeats/self.seconds)+_debugValue;
        int currentBPM = [AppDelegate instance].currentHeartBeat+_debugValue;
        NSString *utterance;
        utterance = [NSString stringWithFormat:@"Time, %i minutes, Current Heart beat %i, Average Heart Rate %i",
                     minutes, currentBPM, averageBPM];
        _speechUtterance = [AVSpeechUtterance speechUtteranceWithString:utterance];
        _speechUtterance.rate = UTTERANCE_RATE;
        [_speechSynthesizer  speakUtterance:_speechUtterance];
    }
}

- (IBAction)muteButtonPressed:(UIButton *)sender {
    sender.selected = !sender.selected;
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:sender.selected] forKey:@"mute"];
}

- (IBAction)workoutButtonPressed:(UIButton *)sender {
    
}

- (IBAction)hideGraphButtonPressed:(UIButton *)sender {
    if (self.originalBpmAverage.count > 1){
        self.lineGraphView.hidden = !self.lineGraphView.hidden;
        if (self.lineGraphView.hidden){
            self.blurView.alpha = .62;
        }else{
            self.blurView.alpha = .89;
        }
        
        if (!self.lineGraphView.hidden){
            [self.lineGraphView reloadGraph];
        }
    }
}

- (IBAction)pauseButtonPressed:(UIButton *)sender {
    if (self.isPaused){
        [sender setTitle:@"pause" forState:UIControlStateNormal];
        if (!self.muteButton.selected){
            NSString *utterance = @"Resuming workout";
            _speechUtterance = [AVSpeechUtterance speechUtteranceWithString:utterance];
            _speechUtterance.rate = UTTERANCE_RATE;
            [_speechSynthesizer  speakUtterance:_speechUtterance];
        }
        [self.timer resume];
    }else{
        [sender setTitle:@"resume" forState:UIControlStateNormal];
        if (!self.muteButton.selected){
            NSString *utterance = @"Pausing workout";
            _speechUtterance = [AVSpeechUtterance speechUtteranceWithString:utterance];
            _speechUtterance.rate = UTTERANCE_RATE;
            [_speechSynthesizer  speakUtterance:_speechUtterance];
        }
        [self.timer pause];
    }
    self.isPaused = !self.isPaused;
}

- (IBAction)endButtonPressed:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Save"
                                                    otherButtonTitles:@"Don't Save", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate -

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        [self endWorkout];
    }else if (buttonIndex == 1){
        [AppDelegate instance].isWorkoutActive = NO;
        [self.timer pause];
        [self.timer invalidate];
        self.timer = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - AVSpeechSynthesizerDelegate -

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance{
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

#pragma mark - BEMSimpleLineGraphView DataSource/Delegates -

-(NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph{
    self.disclosureButton.hidden = self.lineGraphView.hidden = self.modifiedBpmAverage.count > 1 ? NO : YES;
    return self.modifiedBpmAverage.count;
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index
{
    if (!self.count) self.count = 0;
    
    self.count++;
    float position = (float)index / (float)self.modifiedBpmAverage.count;
    float duration = self.minutes;
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:0];
    float result = position * duration;
    
    int seconds = fmod(result, 1.0)*60;
    int minutes = (int)result;
    NSString *returnString = [NSString stringWithFormat:@"%02d:%i", minutes, seconds];
    
    if (self.minutes > 15){
       returnString = [formatter stringFromNumber:[NSNumber numberWithFloat:result]];
    }
    return returnString;
}


- (NSInteger)numberOfYAxisLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph{
    return 5;
}

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    float var = self.minutes > 7 ? .16 : .25;
    return self.modifiedBpmAverage.count * var; // The number of hidden labels between each displayed label.
}

-(CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index{
    NSNumber *point = [self.modifiedBpmAverage objectAtIndex:index];
    CGFloat f = point.doubleValue;
    return f;
}

- (CGFloat)maxValueForLineGraph:(BEMSimpleLineGraphView *)graph
{
    int max = 0;
    for (NSNumber *num in self.modifiedBpmAverage) {
        int orig = num.intValue;
        if (orig > max) max = orig;
    }
    
    return max;
}

-(CGFloat)minValueForLineGraph:(BEMSimpleLineGraphView *)graph
{
    int min = 200;
    for (NSNumber *num in self.modifiedBpmAverage) {
        int orig = num.intValue;
        if (orig < min) min = orig;
    }
    
    return min;
}

- (void) updateWorkoutType {
    NSNumber *indexNum = [[NSUserDefaults standardUserDefaults] valueForKey:@"workoutType"];
    int index = indexNum.intValue;
    NSString *workoutType = self.workoutTypesArray[index];
    if (!workoutType) workoutType = @"workout type";
    [self.workoutTypeButton setTitle:workoutType forState:UIControlStateNormal];
    
    if (index == HKWorkoutActivityTypeWalking || index == HKWorkoutActivityTypeRunning ||
        index ==  HKWorkoutActivityTypeHiking ||index ==  HKWorkoutActivityTypeCycling){
        [self.locationManager startUpdatingLocation];
        self.mapView.showsUserLocation = YES;
        self.distanceLabel.hidden = NO;
    }else{
        if (self.seconds < 120){
            self.mapView.showsUserLocation = NO;
            self.distanceLabel.hidden = YES;
            [self.locationManager stopUpdatingLocation];
        }
    }
}

//- (void) turnoffLocation{
//    NSNumber *indexNum = [[NSUserDefaults standardUser43 3Defaults] valueForKey:@"workoutType"];
//    int index = indexNum.intValue;
//    
//}

#pragma mark - CoreLocation & MapKit Delegates -

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // since the oldLocation might be from some previous use of core location, we need to make sure we're getting data from this run
    if (oldLocation == nil) return;
    if (!self.locationDate) self.locationDate = [NSDate date];
    if (!self.allPins) self.allPins = [NSMutableArray array];
    if (self.locationHistory.count == 0) [self.locationHistory addObject:newLocation];
    
    NSTimeInterval age = [[NSDate date] timeIntervalSinceDate:self.locationDate];
    if (newLocation.horizontalAccuracy >= 0.0f && newLocation.horizontalAccuracy < kRequiredHorizontalAccuracy) {
        if (![self.locationHistory.lastObject isEqual:newLocation] && (age > 5)){
            [self.locationHistory addObject:newLocation];
            self.locationDate = [NSDate date];
            [self determineTotalDistanceTraveled];
        }
    }
    
    Pin *pin = [[Pin alloc] initWithCoordinate:newLocation.coordinate];
    if (![self.allPins containsObject:pin])
        [self.allPins addObject:pin];

    if (self.mapView.showsUserLocation){
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (newLocation.coordinate, 50, 50);
        [self.mapView setRegion:region animated:YES];
    }
}

- (void) determineTotalDistanceTraveled{
    CLLocationDistance distance = 0;
    for (CLLocation *location in self.locationHistory) {
        NSUInteger index = [self.locationHistory indexOfObject:location] + 1;
        if (self.locationHistory.count != index){
            CLLocation *nextLocation = self.locationHistory[index];
            distance += [nextLocation distanceFromLocation:location];
        }
    }
    self.distance = distance;
    MKDistanceFormatter *df = [[MKDistanceFormatter alloc]init];
    df.unitStyle = MKDistanceFormatterUnitStyleAbbreviated;

    NSNumber *index = [[NSUserDefaults standardUserDefaults] valueForKey:@"workoutType"];
    if (index.intValue == HKWorkoutActivityTypeWalking || index.intValue == HKWorkoutActivityTypeRunning){
        if (distance > 0){
            self.distanceLabel.text = [NSString stringWithFormat:@"dist %@", [df stringFromDistance: distance]];
        }else{
            self.distanceLabel.text = @"";
        }
    }
}

- (void) drawMap{
    if (self.seconds > 10)
        [self drawLineSubroutine];
}

- (void)drawLineSubroutine {
    
    // remove polyline if one exists
    [self.mapView removeOverlay:self.polyline];
    
    // create an array of coordinates from allPins
    CLLocationCoordinate2D coordinates[self.allPins.count];
    int i = 0;
    
    for (Pin *currentPin in self.allPins) {
        coordinates[i] = currentPin.coordinate;
        i++;
    }
    
    // create a polyline with all cooridnates
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:self.allPins.count];
    [self.mapView addOverlay:polyline];
    self.polyline = polyline;
    
    // create an MKPolylineView and add it to the map view
    self.lineView = [[MKPolylineView alloc]initWithPolyline:self.polyline];
    self.lineView.strokeColor = [UIColor redColor];
    self.lineView.lineWidth = 7;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    return self.lineView;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.currentWorkoutSummary descriptionValue];
    if ([segue.identifier isEqualToString:@"endWorkoutSegue"]){
        EndWorkoutVC *vc = segue.destinationViewController;
        vc.workoutSummary = self.currentWorkoutSummary;
        vc.region = self.mapView.region;
        vc.timeString = self.timerLabel.text;
    }else if ([segue.identifier isEqualToString:@"workoutTypeSegue"]){
        UINavigationController *nc = segue.destinationViewController;
        WorkoutTypeVC *vc = nc.viewControllers.lastObject;
        vc.delegate = self;
    }
}

@end
