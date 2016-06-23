//
//  HistoryVC.m
//  Heart Beat
//
//  Created by inailuy on 2/11/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import "HistoryVC.h"
#import "WorkoutSummaryVC.h"
#import "AppDelegate.h"
#import "CloudManager.h"

@interface HistoryVC ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, CloudManagerDelegate>

@property (strong, nonatomic) NSIndexPath *indexPathSelected;

@end

@implementation HistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"history";
    
    if (!self.objects) self.objects = [NSMutableArray array];
    self.dictionary = [NSMutableDictionary dictionary];

    [self reloadDatabase];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(longPressTableViewCell:)];
    lpgr.minimumPressDuration = .45; //seconds
    [self.tableview addGestureRecognizer:lpgr];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadDatabase)
                                                 name:@"ReloadData"
                                               object:nil];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableview.separatorColor = [UIColor grayColor];
    
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
//                                   initWithTitle:@"·    "
//                                   style:UIBarButtonItemStylePlain
//                                   target:self
//                                   action:@selector(backButtonPressed)];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 25, 25)];
    [btn setImage:[UIImage imageNamed:@"heartNav.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = btnBack;
}

- (void) backButtonPressed{
    YZSwipeBetweenViewController *swipeBetweenVC = [AppDelegate instance].swipeBetweenVC;
    [swipeBetweenVC scrollToViewControllerAtIndex:1 animated:YES];
}

- (void) reloadDatabase {
    /*
    NSString *user = [PFUser currentUser].username;
    if (user){
        PFQuery *query = [PFQuery queryWithClassName:@"Workout"];
        [query orderByDescending:@"createdAt"];
        [query whereKey:@"username" equalTo:user];
        //[query fromLocalDatastore];
        [[query findObjectsInBackground] continueWithBlock:^id(BFTask *task){
            if (task.error) {
                // something went wrong;
                NSLog(@"reloadDatabase - %@", task.error.localizedDescription);
                return task;
            }
            self.dictionaryKeys = [NSArray array];
            [self.dictionary removeAllObjects];
            self.objects = task.result;
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"MM/dd/yyyy";
            for (PFObject *workout in self.objects) {
                NSString *key = [formatter stringFromDate:workout.createdAt];
                if (!key) key = [formatter stringFromDate:workout[@"endDate"]];
                if ([self.dictionary objectForKey:key]){
                    NSMutableArray *array = [self.dictionary objectForKey:key];
                    [array addObject:workout];
                    [self.dictionary setObject:array forKey:key];
                }else{
                    NSMutableArray *array = [NSMutableArray arrayWithObject:workout];
                    [self.dictionary setObject:array forKey:key];
                }
            }
            self.dictionaryKeys = [self.dictionary.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"MM/dd/yyyy"];
                NSDate *d1 = [df dateFromString:(NSString*) obj1];
                NSDate *d2 = [df dateFromString:(NSString*) obj2];
                return [d2 compare: d1];
            }];
            NSLog(@"task results %lu", (unsigned long)self.objects.count);
            [self.tableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            return task;
        }];
    }
   */
    
    CloudManager *manager = [CloudManager sharedManagerWithDelegate:self];
    [manager fetchAllFromPrivateCloudwithRecordType:kWorkOutRecordName];
    
}

- (void)viewWillAppear:(BOOL)animated{
        self.view.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gestureRecognized:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)hide{
   [self dismissViewControllerAnimated:YES completion:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    cell.backgroundColor = [UIColor  colorWithWhite:.9 alpha:.4];
    
    if (self.dictionaryKeys.count == 0){
        return cell;
    }
    
    NSString *key = self.dictionaryKeys[indexPath.section];
    NSArray *array = self.dictionary[key];
    if (array.count > indexPath.row){
        //
        WorkoutObject *workout = array[indexPath.row];
        
        //    NSNumber *caloriesBurned = workout[@"caloriesBurned"];
        NSString *workoutType = workout.workoutType;
        NSNumber *totalTime = workout.totalTime;
        NSNumber *bpm = workout.averageBPM;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:30];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15];
        cell.textLabel.text = [NSString stringWithFormat:@"     %i min", totalTime.intValue];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"       %@  -  %ibpm", workoutType, bpm.intValue];
         //
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.dictionaryKeys[section];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.indexPathSelected = indexPath;
    [self performSegueWithIdentifier: @"workoutSummarySegue" sender: self];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *key = self.dictionaryKeys[section];
    NSArray *array = self.dictionary[key];
    return array.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dictionaryKeys.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
//
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:headerView.frame];
    NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentJustified;
    style.firstLineHeadIndent = 10.0f;
    style.headIndent = 20.0f;
    style.tailIndent = -10.0f;
    
    if (self.dictionaryKeys.count == 0) return nil;
    
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:self.dictionaryKeys[section] attributes:@{ NSParagraphStyleAttributeName : style}];
    label.numberOfLines = 0;
    label.attributedText = attrText;
    label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:20];
    
    [headerView addSubview:label];
    headerView.backgroundColor = [UIColor colorWithWhite:.7 alpha:.35];
    return headerView;
}
//

