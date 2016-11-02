//
//  WorkoutSummaryVC.m
//  Heart Beat
//
//  Created by inailuy on 2/14/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import "WorkoutSummaryVC.h"
#import "BEMSimpleLineGraphView.h"
#import "AppDelegate.h"
#import <MapKit/MapKit.h>
#import "Pin.h"
#import "WorkoutObject.h"

#define IS_PAD ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
#define IS_PHONE_3 ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && \
ABS([UIScreen mainScreen].bounds.size.height - 480.01) < 0.01)
#define IS_PHONE_4 ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && \
[UIScreen mainScreen].bounds.size.height > 480.01)
#define IS_IOS7 [[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue] >= 7


@interface WorkoutSummaryVC ()<BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *caloriesBurnedLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageBpmLabel;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *workoutTypeLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) NSArray *originalBpmAverage;
@property (strong, nonatomic) NSArray *modifiedBpmAverage;
@property (nonatomic) int count;
@property (nonatomic, strong) NSMutableArray *locationHistory;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MKPolyline *polyline;
@property (nonatomic, strong) MKPolylineView *lineView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) WorkoutObject *workout;

@end

@implementation WorkoutSummaryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.workout = (WorkoutObject *)self.workoutSummary;
    
    NSString *workoutType = self.workout.workoutType;
    if (!workoutType) workoutType = @"Workout Summary";
    self.title = workoutType;
    
    // Do any additional setup after loading the view.
    self.originalBpmAverage = self.modifiedBpmAverage = self.workout.bpmAverageArray;
   // NSLog(@"%lu", (unsigned long)self.bpmAverageArray.count);
    self.caloriesBurnedLabel.text = [NSString stringWithFormat:@"calories burned %i", [self calculateVo2maxCaloriesBurned]];
    self.durationLabel.text = [NSString stringWithFormat:@"duration %i min", self.workout.totalTime.intValue];
    self.averageBpmLabel.text = [NSString stringWithFormat:@"average bpm %i", self.workout.averageBPM.intValue];
    self.workoutTypeLabel.text = self.workout.workoutType;
    
    NSDate *currentDate = self.workout.createdAt;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"US/Eastern"]];
    NSString *stringFromDate = [formatter stringFromDate:currentDate];
    self.dateLabel.text = [NSString stringWithFormat:@"date:%@", stringFromDate];
    
    
    if (self.originalBpmAverage.count < 36){ // under 6 minutes
        [self originalBpmAverage];
        self.segmentedControl.selectedSegmentIndex = 0;
    }else if (self.originalBpmAverage.count < 72){ // 6 - 12 minutes
        [self thirdMinuteAverage];
        self.segmentedControl.selectedSegmentIndex = 1;
    }else if (self.originalBpmAverage.count < 270){ // 12 - 45 minutes
        [self halfMinuteAverage];
        self.segmentedControl.selectedSegmentIndex = 2;
    }else{                                          // 45 + minutes
        [self minuteAverage];
        self.segmentedControl.selectedSegmentIndex = 3;
    }
    
    if (self.workout.locationHistory){
        NSArray *locationHistory = self.workout.locationHistory;
        /*
        for (PFGeoPoint *geoPoint in locationHistory) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
            if (!self.locationHistory) self.locationHistory = [NSMutableArray array];
            Pin *pin = [[Pin alloc] initWithCoordinate:location.coordinate];
            [self.locationHistory addObject:pin];
        }
         */
        [self drawLineSubroutine];
    }
    self.mapView.showsUserLocation = YES;
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"share"
                                       style:UIBarButtonItemStyleDone
                                       target:self
                                       action:@selector(shareButtonPressed)];
    self.navigationItem.rightBarButtonItem = shareButton;
}

- (void)shareButtonPressed {
    UIImage *screenshot = [self captureView];
    NSArray *items = @[screenshot];

    NSArray *Acts = nil;
    
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                               applicationActivities:Acts];
    activityView.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeMail];
    
    if (IS_PAD && IS_IOS7)
    {
//        self.popover = [[UIPopoverController alloc] initWithContentViewController:activityView];
//        
//        __weak id weakSelf = self;
//        self.popover.delegate = weakSelf;x
//        [self.popover presentPopoverFromRect:self.view.frame
//                                      inView:self.view
//                    permittedArrowDirections:nil
//                                    animated:YES];
        
    }
    else
    {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        [self presentViewController:activityView animated:YES completion:nil];
    }
}

