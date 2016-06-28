//
//  SettingVC.m
//  Heart Beat
//
//  Created by inailuy on 2/11/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import "SettingVC.h"
#import "HKHealthStore+AAPLExtensions.h"
#import "YZSwipeBetweenViewController.h"
#import "SettingsTableViewCell.h"
#import "MainVC.h"

#define IDENTIFIER_TEXTFIELD @"textfieldCell"
#define IDENTIFIER_SWTICH @"switchCell"
#define IDENTIFIER_SEGMENTED_SEX @"segmentedCellSex"
#define IDENTIFIER_SEGMENTED_METRIC @"segmentedCellMetric"
#define IDENTIFIER_NORMAL @"normalCell"

#define TAG_SWITCH 100
#define TAG_SEGEMENTED 101
#define TAG_TEXTFIELD 102

@interface SettingVC ()<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *pickerArray;
@property (nonatomic, strong) NSNumber *pickerSelected;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"settings";
    
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"age"] isEqual:[NSNumber numberWithInt:0]])
        self.age = ((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"age"]).intValue;
    self.sex = ((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"sex"]).boolValue;
    self.debugMode = ((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"debugMode"]).boolValue;
    self.healthKit = ((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"isHealthKitEnabled"]).boolValue;
    self.pickerSelected = ((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"speechUtterance"]);
    self.metric = ((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"isUsingMetricSystem"]).boolValue;

    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"weight"] isEqual:[NSNumber numberWithInt:0]]){
        if (self.metric == 0){
            float wieght = ((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"weight"]).floatValue;
            self.weight = wieght*2.20462;
        }else{
            self.weight = ((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"weight"]).floatValue;
        }
    }
    
    if (!self.pickerArray) self.pickerArray = @[@0, @1, @2, @5, @10, @20, @30];
    [self updateUsersAgeLabel];
    [self updateUsersWeight];


    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 25, 25)];
    [btn setImage:[UIImage imageNamed:@"heartNav.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = btnBack;
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

-(void)viewWillAppear:(BOOL)animated{
    self.view.hidden = NO;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view.window endEditing:YES];
}

- (void) backButtonPressed{
    YZSwipeBetweenViewController *swipeBetweenVC = [AppDelegate instance].swipeBetweenVC;
    [swipeBetweenVC scrollToViewControllerAtIndex:1 animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissButtonPressed:(UIButton *)sender {
    [self saveData];
}

- (IBAction)gestureRecognized:(id)sender {
    UISwipeGestureRecognizer *g = sender;
    if (self.pickerView && self.pickerView.frame.origin.y != self.view.frame.size.height &&
        (([sender isKindOfClass:[UISwipeGestureRecognizer class]] && g.direction == UISwipeGestureRecognizerDirectionDown) ||
         [sender isKindOfClass:[UITapGestureRecognizer class]])){
        [UIView animateKeyframesWithDuration:0.5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModePaced animations:^{
            CGRect frame = self.pickerView.frame;
            frame.origin.y = self.view.frame.size.height;
            self.pickerView.frame = frame;
            [self saveData];
        }completion:nil];
    }else if ([sender isKindOfClass:[UISwipeGestureRecognizer class]] && g.direction == UISwipeGestureRecognizerDirectionDown){
        [self saveData];
    }
    
    [self.view.window endEditing:YES];
}

- (void) saveData{
    if (self.age > 0  && self.weight > 0){
        float weight = (self.metric == 0) ? self.weight * 0.453592 : self.weight;
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:weight] forKey:@"weight"];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:self.age] forKey:@"age"];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:self.sex] forKey:@"sex"];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:self.metric] forKey:@"isUsingMetricSystem"];
        [[NSUserDefaults standardUserDefaults] setValue:self.pickerSelected forKey:@"speechUtterance"];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:self.debugMode] forKey:@"debugMode"];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:self.healthKit] forKey:@"isHealthKitEnabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (IBAction)debugSwitchPressed:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:sender.on] forKey:@"debugMode"];
    [self saveData];
}

- (IBAction)healthKitSwitchPressed:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:sender.on] forKey:@"isHealthKitEnabled"];
    [self saveData];
}

