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
//  ATScreen.h
//  Tracker
//

#import <Foundation/Foundation.h>
#import "ATBusinessObject.h"

@class ATTracker;


@interface ATScreenInfo : ATBusinessObject

@end


@interface ATAbstractScreen : ATBusinessObject

/**
 Screen actions
 */
typedef NS_ENUM(int, ATScreenAction) {
    ATScreenActionView
};

/**
 Screen name
 */
@property (nonatomic, strong) NSString *name;

/**
 Screen chapter1
 */
@property (nonatomic, strong) NSString *chapter1;

/**
 Screen chapter2
 */
@property (nonatomic, strong) NSString *chapter2;

/**
 Screen chapter3
 */
@property (nonatomic, strong) NSString *chapter3;

/**
 Screen level2
 */
@property (nonatomic) int level2;

/**
 Screen action
 */
@property (nonatomic) ATScreenAction action;

/**
 Basket screen
 */
@property (nonatomic) BOOL isBasketScreen;

/**
 Send view hit
 */
- (void)sendView;

/**
 Prepare parameters for the hit query string
 */
- (void)setEvent;

/**
 ATAbstractScreen initializer
 @param tracker the tracker instance
 @return ATAbstractScreen instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end


@interface ATScreen : ATAbstractScreen

/**
 Prepare parameters for the hit query string
 */
- (void)setEvent;

/**
 ATScreen initializer
 @param tracker the tracker instance
 @return ATScreen instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end


@interface ATDynamicScreen : ATAbstractScreen

/**
 Dynamic screen identifier
 */
@property (nonatomic) NSString* screenId;

/**
 Dynamic screen update date
 */
@property (nonatomic, strong) NSDate *update;

/**
 Prepare parameters for the hit query string
 */
- (void)setEvent;

/**
 ATDynamicScreen initializer
 @param tracker the tracker instance
 @return ATDynamicScreen instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end


@interface ATScreens : NSObject

/**
 Tracker instance
 */
@property (nonatomic, strong) ATTracker *tracker;

/**
 Add tagging data for a screen
 @return the ATScreen instance
 */
- (ATScreen *)add;

/**
 Add tagging data for a screen
 @param name screen name
 @return the ATScreen instance
 */
- (ATScreen *)addWithName:(NSString *)name;

/**
 Add tagging data for a screen
 @param name screen name
 @param chapter1 screen chapter1
 @return the ATScreen instance
 */
- (ATScreen *)addWithName:(NSString *)name chapter1:(NSString *)chapter1;

/**
 Add tagging data for a screen
 @param name screen name
 @param chapter1 screen chapter1
 @param chapter2 screen chapter2
 @return the ATScreen instance
 */
- (ATScreen *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2;

/**
 Add tagging data for a screen
 @param name screen name
 @param chapter1 screen chapter1
 @param chapter2 screen chapter2
 @param chapter3 screen chapter3
 @return the ATScreen instance
 */
- (ATScreen *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2 chapter3:(NSString *)chapter3;

/**
 ATScreens initializer
 @param tracker the tracker instance
 @return ATScreens instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end


@interface ATDynamicScreens : NSObject

/**
 Tracker instance
 */
@property (nonatomic, strong) ATTracker *tracker;

/**
 Add tagging data for a dynamic screen
 @param update dynamic screen update
 @param name dynamic screen name
 @return the ATDynamicScreen instance
 */
- (ATDynamicScreen *)addWithId:(int)screenId update:(NSDate *)update name:(NSString *)name __attribute((deprecated(("Use addWithStringId instead."))));

/**
 Add tagging data for a dynamic screen
 @param update dynamic screen update
 @param name dynamic screen name
 @return the ATDynamicScreen instance
 */
- (ATDynamicScreen *)addWithStringId:(NSString *)screenId update:(NSDate *)update name:(NSString *)name;

/**
 Add tagging data for a dynamic screen
 @param update dynamic screen update
 @param name dynamic screen name
 @param chapter1 dynamic screen chapter1
 @return the ATDynamicScreen instance
 */
- (ATDynamicScreen *)addWithId:(int)screenId update:(NSDate *)update name:(NSString *)name chapter1:(NSString *)chapter1 __attribute((deprecated(("Use addWithStringId instead."))));

/**
 Add tagging data for a dynamic screen
 @param update dynamic screen update
 @param name dynamic screen name
 @param chapter1 dynamic screen chapter1
 @return the ATDynamicScreen instance
 */
- (ATDynamicScreen *)addWithStringId:(NSString *)screenId update:(NSDate *)update name:(NSString *)name chapter1:(NSString *)chapter1;

/**
 Add tagging data for a dynamic screen
 @param update dynamic screen update
 @param name dynamic screen name
 @param chapter1 dynamic screen chapter1
 @param chapter2 dynamic screen chapter2
 @return the ATDynamicScreen instance
 */
- (ATDynamicScreen *)addWithId:(int)screenId update:(NSDate *)update name:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2 __attribute((deprecated(("Use addWithStringId instead."))));

/**
 Add tagging data for a dynamic screen
 @param update dynamic screen update
 @param name dynamic screen name
 @param chapter1 dynamic screen chapter1
 @param chapter2 dynamic screen chapter2
 @return the ATDynamicScreen instance
 */
- (ATDynamicScreen *)addWithStringId:(NSString *)screenId update:(NSDate *)update name:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2;

/**
 Add tagging data for a dynamic screen
 @param update dynamic screen update
 @param name dynamic screen name
 @param chapter1 dynamic screen chapter1
 @param chapter2 dynamic screen chapter2
 @param chapter3 dynamic screen chapter3
 @return the ATDynamicScreen instance
 */
- (ATDynamicScreen *)addWithId:(int)screenId update:(NSDate *)update name:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2 chapter3:(NSString *)chapter3 __attribute((deprecated(("Use addWithStringId instead."))));

/**
 Add tagging data for a dynamic screen
 @param update dynamic screen update
 @param name dynamic screen name
 @param chapter1 dynamic screen chapter1
 @param chapter2 dynamic screen chapter2
 @param chapter3 dynamic screen chapter3
 @return the ATDynamicScreen instance
 */
- (ATDynamicScreen *)addWithStringId:(NSString *)screenId update:(NSDate *)update name:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2 chapter3:(NSString *)chapter3;

/**
 ATDynamicScreens initializer
 @param tracker the tracker instance
 @return ATDynamicScreens instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end