- (UIImage *)captureView {
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(self.view.bounds.size);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)drawLineSubroutine {
    
    // remove polyline if one exists
    [self.mapView removeOverlay:self.polyline];
    
    // create an array of coordinates from allPins
    CLLocationCoordinate2D coordinates[self.locationHistory.count];
    int i = 0;
    for (Pin *currentPin in self.locationHistory) {
        coordinates[i] = currentPin.coordinate;
        i++;
    }
    
    // create a polyline with all cooridnates
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:self.locationHistory.count];
    [self.mapView addOverlay:polyline];
    self.polyline = polyline;
    
    // create an MKPolylineView and add it to the map view
    self.lineView = [[MKPolylineView alloc]initWithPolyline:self.polyline];
    self.lineView.strokeColor = [UIColor redColor];
    self.lineView.lineWidth = 5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (IBAction)segmentControlledChanged:(UISegmentedControl *)sender {
//    switch (sender.selectedSegmentIndex) {
//        case 0:
//            [self originalAverage];
//            [self.lineGraphView reloadGraph];
//            break;
//        case 1:
//            [self thirdMinuteAverage];
//            [self.lineGraphView reloadGraph];
//            break;
//        case 2:
//            [self halfMinuteAverage];
//            [self.lineGraphView reloadGraph];
//            break;
//        case 3:
//            [self minuteAverage];
//            [self.lineGraphView reloadGraph];
//            break;
//            
//        default:
//            break;
//    }
//}


- (IBAction)swipeDown:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph{
    NSLog(@"COUNTTTT  %lu", (unsigned long)self.modifiedBpmAverage.count);
    return self.modifiedBpmAverage.count;
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

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index
{
    if (!self.count) self.count = 0;
    
    self.count++;
    float position = (float)index / (float)self.modifiedBpmAverage.count;
    float duration = self.workout.totalTime.intValue;
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:0];
    float result = position * duration;
    
    int seconds = fmod(result, 1.0)*60;
    int minutes = (int)result;
    NSString *returnString = [NSString stringWithFormat:@"%02d:%i", minutes, seconds];
    
    if (duration > 15){
        returnString = [formatter stringFromNumber:[NSNumber numberWithFloat:result]];
    }
    
    return returnString;
}

- (NSInteger)numberOfYAxisLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph{
    return 5;
}

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    float var = self.workout.totalTime.intValue > 7 ? .12 : .25;
    return self.modifiedBpmAverage.count * var;
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index {
    if (!self.count) self.count = 0;
    
    self.count++;
    float position = (float)index / (float)self.modifiedBpmAverage.count;
    float duration = self.workout.totalTime.intValue;
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:0];
    float result = position * duration;
    
    int seconds = fmod(result, 1.0)*60;
    int minutes = (int)result;
    NSString *returnString = [NSString stringWithFormat:@"%02d:%i", minutes, seconds];
    
    if (duration > 15){
        returnString = [formatter stringFromNumber:[NSNumber numberWithFloat:result]];
    }
    
    NSString *minutesString = @"minutes";
    if (result == 1){
        minutesString = @"minute";
    }
    self.durationLabel.text = [NSString stringWithFormat:@"%@ %@", returnString, minutesString];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
    self.durationLabel.text = [NSString stringWithFormat:@"%i minutes", self.workout.totalTime.intValue];
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

- (int) calculateVo2maxCaloriesBurned {
    NSNumber *ageNum = [[NSUserDefaults standardUserDefaults] valueForKey:@"age"];
    NSNumber *wieghtNum = [[NSUserDefaults standardUserDefaults] valueForKey:@"wieght"];
    NSNumber *sex = [[NSUserDefaults standardUserDefaults] valueForKey:@"sex"];
    float caloriesBurned = 0;
    float age = ageNum.floatValue;
    float VO2MAX = 15 * ((208 - 0.7 * age)/65);
    float weight = wieghtNum.floatValue;
    float minutes = self.workout.totalTime.floatValue;
    float bpm = self.workout.averageBPM.floatValue;
    if (sex.boolValue == MALE){
        //caloriesBurned = ((-59.3954 + (-36.3781 + 0.271 * age + 0.394 * weight + 0.404 * VO2MAX + 0.634 * bpm))/4.184)* minutes;// V02 max
        caloriesBurned = ((age * 0.2017) + (weight * 0.1988)+ (bpm * 0.6309) - 55.0969) * minutes / 4.184;
    }else if (sex.boolValue == FEMALE){
        //caloriesBurned = ((-20.4022 + 0.4472 * bpm + 0.1263 * weight + 0.074 * age) / 4.184) * minutes;// V02 max
        caloriesBurned = ( (age * 0.074) + (weight * 0.1263) + (bpm * 0.4472) - 20.4022) * minutes / 4.184;
    }
    return (int)caloriesBurned;
}

- (void)drawLine {
    
    // remove polyline if one exists
    [self.mapView removeOverlay:self.polyline];
    
    // create an array of coordinates from allPins
    CLLocationCoordinate2D coordinates[self.locationHistory.count];
    int i = 0;
    for (Pin *currentPin in self.locationHistory) {
        coordinates[i] = currentPin.coordinate;
        i++;
    }
    
    // create a polyline with all cooridnates
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:self.locationHistory.count];
    [self.mapView addOverlay:polyline];
    self.polyline = polyline;
    
    // create an MKPolylineView and add it to the map view
    self.lineView = [[MKPolylineView alloc]initWithPolyline:self.polyline];
    self.lineView.strokeColor = [UIColor redColor];
    self.lineView.lineWidth = 5;
    
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    
    return self.lineView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    if (indexPath.row == 0){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"MM/dd/yy"];
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:cell.frame];
        
        //Optionally for time zone conversions
        NSString *stringFromDate = [formatter stringFromDate:self.workout.endDate];
        dateLabel.text = stringFromDate;
        dateLabel.textAlignment = NSTextAlignmentCenter;
        //[cell addSubview:dateLabel];
    }else if (indexPath.row == 2){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"linegraphCell"];
        [self setupGraph:cell];
    }else if (indexPath.row == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"timesCell"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm a"];
        
        UILabel *startingDateLabel = (UILabel *)[cell viewWithTag:320];
        UILabel *durationLabel = (UILabel *)[cell viewWithTag:321];
        UILabel *endDateLabel = (UILabel *)[cell viewWithTag:322];
        self.durationLabel = durationLabel;
        
        startingDateLabel.textAlignment = NSTextAlignmentLeft;
        endDateLabel.textAlignment = NSTextAlignmentRight;
        durationLabel.textAlignment = NSTextAlignmentCenter;
        
        NSDate *startedDate = [NSDate dateWithTimeInterval:-(self.workout.totalTime.intValue*60)
                                                 sinceDate:self.workout.endDate];
        startingDateLabel.text = [[formatter stringFromDate:startedDate] lowercaseString];
        endDateLabel.text = [[formatter stringFromDate:self.workout.endDate] lowercaseString];
        durationLabel.text = [NSString stringWithFormat:@"%i minutes", self.workout.totalTime.intValue];
        
    }else if (indexPath.row == 3){
        UILabel *label = [[UILabel alloc] initWithFrame:cell.frame];
        [self correctFrame:label with:cell];
        
        label.textAlignment = NSTextAlignmentCenter;
       
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
        NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:self.workout.calories.intValue]];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:24];
        label.text = [NSString stringWithFormat:@"%@ calories burned", formatted];
        [cell addSubview:label];
        
    }else if (indexPath.row == 4){
        cell = [tableView dequeueReusableCellWithIdentifier:@"bpmCell"];
        
        UILabel *minBPM = (UILabel *)[cell viewWithTag:500];
        UILabel *averageBPM = (UILabel *)[cell viewWithTag:501];
        UILabel *maxBPM = (UILabel *)[cell viewWithTag:502];
        
        maxBPM.textAlignment = NSTextAlignmentRight;
        minBPM.textAlignment = NSTextAlignmentLeft;
        averageBPM.textAlignment = NSTextAlignmentCenter;
        
        int max = 0;
        int min = 220;
        
        for (NSNumber *bpm in self.workout.bpmAverageArray) {
            if (bpm.intValue > max) max = bpm.intValue;
            if (bpm.intValue < min) min = bpm.intValue;
        }
        
        maxBPM.text = [NSString stringWithFormat:@"%i max", max];
        minBPM.text = [NSString stringWithFormat:@" %i min", min];
        averageBPM.text = [NSString stringWithFormat:@"%i average", self.workout.averageBPM.intValue];
        
    }else if (indexPath.row == 4){

    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1){
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat value = 50;
    
    if (indexPath.row == 0){
        value = 0;
    }else if (indexPath.row == 2){
        value = 340;
    }else if (indexPath.row == 1){
        value = 60;
    }else if (indexPath.row == 3){
        value = 100;
    }else if (indexPath.row == 5){
        value = 50;
    }else if (indexPath.row == 4){
        value = 50;
    }
    
    return value;
}

- (void) correctFrame:(UILabel *)label with:(UITableViewCell *)cell{
    CGRect frame = label.frame;
    frame.size.width = self.view.frame.size.width;
    frame.origin.y = 26;
    label.frame = frame;
}

- (void) setupGraph:(UITableViewCell *)cell{
    BEMSimpleLineGraphView *lineGraphView = nil;
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 340);
    lineGraphView = [[BEMSimpleLineGraphView alloc] initWithFrame:frame];
    
    lineGraphView.enableBezierCurve = YES;
    lineGraphView.enablePopUpReport = YES;
    lineGraphView.enableTouchReport = YES;
    lineGraphView.enableXAxisLabel = YES;
    lineGraphView.enableYAxisLabel = YES;
    lineGraphView.enableReferenceXAxisLines = YES;
    lineGraphView.enableReferenceYAxisLines = YES;
    lineGraphView.animationGraphStyle = BEMLineAnimationNone;
    lineGraphView.alpha = .7;
    
    lineGraphView.delegate = self;
    lineGraphView.dataSource = self;
    [cell addSubview:lineGraphView];
    [lineGraphView reloadGraph];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
