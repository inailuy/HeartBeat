//
//  HeartRateCoreSDK.h
//
//  Copyright (c) 2014 Intel Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HeartRateData.h"

/**
 Heart rate monitor status values.
 */
typedef NS_OPTIONS(NSUInteger, HeartRateMonitorStatus) {
    /** Host device does not support external microphone */
    WrcMicrophoneNotAccessible = 1 << 0,
    /** Heart rate monitoring device is not connected */
    WrcMicDeviceNotConnected = 1 << 1,
    /** Microphone is being used by another application or Microhphone is busy */
    WrcMicrophoneInUse = 1 << 2,
    /** User has not granted permission to access microphone */
    WrcMicrophoneAccessNotGranted = 1 << 3,
    /** Device is not a supported heart rate monitor or it is not in heart rate monitoring mode */
    WrcNotAHeartRateMonitor = 1 << 4,
    /** Device is starting up and trying to detect heart rate */
    WrcDetectingHeartRate = 1 << 5,
    /** Low confidence on heart rate data from the device. Heart rate data will not be delivered. */
    WrcLowConfidence = 1 << 6,
    /** No heart rate found. Heart rate monitoring device may be out of ear */
    WrcHeartRateNotFound = 1 << 7
};

/**
 HeartRateCoreSDKDelegate - provides interface for an iOS application to obtain current heart rate in beats per minute as well as the status of heart rate monitor.
 */
@protocol HeartRateCoreSDKDelegate <NSObject>
/**
 Update current heart rate from heart rate monitor
 
 @param heartRateData current heart rate in bpm (beats per minute)
 */
- (void) didUpdateHeartRate:(HeartRateData *) heartRateData;
/**
 Heart monitor status changed
 
 @param heartRateMonitorStatus current heart rate monitor status.
 */
- (void) didChangeHeartRateMonitorStatus:(HeartRateMonitorStatus) heartRateMonitorStatus;
@end


/**
 HeartRateCoreSDK - core sdk static library to interface with heart rate monitoring device
 */


@interface HeartRateCoreSDK : NSObject
+ (HeartRateCoreSDK *) sharedInstance;
@property (nonatomic, readonly) HeartRateMonitorStatus heartRateMonitorStatus;
/** delegate - HeartRateCoreSDKDelegate to deliver heart rate and status */
@property (nonatomic, weak) id <HeartRateCoreSDKDelegate> delegate;
/** start updating heart rate - current heart rate is updated via delegate method didUpdateHeartRate */
- (void) start;
/** stop updating heart rate - stop heart rate updates to deleage method didUpdateHeartRate */
- (void) stop;
@end

