//
//  SettingVC.h
//  Heart Beat
//
//  Created by inailuy on 2/11/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface SettingVC : BaseVC

@property (nonatomic) int age;
@property (nonatomic) float weight;
@property (nonatomic) BOOL sex;
@property (nonatomic) BOOL debugMode;
@property (nonatomic) BOOL healthKit;
@property (nonatomic) BOOL metric;

- (void) updateHealthSwitch;
- (void)updateUsersWeight;
- (void) saveData;

@end
