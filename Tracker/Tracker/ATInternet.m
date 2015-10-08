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
//  ATInternet.m
//  Tracker
//

#import "ATInternet.h"

@interface ATInternet()

/**
 A collection of named trackers
 */
@property (nonatomic, strong) NSMutableDictionary* trackers;

@end

@implementation ATInternet

@synthesize defaultTracker = _defaultTracker;

+ (id)sharedInstance {
    static ATInternet *sharedATI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedATI = [[self alloc] init];
    });
    return sharedATI;
}

- (ATTracker *)defaultTracker {
    return [self trackerWithName:@"defaultTracker"];
}

- (ATTracker *)trackerWithName:(NSString *)name {
    return [self trackerWithName:name configuration:nil];
}

- (ATTracker *)trackerWithName:(NSString *)name configuration:(NSDictionary *) configuration {
    BOOL firstInit = NO;
    
    if(!self.trackers) {
        firstInit = YES;
        self.trackers = [[NSMutableDictionary alloc] init];
    }
    
    if([self.trackers objectForKey:name] && [[self.trackers objectForKey:name] isKindOfClass:[ATTracker class]]) {
        return (ATTracker *)[self.trackers objectForKey:name];
    } else {
        ATTracker *tracker;
        
        if(configuration) {
            tracker = [[ATTracker alloc] init:configuration];
        }
        else {
            tracker = [[ATTracker alloc] init];
        }
        
        [self.trackers setObject:tracker forKey:name];
        
        if(firstInit == YES) {
            _defaultTracker = tracker;
        }
        
        return tracker;
    }
}

@end