- (IBAction)audioCuesButtonPressed:(id)sender {
    if (!self.pickerView){
        self.pickerView = [UIPickerView new];
        self.pickerView.delegate = self;
        self.pickerView.backgroundColor = [UIColor grayColor];
        NSUInteger index = [self.pickerArray indexOfObject:self.pickerSelected];
        if (self.pickerArray.count > index)
            [self.pickerView selectRow:index inComponent:0 animated:NO];
    }
    CGRect frame = self.pickerView.frame;
    frame.origin = CGPointMake(0, self.view.frame.size.height);
    self.pickerView.frame = frame;
    [self.view addSubview:self.pickerView];
    [UIView animateKeyframesWithDuration:0.5 delay:0.2 options:UIViewKeyframeAnimationOptionCalculationModePaced animations:^{
        CGRect frame = self.pickerView.frame;
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        self.pickerView.frame = frame;
        [self saveData];
    }completion:nil];
    
}

- (IBAction)segmentSwitched:(UISegmentedControl *)sender {
    [self updateUsersWeight];
    [self saveData];
}

- (void) updateHealthSwitch{
    self.healthKit = ((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"isHealthKitEnabled"]).boolValue;
    [self.tableView reloadData];
}

#pragma mark - Healthkit -

- (void)updateUsersAgeLabel {
    // Set the user's age unit (years).
    //self.ageUnitLabel.text = NSLocalizedString(@"Age (yrs)", nil);
    
    NSError *error;
    NSDate *dateOfBirth = [self.healthStore dateOfBirthWithError:&error];
    
    if (!dateOfBirth) {
        NSLog(@"Either an error occured fetching the user's age information or none has been stored yet. In your app, try to handle this gracefully.");
        
        //self.ageValueLabel.text = NSLocalizedString(@"Not available", nil);
    }
    else {
        // Compute the age of the user.
        NSDate *now = [NSDate date];
        
        NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:dateOfBirth toDate:now options:NSCalendarWrapComponents];
        
        NSUInteger usersAge = [ageComponents year];
        self.age = (int)usersAge;
        //self.ageValueLabel.text = [NSNumberFormatter localizedStringFromNumber:@(usersAge) numberStyle:NSNumberFormatterNoStyle];
    }
}

- (void)updateUsersWeight {
    // Fetch the user's default weight unit in pounds.
    NSMassFormatter *massFormatter = [[NSMassFormatter alloc] init];
    massFormatter.unitStyle = NSFormattingUnitStyleLong;
    
    // Query to get the user's latest weight, if it exists.
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    [self.healthStore aapl_mostRecentQuantitySampleOfType:weightType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        if (!mostRecentQuantity) {
            NSLog(@"Either an error occured fetching the user's weight information or none has been stored yet. In your app, try to handle this gracefully.");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //self.weightLabel.text = NSLocalizedString(@"Not available", nil);
            });
        }
        else {
            // Determine the weight in the required unit.
            BOOL metric = ((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"isUsingMetricSystem"]).boolValue;
            HKUnit *weightUnit = metric ? [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo] : [HKUnit poundUnit];
            double usersWeight = [mostRecentQuantity doubleValueForUnit:weightUnit];
            // Update the user interface.
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *wieght = [NSNumberFormatter localizedStringFromNumber:@(usersWeight) numberStyle:NSNumberFormatterNoStyle];
                self.weight = wieght.intValue;
                [self.tableView reloadData];
            });
        }
    }];
}

#pragma mark - UIPickerView DataSource/Delegate -

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerArray.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSNumber *number = self.pickerArray[row];
    return number.stringValue;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.pickerSelected = self.pickerArray[row];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self saveData];
}

