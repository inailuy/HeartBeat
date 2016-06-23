//
//  SettingsTableViewCell.h
//  Heart Beat
//
//  Created by inailuy on 3/12/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingVC.h"

@interface SettingsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *switchCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segementedControl;
@property (weak, nonatomic) IBOutlet UITextField *textfield;

@property (nonatomic, weak) SettingVC *delegate;

@end
