/*
This SDK is licensed under the MIT license (MIT)
Copyright (c) 2015- Applied Technologies Internet SAS (registration number B 403 261 258 - Trade and Companies Register of Bordeaux – France)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/





//
//  ATHit.h
//  Tracker
//

#import <Foundation/Foundation.h>


@interface ATProcessedHitType: NSObject

/**
 Set of all hit types that can be processed
 */
+ (NSDictionary *)list;

@end


@interface ATHit : NSObject

/**
 Standard hit type
 */
typedef NS_ENUM(int, ATHitType) {
    ATHitTypeUnknown = 0,
    ATHitTypeScreen = 1,
    ATHitTypeTouch = 2,
    ATHitTypeAudio = 3,
    ATHitTypeVideo = 4,
    ATHitTypeAnimation = 5,
    ATHitTypePodCast = 6,
    ATHitTypeRSS = 7,
    ATHitTypeEmail = 8,
    ATHitTypeAdvertising = 9,
    ATHitTypeAdTracking = 10,
    ATHitTypeProductDisplay = 11,
    ATHitTypeWeborama = 12,
    ATHitTypeMVTesting = 13
};

/**
 Hit
 */
@property (nonatomic, strong) NSString *url;

/**
 Date of creation
 */
@property (nonatomic, strong) NSDate *creationDate;

/**
 Number of retry that were made to send the hit
 */
@property (nonatomic, strong) NSNumber *retryCount;

/**
 Indicates wheter the hit comes from storage
 */
@property (nonatomic, getter = isOffline) BOOL offline;

/**
 Initialize a new ATHit object
 @returns a newly initialized object
 */
- (instancetype)init;

/**
 Initialize a new ATHit object
 @param url of hit
 @returns a newly initialized object with a url
 */
- (instancetype)init:(NSString *)url NS_DESIGNATED_INITIALIZER;

/**
 Get the hit type depending on the hit url
 @param url of hit
 @returns type of hit
 */
- (ATHitType)hitType;

/**
 Get the hit type depending on parameters set in buffer
 @param arrays of parameters
 @returns type of hit
 */
+ (ATHitType)hitType:(NSArray *)parameters, ...;

@end
