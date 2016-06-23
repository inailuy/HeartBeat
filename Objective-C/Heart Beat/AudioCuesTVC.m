//
//  AudioCuesTVC.m
//  Heart Beat
//
//  Created by inailuy on 3/13/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import "AudioCuesTVC.h"

@interface AudioCuesTVC ()

@property (nonatomic, strong) NSArray *minutesArray;
@property (nonatomic, strong) NSArray *typesArray;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSNumber *numberSelected;
@property (nonatomic, strong) NSMutableArray *cuesArray;

@end

@implementation AudioCuesTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"Audio Cues";
    self.numberSelected = ((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"speechUtterance"]);
    if (!self.minutesArray) self.minutesArray = @[@0, @1, @2, @5, @10, @20, @30];
    if (!self.typesArray) self.typesArray = @[@"Elapsed Time", @"Current Heartbeat", @"Average Heartbeat", @"Calories Burned"];
    NSUInteger index = [self.minutesArray indexOfObject:self.numberSelected];
    self.selectedIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    self.view.backgroundColor = [UIColor clearColor];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"cuesArray"]){
        [[NSUserDefaults standardUserDefaults] setObject:@[@NO, @NO, @NO, @NO] forKey:@"cuesArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSArray *tmpArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"cuesArray"];
    self.cuesArray = tmpArr.mutableCopy;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSUInteger value = self.minutesArray.count;
    if (section){
        value = self.typesArray.count;
    }
    
    return value;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:22.0];
    if (indexPath.section == 0){
        cell.textLabel.text = [NSString stringWithFormat:@"     %@ Minutes", self.minutesArray[indexPath.row]];
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"     %@", self.typesArray[indexPath.row]];
        NSNumber *numberBool = [self.cuesArray objectAtIndex:indexPath.row];
        if (numberBool.boolValue)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    if ([self.selectedIndexPath  isEqual:indexPath]){
     cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 45)];
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
            title = @"  Audio Timing";
            break;
        case 1:
            title = @"  Spoken Cues";
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

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0){
        if (self.selectedIndexPath)
            [self.tableView cellForRowAtIndexPath:self.selectedIndexPath].accessoryType = UITableViewCellAccessoryNone;
        [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        if ([self.tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark){
           [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        }else{
            [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    self.selectedIndexPath = indexPath;
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0){
        NSNumber *number = [self.minutesArray objectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setValue:number forKey:@"speechUtterance"];
    }else if (indexPath.section == 1){
        BOOL var = NO;
        if ([self.tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark)
            var = YES;
        [self.cuesArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:var]];
        [[NSUserDefaults standardUserDefaults] setObject:self.cuesArray forKey:@"cuesArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
