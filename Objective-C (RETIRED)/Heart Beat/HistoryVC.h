//
//  HistoryVC.h
//  Heart Beat
//
//  Created by inailuy on 2/11/15.
//  Copyright (c) 2015 inailuy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface HistoryVC : BaseVC

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray *objects;
@property (strong, nonatomic) NSMutableDictionary *dictionary;
@property (strong, nonatomic) NSArray *dictionaryKeys;

- (void) reloadDatabase;

@end
