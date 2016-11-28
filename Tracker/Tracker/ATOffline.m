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
#import "ATConfiguration.h"

@implementation ATOffline

- (instancetype)initWithTracker:(ATTracker *)tracker {
    if (self = [super init]) {
        self.tracker = tracker;
        self.offlineMode = tracker.configuration.parameters[@"storage"];
    }
    
    return self;
}

- (void)dispatch {
    [ATSender sendOfflineHits:self.tracker forceSendOfflineHits:YES];
}
- (NSArray *)get {
    return [[ATStorage sharedInstanceOf:self.offlineMode] hits];
}

- (NSInteger)count {
    return [[ATStorage sharedInstanceOf:self.offlineMode] count];
    
}

- (NSInteger)delete {
    return [[ATStorage sharedInstanceOf:self.offlineMode] deleteAll];
}

- (NSInteger)deleteOlderThanDays:(NSInteger)days {
    NSDate* now = [NSDate date];
    NSDateComponents* dateComponent = [[NSDateComponents alloc] init];
    dateComponent.day = -days;
    
    NSDate* past =[[NSCalendar currentCalendar] dateByAddingComponents:dateComponent toDate:now options:kNilOptions];
    
    return [[ATStorage sharedInstanceOf:self.offlineMode] deleteFromDate:past];
}

- (NSInteger)deleteOlderThanDate:(NSDate *)date {
    return [[ATStorage sharedInstanceOf:self.offlineMode] deleteFromDate:date];
}

- (ATHit *)oldest {
    return [[ATStorage sharedInstanceOf:self.offlineMode] first];
}

- (ATHit *)latest {
    return [[ATStorage sharedInstanceOf:self.offlineMode] last];
}


@end