//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
//    return self.objects.count;
//}

// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        //add code here for when you hit delete
//        PFObject *workout = self.objects[indexPath.row];
//        [workout deleteInBackground];
//        [self.objects removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
//}

- (void)longPressTableViewCell:(UILongPressGestureRecognizer *)gestureRecognizer
{
    //#ifdef DEBUG
    //Container *container;
    CGPoint p = [gestureRecognizer locationInView:self.tableview];
    
    NSIndexPath *indexPath = [self.tableview indexPathForRowAtPoint:p];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        if (indexPath == nil)
        {
#ifdef DEBUG
            NSLog(@"long press on table view but not on a row");
#endif
        }
        else
        {
            //
            if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue] >= 6)
            {
                self.indexPathSelected = indexPath;
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
                [actionSheet showInView:self.view];
            }
            //
        }
    }
    //#endif
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        NSString *key = self.dictionaryKeys[self.indexPathSelected.section];
        NSMutableArray *array = self.dictionary[key];
        
        // Sorting WorkoutObjects
        WorkoutObject *workout= array[self.indexPathSelected.row];
        CKRecord *corerctRecord = nil;
        for (CKRecord *record in self.objects) {
            NSDate * date1 = record[@"endDate"];
            NSDate * date2 = workout.endDate;
        
            if ([date1 compare:date2] == NSOrderedDescending || [date1 compare:date2] == NSOrderedAscending) {
                // Record do not match
            }else {
                corerctRecord = record;
                break;
            }
        }
        
        if (corerctRecord){
            CloudManager *manager = [CloudManager sharedManagerWithDelegate:self];
            [manager deleteRecordToPrivate:corerctRecord];
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [self.tableview deselectRowAtIndexPath:self.indexPathSelected animated:NO];
    
    WorkoutSummaryVC *vc = segue.destinationViewController;
    
    NSString *key = self.dictionaryKeys[self.indexPathSelected.section];
    NSArray *array = self.dictionary[key];
    vc.workoutSummary = array[self.indexPathSelected.row];
    self.view.hidden = YES;
}

#pragma mark - CloudManagerDelegate -

-(void)finishedFetchingItems:(NSArray *)results fromQuery:(CKQuery *)query andZoneID:(CKRecordZoneID *)zoneID{
    if (results){
        self.dictionaryKeys = results;

        //self.dictionaryKeys = [NSArray array];
        [self.dictionary removeAllObjects];
        self.objects = results.mutableCopy;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy";
        for (CKRecord *record in self.objects) {
            WorkoutObject *workout = [WorkoutObject createWorkoutObjectFromRecord:record];
            
            NSLog(@"%@", workout.class);
            NSString *key = [formatter stringFromDate:workout.endDate];
            if (!key) key = [formatter stringFromDate:workout.endDate];
            if ([self.dictionary objectForKey:key]){
                NSMutableArray *array = [self.dictionary objectForKey:key];
                [array addObject:workout];
                [self.dictionary setObject:array forKey:key];
            }else{
                NSMutableArray *array = [NSMutableArray arrayWithObject:workout];
                [self.dictionary setObject:array forKey:key];
            }
        }
        self.dictionaryKeys = [self.dictionary.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"MM/dd/yyyy"];
            NSDate *d1 = [df dateFromString:(NSString*) obj1];
            NSDate *d2 = [df dateFromString:(NSString*) obj2];
            return [d2 compare: d1];
        }];
        NSLog(@"task results %lu", (unsigned long)self.objects.count);
        [self.tableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

- (void)reloadUI{
    CloudManager *manager = [CloudManager sharedManagerWithDelegate:self];
    [manager fetchAllFromPrivateCloudwithRecordType:kWorkOutRecordName];
}



@end
