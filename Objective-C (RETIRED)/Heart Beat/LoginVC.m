//
//  LoginVC.m
//  Heart Beat
//
//  Created by inailuy on 2/12/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import "LoginVC.h"
#import <FacebookSDK/FacebookSDK.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <Bolts/Bolts.h>
#import "HistoryVC.h"
#import "SettingVC.h"
#import "AppDelegate.h"

@interface LoginVC ()

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *anonymousButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *loginButton;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Login";
    
    // Do any additional setup after loading the view.
//    FBLoginView *loginView = [[FBLoginView alloc] init];
//    loginView.center = self.view.center;
//    [self.view addSubview:loginView];
//    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
//    // Optional: Place the button in the center of your view.
//    loginButton.center = self.view.center;
//    [self.view addSubview:loginButton];
    
    [self updateButtonsDisplay];
}

-(void)viewDidAppear:(BOOL)animated{
//    if (self.facebookButton){
//        self.facebookButton.readPermissions = @[@"email"];;
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gestrueRecognizedDown:(id)sender {
   // [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)FBloginButtonPressed:(id)sender {
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             NSLog(@"Logged in");
             NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
             [parameters setValue:@"id,name,email" forKey:@"fields"];
             
             [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
              startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                           id result, NSError *error) {
                  NSLog(@"%@", result);
                  
                  
                  
                  [[AppDelegate instance] refreashLocalParse];
                  [self dismissViewControllerAnimated:YES completion:nil];
              }];
             [self performLoginAction];
             [self dismissViewControllerAnimated:YES completion:nil];
         }
         [self dismissViewControllerAnimated:YES completion:nil];
     }];
}

- (IBAction)twitterloginButtonPressed:(id)sender {
//    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
//        if (!user) {
//            NSLog(@"Uh oh. The user cancelled the Twitter login.");
//            return;
//        } else if (user.isNew) {
//            [self enableHealthKit:@NO];
//            NSLog(@"User signed up and logged in with Twitter!");
//            [self performLoginAction];
//            [self dismissViewControllerAnimated:YES completion:nil];
//        } else {
//            NSLog(@"User logged in with Twitter!");
//            [self enableHealthKit:@NO];
//            if (![PFTwitterUtils isLinkedWithUser:user]) {
//                [PFTwitterUtils linkUser:user block:^(BOOL succeeded, NSError *error) {
//                    if ([PFTwitterUtils isLinkedWithUser:user]) {
//                        NSLog(@"Woohoo, user logged in with Twitter!");
//                    }
//                }];
//            }
//            [self performLoginAction];
//        }
//    }];
}

- (IBAction)anonymousLoginButtonPressed:(id)sender {
    /*
    [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (error) {
            NSLog(@"Anonymous login failed.");
        } else {
            NSLog(@"Anonymous user logged in.");
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
     */
}

- (void)performSignupAction {
//    PFUser *user = [PFUser user];
//    user.email = @"email@example.com";
//    
//    // other fields can be set just like with PFObject
//    //user[@"phone"] = @"415-392-0202";
//    
//    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (!error) {   // Hooray! Let them use the app now.
//        } else {   NSString *errorString = [error userInfo][@"error"];   // Show the errorString somewhere and let the user try again.
//            NSLog(@"%@", errorString);
//        }
//    }];

    /*
    NSArray *permissions = @[@"public_profile", @"email"];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
        } else {
            NSLog(@"User logged in through Facebook!");
        }
    }];
     */
}

- (void)performLoginAction{
    /*
    PFQuery *query = [PFQuery queryWithClassName:@"Workout"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"username" equalTo:[PFUser currentUser].username];
    // Query for new results from the network
    [[query findObjectsInBackground] continueWithSuccessBlock:^id(BFTask *task) {
        return [[PFObject unpinAllObjectsInBackground] continueWithSuccessBlock:^id(BFTask *ignored) {
            // Cache the new results.
            UINavigationController *nc = [AppDelegate instance].swipeBetweenVC.viewControllers[0];
            HistoryVC *vc = nc.viewControllers[0];
            vc.objects = task.result;
            [vc.dictionary removeAllObjects];
            vc.dictionaryKeys = [NSArray array];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"MM/dd/yyyy";
            
            for (PFObject *workout in task.result) {
                NSString *key = [formatter stringFromDate:workout.createdAt];
                if ([vc.dictionary objectForKey:key]){
                    NSMutableArray *array = [vc.dictionary objectForKey:key];
                    [array addObject:workout];
                    [vc.dictionary setObject:array forKey:key];
                }else{
                    NSMutableArray *array = [NSMutableArray arrayWithObject:workout];
                    [vc.dictionary setObject:array forKey:key];
                }
            }
            vc.dictionaryKeys = [vc.dictionary.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"MM/dd/yyyy"];
                NSDate *d1 = [df dateFromString:(NSString*) obj1];
                NSDate *d2 = [df dateFromString:(NSString*) obj2];
                return [d2 compare: d1];
            }];
            NSLog(@"%lu", (unsigned long)vc.objects.count);
            [vc.tableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            return [PFObject pinAllInBackground:task.result];
        }];
    }];
    */
    
    [[AppDelegate instance] refreashLocalParse];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)logoutPressed:(id)sender {
    /*
    [PFObject unpinAllObjectsInBackground];
    [PFUser logOut];
     */
    [self updateButtonsDisplay];
}

- (void) updateButtonsDisplay{
   // self.facebookButton.hidden = self.twitterButton.hidden = self.anonymousButton.hidden = [PFUser currentUser].isAuthenticated;
   // self.logoutButton.hidden = ![PFUser currentUser].isAuthenticated;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData"
                                                        object:nil];
}

- (void)enableHealthKit:(NSNumber *)boolNum{
#ifdef DEBUG
    [[NSUserDefaults standardUserDefaults] setValue:boolNum forKey:@"isHealthKitEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
    
    UINavigationController *nc = [AppDelegate instance].swipeBetweenVC.viewControllers.lastObject;
    SettingVC *vc = nc.viewControllers.lastObject;
    [vc updateHealthSwitch];
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