#pragma mark - UITableView DataSource/Delegate -

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   NSString *title = @"";
    NSString *reuseID = @"";
    BOOL itemBool;
    NSString *text = @"";
    
    if (indexPath.section == 0 && indexPath.row == 0){
        title = @"Age";
        reuseID = IDENTIFIER_TEXTFIELD;
        text = [NSString stringWithFormat:@"%i", self.age];
    }else if (indexPath.section == 0 && indexPath.row == 1){
        title = @"Weight";
        reuseID = IDENTIFIER_TEXTFIELD;
        text = [NSString stringWithFormat:@"%i", (int)self.weight];
    }else if (indexPath.section == 0 && indexPath.row == 2){
        title = @"Sex";
        reuseID = IDENTIFIER_SEGMENTED_SEX;
        itemBool = self.sex;
    }else if (indexPath.section == 1 && indexPath.row == 0){
        title = @"Units";
        reuseID = IDENTIFIER_SEGMENTED_METRIC;
        itemBool = self.metric;
    }else if (indexPath.section == 1 && indexPath.row == 1){
        title = @"Health App";
        reuseID = IDENTIFIER_SWTICH;
        itemBool = self.healthKit;
    }else if (indexPath.section == 1 && indexPath.row == 2){
        title = @"Audio Cues";
        reuseID = IDENTIFIER_NORMAL;
    }else if (indexPath.section == 1 && indexPath.row == 3){
        title = @"Connect Hardware";
        reuseID = IDENTIFIER_NORMAL;
    }else if (indexPath.section == 2 && indexPath.row == 0){
        title = @"Debug Mode";
        reuseID = IDENTIFIER_SWTICH;
    }else if (indexPath.section == 2 && indexPath.row == 1){
        title = @"Log Out";
        reuseID = IDENTIFIER_NORMAL;
        itemBool = self.debugMode;
    }
    
    SettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    cell.delegate = self;
    if ([reuseID isEqualToString:IDENTIFIER_NORMAL] ||
        [reuseID isEqualToString:IDENTIFIER_TEXTFIELD]){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if ([cell.reuseIdentifier isEqual:IDENTIFIER_TEXTFIELD]){
        cell.textfield.text = text;
    }else if ([cell.reuseIdentifier isEqual:IDENTIFIER_SWTICH]){
        cell.switchCell.on = itemBool;
    }else if ([cell.reuseIdentifier isEqual:IDENTIFIER_SEGMENTED_METRIC] ||
              [cell.reuseIdentifier isEqual:IDENTIFIER_SEGMENTED_SEX]){
        cell.segementedControl.selectedSegmentIndex = itemBool;
    }
    
    cell.backgroundColor = [UIColor  colorWithWhite:.9 alpha:.4];
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:22.0];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SettingsTableViewCell *cell = (SettingsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:IDENTIFIER_TEXTFIELD]){
        [cell.textfield becomeFirstResponder];
    }else if ([indexPath isEqual:[NSIndexPath indexPathForRow:2 inSection:1]]){
        [self performSegueWithIdentifier:@"audioSegue" sender:self];
    }else if ([indexPath isEqual:[NSIndexPath indexPathForRow:3 inSection:1]]){
        if ([AppDelegate instance].isPeripheralConnected){
            [[AppDelegate instance] disconnectPeripheral];
        }else{
            [[AppDelegate instance] connectPeripheral];
        }
    }else if ([indexPath isEqual:[NSIndexPath indexPathForRow:1 inSection:2]]){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to log out?"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Log Out"
                                                        otherButtonTitles:nil];
        [actionSheet showInView:self.view];
    }else if ([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:2]]){
        // DEBUG tableviewCell
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int sect = 0;
    if (section == 0){
        sect = 3;
    }else if (section == 1){
        sect = 4;
    }else if (section == 2){
        sect = 2;
    }
    return sect;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    UILabel *label = [[UILabel alloc] initWithFrame:headerView.frame];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0];
    NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentJustified;
    style.firstLineHeadIndent = 10.0f;
    style.headIndent = 20.0f;
    style.tailIndent = -10.0f;
    
    NSString *title = @"Personal Info";
    switch (section) {
        case 1:
            title = @"App Details";
            break;
        case 2:
            title = @"Other";
        default:
            break;
    }
    
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:title attributes:@{ NSParagraphStyleAttributeName : style}];
    label.numberOfLines = 0;
    label.attributedText = attrText;
    label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:20];
    
    [headerView addSubview:label];
    headerView.backgroundColor = [UIColor colorWithWhite:.7 alpha:.35];
    return headerView;
}

#pragma mark - UIActionSheetDelegate -

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){ // Pressed Log Out
        //[PFObject unpinAllObjectsInBackground];
       // [PFUser logOut];
        
        UINavigationController *nc = [AppDelegate instance].swipeBetweenVC.viewControllers[1];
        MainVC *vc = nc.viewControllers.lastObject;
        [vc performLoginOperation];
        [[AppDelegate instance].swipeBetweenVC scrollToViewControllerAtIndex:1];
    }
}

//
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    self.view.hidden = YES;
}
//

@end
