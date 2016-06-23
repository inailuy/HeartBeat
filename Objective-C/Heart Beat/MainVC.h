//
//  ViewController.h
//  Heart Beat
//
//  Created by inailuy on 2/11/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface MainVC : BaseVC

@property (weak, nonatomic) IBOutlet UILabel *heartbeatLabel;
@property (weak, nonatomic) IBOutlet UILabel *peripheralStausLabel;

- (void)performLoginOperation;

@end

