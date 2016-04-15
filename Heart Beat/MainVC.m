//
//  ViewController.m
//  Heart Beat
//
//  Created by inailuy on 2/11/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import "MainVC.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "YZSwipeBetweenViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <CoreImage/CoreImage.h>
//#import "HeartRateCoreSDK.h"

#define kDistanceCalculationInterval 10 // the interval (seconds) at which we calculate the user's distance
#define kNumLocationHistoriesToKeep 5 // the number of locations to store in history so that we can look back at them and determine which is most accurate
#define kValidLocationHistoryDeltaInterval 3 // the maximum valid age in seconds of a location stored in the location history
#define kMinLocationsNeededToUpdateDistance 3 // the number of locations needed in history before we will even update the current distance
#define kRequiredHorizontalAccuracy 40.0f
#define SECONDS_IN_MINUTES 60

@interface MainVC ()<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *peripheralConnectionButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *workoutButton;
@property (nonatomic, strong) YZSwipeBetweenViewController *swipeBetweenVC;
@property (weak, nonatomic) IBOutlet UIButton *workoutTypeButton;
//
@property (weak, nonatomic) IBOutlet UIView *blurView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locationHistory;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MKPolyline *polyline;
@property (nonatomic, strong) MKPolylineView *polylineRenderer;
@property (nonatomic) BOOL firstTimeLoading;

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.swipeBetweenVC = [AppDelegate instance].swipeBetweenVC;
    
    [NSTimer scheduledTimerWithTimeInterval:01.0
                                     target:self
                                   selector:@selector(targetMethod)
                                   userInfo:nil
                                    repeats:YES];
    self.workoutButton.hidden = YES;
    
    UIBarButtonItem *historyButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Settings"
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(settingsButtonPressed)];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"History"
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(historyButtonPressed)];
    self.navigationItem.rightBarButtonItem = historyButton;
    self.navigationItem.leftBarButtonItem = settingsButton;
    
    NSNumber *index = [[NSUserDefaults standardUserDefaults] valueForKey:@"workoutType"];
    NSString *workoutType = self.workoutTypesArray[index.intValue];
    if (!workoutType) workoutType = @"workout type";
    [self.workoutTypeButton setTitle:workoutType forState:UIControlStateNormal];
    
    
    //
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
        
        if ([CLLocationManager locationServicesEnabled]) {
            //[self.locationManager startUpdatingLocation];
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            self.locationManager.distanceFilter = 1; // specified in meters
        }
        
        self.locationHistory = [NSMutableArray array];
    }
    //
    
    self.mapView.showsUserLocation = NO;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.view.bounds];
    self.blurView.backgroundColor = [UIColor clearColor];
    self.blurView.alpha = .8;
    [self.blurView addSubview:blurEffectView];
    
    self.title = @"heartbeat";
//    [HeartRateCoreSDK sharedInstance].delegate = self;
//    [[HeartRateCoreSDK sharedInstance] start];
//    self.polylineRenderer = [[MKPolylineView alloc] init];
//    self.polylineRenderer.lineWidth = 8.0f;
//    self.polylineRenderer.strokeColor = [UIColor redColor];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    /*
    NSString *user = [PFUser currentUser].username;
    if (!user){
        [self performLoginOperation];
    }
    */
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // since the oldLocation might be from some previous use of core location, we need to make sure we're getting data from this run
    if (oldLocation == nil) return;
    
    [manager stopUpdatingLocation];

    
//    NSTimeInterval age = [[NSDate date] timeIntervalSinceDate:newLocation.timestamp];
//    
//    if (age < SECONDS_IN_MINUTES)
//    {
//        MKCoordinateRegion mapRegion;
//        mapRegion.center = newLocation.coordinate;
//        mapRegion.span.latitudeDelta = 0.025;
//        mapRegion.span.longitudeDelta = 0.025;
//        
//        [self.mapView setRegion:mapRegion animated: YES];
//        if (mapRegion.center.latitude)
//            self.firstTimeLoading = YES;
//    }
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
    MKDistanceFormatter *df = [[MKDistanceFormatter alloc]init];
    df.unitStyle = MKDistanceFormatterUnitStyleAbbreviated;
    
    self.peripheralStausLabel.text = [NSString stringWithFormat:@"distance %@  count %lu", [df stringFromDistance: distance], (unsigned long)self.locationHistory.count];
}

//- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id )overlay
//{
//    MKOverlayView* overlayView = nil;
//    
//    if(overlay == self.routeLine)
//    {
//        //if we have not yet created an overlay view for this overlay, create it now.
//        if(nil == self.routeLineView)
//        {
//            self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
//            self.routeLineView.fillColor = [UIColor redColor];
//            self.routeLineView.strokeColor = [UIColor redColor];
//            self.routeLineView.lineWidth = 3;
//        }
//        
//        overlayView = self.routeLineView;
//        
//    }
//    
//    return overlayView;
//    
//}

//-(void) createPath{
//    CGMutablePathRef path = CGPathCreateMutable();
//    BOOL pathIsEmpty = YES;
//    for (CLLocation *location in self.locationHistory) {
//        MKPolyline *polyline = [MKPolyline polylineWithCoordinates:location.coordinate  count:1];
//        CGPoint point = polyline.points;
//        if (pathIsEmpty){
//            CGPathMoveToPoint(path, nil, point.x, point.y);
//            pathIsEmpty = NO;
//        } else {
//            CGPathAddLineToPoint(path, nil, point.x, point.y);
//        }
//    }
//    
//    self.path = path; //<—— don't forget this line.
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)targetMethod{
    self.heartbeatLabel.text = [AppDelegate instance].heartBeatString;
    //self.peripheralStausLabel.text = [AppDelegate instance].peripheralStatusString;
    
    NSString *buttonTitle = @"";
    if ([AppDelegate instance].isPeripheralConnected){
        buttonTitle = @"Disconnect Peripheral";
        //if ([self.peripheralStausLabel.text isEqualToString:@""])
            self.workoutButton.hidden = NO;
    }else{
        buttonTitle = @"Connect Peripheral";
        self.workoutButton.hidden = NO;
    }
    [self.peripheralConnectionButton setTitle:buttonTitle forState:UIControlStateNormal];

}

- (IBAction)historyButtonPressed {
    [self.swipeBetweenVC scrollToViewControllerAtIndex:0 animated:YES];
}

- (IBAction)settingsButtonPressed {
    [self.swipeBetweenVC scrollToViewControllerAtIndex:2 animated:YES];
}

- (IBAction)workoutButtonPressed:(UIButton *)sender {
    [AppDelegate instance].isWorkoutActive = YES;
}

- (IBAction)workoutTypeButtonPressed:(UIButton *)sender {

}

- (IBAction)gestureRecognized:(id)sender {
    //[self performSegueWithIdentifier:@"workoutSegue" sender:self];
}

- (IBAction)gestureRecognizerUp:(id)sender{
  //  [self performSegueWithIdentifier:@"loginSegue" sender:self];
}

- (IBAction)peripheralConnectionButtonPressed:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData"
                                                        object:nil];
    
    NSString *buttonTitle = @"";
    if ([AppDelegate instance].isPeripheralConnected){
        [[AppDelegate instance] disconnectPeripheral];
        buttonTitle = @"Connect Peripheral";
    }else{
        [[AppDelegate instance] connectPeripheral];
        buttonTitle = @"Disconnect Peripheral";
    }
    [self.peripheralConnectionButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void) updateWorkoutType {
    NSNumber *index = [[NSUserDefaults standardUserDefaults] valueForKey:@"workoutType"];
    NSString *workoutType = self.workoutTypesArray[index.intValue];
    if (!workoutType) workoutType = @"workout type";
    [self.workoutTypeButton setTitle:workoutType forState:UIControlStateNormal];
    //NSLog(@"%lu %li", (unsigned long)HKWorkoutActivityTypeAmericanFootball, index.longValue);
}

- (void)performLoginOperation{
    [self performSegueWithIdentifier:@"loginSegue" sender:self];
}

//- (void) didUpdateHeartRate:(HeartRateData *) heartRateData{
//    self.heartbeatLabel.text = [NSString stringWithFormat:@"%i bpm", (int)heartRateData.heartRateBpm];
//}
//
//- (void) didChangeHeartRateMonitorStatus:(HeartRateMonitorStatus) heartRateMonitorStatus{
//    
//}

@end
