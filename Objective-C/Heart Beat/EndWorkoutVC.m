//
//  EndWorkoutVC.m
//  Heart Beat
//
//  Created by inailuy on 3/6/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import "EndWorkoutVC.h"
#import "BEMSimpleLineGraphView.h"
#import "CloudManager.h"

@interface EndWorkoutVC ()<BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource, CloudManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *blurView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *timeLAbel;
@property (weak, nonatomic) IBOutlet UILabel *averageBPMLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloriesBurned;
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *lineGraphView;

@property (nonatomic, strong) NSMutableArray *modifiedBpmAverage;
@property (nonatomic) float averageBPM;
@property (nonatomic) float minutes;
@property (nonatomic) int count;

@end

@implementation EndWorkoutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
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
    
    NSNumber *averageBPM = self.workoutSummary.averageBPM;
    NSNumber *calories = self.workoutSummary.calories;
    
    self.modifiedBpmAverage = self.workoutSummary.bpmAverageArray.mutableCopy;
    self.averageBPMLabel.text = [NSString stringWithFormat:@"%i average bpm", averageBPM.intValue];
    self.caloriesBurned.text = [NSString stringWithFormat:@"%i calories burned", calories.intValue];
    self.timeLAbel.text = self.timeString;
    
    [self.lineGraphView reloadGraph];
    
    CKRecord *record = self.workoutSummary.createRecordFromWorkoutObject;
    CloudManager *manager = [CloudManager sharedManagerWithDelegate:nil];
    [manager saveRecordToPrivate:record];
}

-(void)viewWillAppear:(BOOL)animated{
        [self.mapView setRegion:self.region animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteButtonPressed:(id)sender {
   /*
    [self.workoutSummary deleteInBackground];
    [self dismissView];
    */
}

- (IBAction)saveButtonPressed:(id)sender {
    CloudManager *manager = [CloudManager sharedManagerWithDelegate:nil];
    [manager fetchAllFromPrivateCloudwithRecordType:kWorkOutRecordName];
    
    [self dismissView];
}

- (void) dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BEMSimpleLineGraphView DataSource/Delegates -

-(NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph{
    return self.modifiedBpmAverage.count;
}

//- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index
//{
//    if (!self.count) self.count = 0;
//    
//    self.count++;
//    float position = (float)index / (float)self.modifiedBpmAverage.count;
//    float duration = self.minutes;
//    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
//    [formatter setMaximumFractionDigits:0];
//    float result = position * duration;
//    
//    int seconds = fmod(result, 1.0)*60;
//    int minutes = (int)result;
//    NSString *returnString = [NSString stringWithFormat:@"%02d:%i", minutes, seconds];
//    
//    if (self.minutes > 15){
//        returnString = [formatter stringFromNumber:[NSNumber numberWithFloat:result]];
//    }
//    return returnString;
//}


- (NSInteger)numberOfYAxisLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph{
    return 5;
}

//- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
//    float var = self.minutes > 7 ? .16 : .25;
//    return self.modifiedBpmAverage.count * var; // The number of hidden labels between each displayed label.
//}

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

//- (void) updateWorkoutType {
//    NSNumber *indexNum = [[NSUserDefaults standardUserDefaults] valueForKey:@"workoutType"];
//    int index = indexNum.intValue;
//    NSString *workoutType = self.workoutTypesArray[index];
//    if (!workoutType) workoutType = @"workout type";
//    [self.workoutTypeButton setTitle:workoutType forState:UIControlStateNormal];
//    
//    if (index == HKWorkoutActivityTypeWalking || index == HKWorkoutActivityTypeRunning ||
//        index ==  HKWorkoutActivityTypeHiking ||index ==  HKWorkoutActivityTypeCycling){
//        [self.locationManager startUpdatingLocation];
//        self.mapView.showsUserLocation = YES;
//        self.distanceLabel.hidden = NO;
//    }else{
//        if (self.seconds < 120){
//            self.mapView.showsUserLocation = NO;
//            self.distanceLabel.hidden = YES;
//            [self.locationManager stopUpdatingLocation];
//        }
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
