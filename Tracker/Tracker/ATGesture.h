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
//  ATGesture.h
//  Tracker
//

#import <Foundation/Foundation.h>
#import "ATBusinessObject.h"

@class ATTracker;


@interface ATGesture : ATBusinessObject

/**
 Gesture actions
 */
typedef NS_ENUM(int, ATGestureAction) {
    ATGestureActionTouch,
    ATGestureActionNavigate,
    ATGestureActionDownload,
    ATGestureActionExit,
    ATGestureActionSearch
};

/**
 Gesture name
 */
@property (nonatomic, strong) NSString *name;

/**
 Gesture chapter1
 */
@property (nonatomic, strong) NSString *chapter1;

/**
 Gesture chapter2
 */
@property (nonatomic, strong) NSString *chapter2;

/**
 Gesture chapter3
 */
@property (nonatomic, strong) NSString *chapter3;

/**
 Gesture level2
 */
@property (nonatomic) int level2;

/**
 Gesture action
 */
@property (nonatomic) ATGestureAction action;

/**
 Send navigation gesture hit
 */
- (void)sendNavigation;

/**
 Send exit gesture hit
 */
- (void)sendExit;

/**
 Send download gesture hit
 */
- (void)sendDownload;

/**
 Send touch gesture hit
 */
- (void)sendTouch;

/**
 Send search gesture hit
 */
- (void)sendSearch;

/**
 Prepare parameters for the hit query string
 */
- (void)setEvent;

/**
 ATGesture initializer
 @param tracker the tracker instance
 @return ATGesture instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end


@interface ATGestures : NSObject

/**
 Tracker instance
 */
@property (nonatomic, strong) ATTracker *tracker;

/**
 ATGestures initializer
 @param tracker the tracker instance
 @return ATGestures instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

/**
 Add tagging data for a gesture
 @return the ATGesture instance
 */
- (ATGesture *)add;

/**
 Add tagging data for a gesture
 @param name gesture name
 @return the ATGesture instance
 */
- (ATGesture *)addWithName:(NSString *)name;

/**
 Add tagging data for a gesture
 @param name gesture name
 @param chapter1 gesture chapter1
 @return the ATGesture instance
 */
- (ATGesture *)addWithName:(NSString *)name chapter1:(NSString *)chapter1;

/**
 Add tagging data for a gesture
 @param name gesture name
 @param chapter1 gesture chapter1
 @param chapter2 gesture chapter2
 @return the ATGesture instance
 */
- (ATGesture *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2;

/**
 Add tagging data for a gesture
 @param name gesture name
 @param chapter1 gesture chapter1
 @param chapter2 gesture chapter2
 @param chapter3 gesture chapter3
 @return the ATGesture instance
 */
- (ATGesture *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2 chapter3:(NSString *)chapter3;

@end
