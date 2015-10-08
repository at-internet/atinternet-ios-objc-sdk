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
//  ATIdentifiedVisitor.h
//  Tracker
//

#import <Foundation/Foundation.h>

@class ATTracker;

@interface ATIdentifiedVisitor : NSObject

/**
 ATIdentifiedVisitor initializer
 @param tracker the tracker instance
 @return ATIdentifiedVisitor instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

/**
 Set tagging data for identified visitor
 @param visitorId visitor numeric identifier
 @return the ATTracker instance
 */
- (ATTracker *)setWithNumericId:(int)visitorId;

/**
 Set tagging data for identified visitor
 @param visitorId visitor numeric identifier
 @param visitorCategory visitor category
 @return the ATTracker instance
 */
- (ATTracker *)setWithNumericId:(int)visitorId visitorCategory:(int)visitorCategory;

/**
 Set tagging data for identified visitor
 @param visitorId visitor text identifier
 @return the ATTracker instance
 */
- (ATTracker *)setWithTextId:(NSString *)visitorId;

/**
 Set tagging data for identified visitor
 @param visitorId visitor text identifier
 @param visitorCategory visitor category
 @return the ATTracker instance
 */
- (ATTracker *)setWithTextId:(NSString *)visitorId visitorCategory:(int)visitorCategory;

/**
 Remove tagging data for identified visitor
 @return the ATTracker instance
 */
- (ATTracker *)unset;

@end
