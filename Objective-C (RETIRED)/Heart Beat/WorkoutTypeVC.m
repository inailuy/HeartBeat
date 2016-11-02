//
//  WorkoutTypeVC.m
//  Heart Beat
//
//  Created by inailuy on 2/22/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import "WorkoutTypeVC.h"

@interface WorkoutTypeVC ()<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray *modifiedArray;
@property (strong, nonatomic) NSMutableArray *favoriteWorkouts;

@end

@implementation WorkoutTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *hideButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"hide"
                                      style:UIBarButtonItemStyleDone
                                      target:self
                                      action:@selector(hideButtonPressed)];
    self.navigationItem.rightBarButtonItem = hideButton;
    self.modifiedArray = self.workoutTypesArray.mutableCopy;
    
    self.title = @"Workout Types";
    [self.searchBar becomeFirstResponder];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteWorkouts"]){
        [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"favoriteWorkouts"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    self.favoriteWorkouts = [[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteWorkouts"];
    self.favoriteWorkouts = self.favoriteWorkouts.mutableCopy;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)hideButtonPressed{
    [self.view.window endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view.window endEditing:YES];
}


#pragma mark - TableView Delegate/DataSource -

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    if (indexPath.section == 1  || self.favoriteWorkouts.count == 0){
        cell.textLabel.text = self.modifiedArray[indexPath.row];
    }else{
        NSNumber *numIndex = self.favoriteWorkouts[indexPath.row];
        cell.textLabel.text = self.modifiedArray[numIndex.intValue];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view.window endEditing:YES];
    NSUInteger index = 0;
    if (self.favoriteWorkouts.count > 0 && indexPath.section == 0){
        index = ((NSNumber *)self.favoriteWorkouts[indexPath.row]).integerValue;
        NSLog(@"%@", self.workoutTypesArray[index]);
    }else{
        index = [self.workoutTypesArray indexOfObject:self.modifiedArray[indexPath.row]];
    }
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLong:index] forKey:@"workoutType"];

    [((BaseVC *)self.delegate) updateWorkoutType];
    
    
    [self saveFavoritesArrayWithIndex:index];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSUInteger returnValue = self.modifiedArray.count;
    if (section == 0 && self.favoriteWorkouts.count){
        returnValue = self.favoriteWorkouts.count;
    }
    return  returnValue;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger returnValue = 1;
    if (self.favoriteWorkouts.count){
        returnValue = 2;
    }
    return returnValue;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
    UILabel *label = [[UILabel alloc] initWithFrame:headerView.frame];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0];
    NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentJustified;
    style.firstLineHeadIndent = 10.0f;
    style.headIndent = 20.0f;
    style.tailIndent = -10.0f;
    
    NSString *title = @"";
    switch (section) {
        case 0:
            title = @"Most Recent";
            break;
        case 1:
            title = @"All Workouts";
        default:
            break;
    }
    if (tableView.numberOfSections == 1) title = @"All Workouts";
    
    
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:title attributes:@{ NSParagraphStyleAttributeName : style}];
    label.numberOfLines = 0;
    label.attributedText = attrText;
    label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:16];
    
    [headerView addSubview:label];
    headerView.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
    return headerView;
}

#pragma mark - SearchBar Delegate -

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText isEqualToString:@""]){
        self.favoriteWorkouts = [[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteWorkouts"];
        self.favoriteWorkouts = self.favoriteWorkouts.mutableCopy;
        self.modifiedArray = self.workoutTypesArray.mutableCopy;
        [self.tableview reloadData];
        return;
    }else{
        [self.favoriteWorkouts removeAllObjects];
    }
    
    self.modifiedArray = [NSMutableArray array];
    for (NSString *workout in self.workoutTypesArray) {
        searchText = [searchText lowercaseString];
        if ([workout containsString:searchText]) {
            [self.modifiedArray addObject:workout];
        }
    }
    [self.tableview reloadData];
}

- (void) saveFavoritesArrayWithIndex:(NSUInteger)index {
    NSNumber *numIndex = [NSNumber numberWithInteger:index];
    
    self.favoriteWorkouts = [[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteWorkouts"];
    self.favoriteWorkouts = self.favoriteWorkouts.mutableCopy;
    
    if (![self.favoriteWorkouts containsObject:numIndex]){
        if (self.favoriteWorkouts.count > 2){
            [self.favoriteWorkouts removeObjectAtIndex:0];
        }
        [self.favoriteWorkouts addObject:numIndex];
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.favoriteWorkouts forKey:@"favoriteWorkouts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
