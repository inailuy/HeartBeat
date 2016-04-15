//
//  BaseVC.m
//  Heart Beat
//
//  Created by inailuy on 2/21/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import "BaseVC.h"
#import "WorkoutTypeVC.h"

@interface BaseVC ()

@end

@implementation BaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!self.healthStore) self.healthStore = [AppDelegate instance].healthStore;
    if (!self.workoutTypesArray) self.workoutTypesArray = [self workoutTypesArraySetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"workoutTypeSegue"]) {
        UINavigationController *nc = segue.destinationViewController;
        WorkoutTypeVC *vc = nc.viewControllers.lastObject;
        vc.delegate = segue.sourceViewController;
    }
}

- (void) updateWorkoutType{
    
}

@end
