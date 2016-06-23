//
//  CloudManager.m
//  Heart Beat
//
//  Created by inailuy on 2/10/16.
//  Copyright © 2016 inailuy. All rights reserved.
//

#import "CloudManager.h"
#import "WorkoutObject.h"

@interface CloudManager()

@property (nonatomic, strong) id delegate;

@end

@implementation CloudManager

+ (id)sharedManager {
    static CloudManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

+ (id)sharedManagerWithDelegate:(id)delegate{
    static CloudManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    
    if (delegate){
        sharedMyManager.delegate = delegate;
    }
    
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

-(CKRecordID *)recordId{
    NSInteger randomNumber = arc4random() % 9999999;
    NSString *recordName = [NSString stringWithFormat:@"%@%li",kWorkOutRecordName, (long)randomNumber];
    CKRecordID *workoutObjectID = [[CKRecordID alloc] initWithRecordName:recordName];
    return workoutObjectID;
}

-(CKRecord *)createRandomRecord{
    CKRecord *workoutRecord = [[CKRecord alloc] initWithRecordType:kWorkOutRecordType recordID:self.recordId];
    workoutRecord[@"workoutType"] = @"soccer";
    workoutRecord[@"averageBPM"] = @500;
    
    return workoutRecord;
}

-(void)saveRecordToPublic:(CKRecord *)record{
    CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
    [self saveRecord:record withDatabase:publicDatabase];
}

-(void)saveRecordToPrivate:(CKRecord *)record{
    CKDatabase *privateDatabase = [[CKContainer defaultContainer] privateCloudDatabase];
    [self saveRecord:record withDatabase:privateDatabase];
}

-(void)saveRecord:(CKRecord *)record withDatabase:(CKDatabase *)database{
    [database saveRecord:record completionHandler:^(CKRecord *workoutRecord, NSError *error){
        if (!error) {
            // Insert successfully saved record code
            if (self.delegate)
            {
                [self.delegate reloadUI];
            }
        }
        else {
            // Insert error handling
        }
    }];
}

- (void)deleteRecordToPublic:(CKRecord *)record{
    CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
    [self deleteRecord:record withDatabase:publicDatabase];
}

- (void)deleteRecordToPrivate:(CKRecord *)record{
    CKDatabase *privateDatabase = [[CKContainer defaultContainer] privateCloudDatabase];
    [self deleteRecord:record withDatabase:privateDatabase];
}

-(void)deleteRecord:(CKRecord *)record withDatabase:(CKDatabase *)database{
    [database deleteRecordWithID:record.recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
        if (error){
            NSLog(@"error %@", error.localizedDescription);
        } else{
            [self.delegate reloadUI];
        }
    }];
}

- (void)fetchAllFromPrivateCloudwithRecordType:(NSString *)recordType{
    CKDatabase *privateDatase = [[CKContainer defaultContainer] privateCloudDatabase];
    [self fetchRecordWithDatabase:privateDatase withRecordType:recordType];
}

- (void)fetchAllFromPublicCloudwithRecordType:(NSString *)recordType{
    CKDatabase *publicDatabase = [[CKContainer defaultContainer] privateCloudDatabase];
    [self fetchRecordWithDatabase:publicDatabase withRecordType:recordType];
}

-(void)fetchRecordWithDatabase:(CKDatabase *)database withRecordType:(NSString *)recordType{
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:recordType predicate:predicate];
    CKRecordZoneID *zoneID = nil;
    [database performQuery:query inZoneWithID:zoneID completionHandler:^(NSArray *results, NSError *error) {
        if (error) {
            #ifdef DEBUG
            NSLog(@"error fetching cloudkit data = %@", error.localizedDescription);
            #endif
            [self fetchRecordWithDatabase:database withRecordType:recordType];
        }
        else {
            // Display the fetched records
            [self.delegate finishedFetchingItems:results fromQuery:query andZoneID:zoneID];
        }
    }];
}


- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
