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
//  ATEvent.h
//  Tracker
//

#import <Foundation/Foundation.h>
#import "ATTracker.h"

@interface ATEvent : NSObject

/**
 Tracker instance
 */
@property (nonatomic, strong) ATTracker *tracker;

/**
 Set tagging data for an event
 @param category event category
 @param action event action
 @param label event label
 @return the ATTracker instance
 */
- (ATTracker *)setWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label;

/**
 Set tagging data for an event
 @param category event category
 @param action event action
 @param label event label
 @param value event value
 @return the ATTracker instance
 */
- (ATTracker *)setWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSString *)value;

/**
 ATEvent initializer
 @param tracker the tracker instance
 @return ATEvent instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end
