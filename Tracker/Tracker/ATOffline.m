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
//  ATOffline.m
//  Tracker
//

#import "ATOffline.h"
#import "ATTracker.h"
#import "ATStorage.h"
#import "ATSender.h"

@implementation ATOffline

- (instancetype)initWithTracker:(ATTracker *)tracker {
    if (self = [super init]) {
        self.tracker = tracker;
    }
    
    return self;
}

- (void)dispatch {
    [ATSender sendOfflineHits:self.tracker forceSendOfflineHits:YES];
}
- (NSArray *)get {
    ATStorage *storage = [[ATStorage alloc] init];
    return [storage hits];
}

- (NSInteger)count {
    ATStorage *storage = [[ATStorage alloc] init];
    return [storage count];
    
}

- (NSInteger)delete {
    ATStorage *storage = [[ATStorage alloc] init];
    return [storage deleteAll];
}

- (NSInteger)deleteOlderThanDays:(NSInteger)days {
    ATStorage *storage = [[ATStorage alloc] init];
    
    NSDate* now = [NSDate date];
    NSDateComponents* dateComponent = [[NSDateComponents alloc] init];
    dateComponent.day = -days;
    
    NSDate* past =[[NSCalendar currentCalendar] dateByAddingComponents:dateComponent toDate:now options:kNilOptions];
    
    return [storage deleteFromDate:past];
}

- (NSInteger)deleteOlderThanDate:(NSDate *)date {
    ATStorage *storage = [[ATStorage alloc] init];
    return [storage deleteFromDate:date];
}

- (ATHit *)oldest {
    return [[[ATStorage alloc] init] first];
}

- (ATHit *)latest {
    return [[[ATStorage alloc] init] last];
}


@end
