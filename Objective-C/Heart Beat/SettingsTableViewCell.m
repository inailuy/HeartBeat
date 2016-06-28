//
//  SettingsTableViewCell.m
//  Heart Beat
//
//  Created by inailuy on 3/12/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import "SettingsTableViewCell.h"

@interface SettingsTableViewCell() <UITextFieldDelegate>

@end

@implementation SettingsTableViewCell

- (void)awakeFromNib {
    // Initialization codel
    self.textfield.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (IBAction)switchPressed:(UISwitch *)sender {
    [self updateSettings];
}

- (IBAction)textfieldUsed:(UITextField *)sender {
   // [self updateSettings];
}

- (IBAction)segmentedControlledUsed:(UISegmentedControl *)sender {
    [self updateSettings];
}

-(void)updateSettings{
    if ([self.textLabel.text isEqualToString:@"Sex"]) {
        self.delegate.sex = self.segementedControl.selectedSegmentIndex;
    }else if ([self.textLabel.text isEqualToString:@"Units"]) {
        self.delegate.metric = self.segementedControl.selectedSegmentIndex;
        [self.delegate updateUsersWeight];
    }else if ([self.textLabel.text isEqualToString:@"Health App"]) {
        self.delegate.healthKit = self.switchCell.on;
    }else if ([self.textLabel.text isEqualToString:@"Debug Mode"]) {
        self.delegate.debugMode = self.switchCell.on;
    }else if ([self.textLabel.text isEqualToString:@"Age"]) {
        self.delegate.age = self.textfield.text.intValue;
    }else if ([self.textLabel.text isEqualToString:@"Weight"]) {
        self.delegate.weight = self.textfield.text.floatValue;
    }
    [self.delegate saveData];
    [self resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [textField becomeFirstResponder];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self updateSettings];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didSelectRowAtIndexPath");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    return YES;
}



@end
