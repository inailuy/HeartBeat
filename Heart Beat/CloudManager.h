//
//  CloudManager.h
//  Heart Beat
//
//  Created by inailuy on 2/10/16.
//  Copyright © 2016 inailuy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

@interface CloudManager : NSObject

+ (id)sharedManager;
+ (id)sharedManagerWithDelegate:(id)delegate;
- (CKRecordID *)recordId;


- (CKRecord *)createRandomRecord;

// Saving Records
- (void)saveRecordToPublic:(CKRecord *)record;
- (void)saveRecordToPrivate:(CKRecord *)record;

- (void)deleteRecordToPublic:(CKRecord *)record;
- (void)deleteRecordToPrivate:(CKRecord *)record;

// Fetching Records
- (void)fetchAllFromPublicCloudwithRecordType:(NSString *)recordType;
- (void)fetchAllFromPrivateCloudwithRecordType:(NSString *)recordType;

@end

@protocol CloudManagerDelegate

- (void)finishedFetchingItems:(NSArray *)results fromQuery:(CKQuery *)query andZoneID:(CKRecordZoneID *)zoneID;
- (void)reloadUI;
@end
