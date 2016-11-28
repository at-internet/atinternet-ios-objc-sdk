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
//  ATOffline.h
//  Tracker
//

#import <Foundation/Foundation.h>

@class ATTracker;
@class ATHit;

@interface ATOffline : NSObject

/**
 Tracker instance
 */
@property (nonatomic, strong) ATTracker *tracker;

/**
 Offline mode
 */
@property (nonatomic, strong) NSString *offlineMode;

/**
 Send offline hits
 */
- (void)dispatch;

/**
 Get all offline hits stored in database
 @return array of offline hits
 */
- (NSArray *)get;

/**
 Get the count of offline hits stored in database
 @return offline hits count
 */
- (NSInteger)count;

/**
 Delete all offline hits stored in database
 @return deleted hits count (-1 if an error occured)
 */
- (NSInteger)delete;

/**
 Delete offline hits older than the number of days passed in parameter
 @param Number of days of offline hits to keep in database
 @return deleted hits count (-1 if an error occured)
 */
- (NSInteger)deleteOlderThanDays:(NSInteger)days;

/**
 Delete offline hits older than the date passed in parameter
 @param Date from which the hits will be deleted
 @return deleted hits count (-1 if an error occured)
 */
- (NSInteger)deleteOlderThanDate:(NSDate *)date;

/**
 Get the first hit stored in database
 @return the oldest hit
 */
- (ATHit *)oldest;

/**
 Get the latest hit stored in database
 @return the latest hit
 */
- (ATHit *)latest;

/**
 ATOffline initializer
 @param tracker the tracker instance
 @return ATOffline instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end
