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
//  ATTVTracking.m
//  Tracker
//


#import "ATTVTracking.h"
#import "ATTracker.h"
#import "ATConfiguration.h"
#import "ATParamOption.h"
#import "ATParam.h"
#import "ATTrackerQueue.h"


@interface ATTVTracking()

@property (nonatomic, strong) ATTracker *tracker;

@end


@implementation ATTVTracking

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
        self.visitDuration = 10;
        [self configure];
    }
    
    return self;
}

- (void)configure {
    
    NSString *urlStr = [self.tracker.configuration.parameters objectForKey:@"tvtURL"];
    
    if (urlStr) {
        if ([urlStr isEqualToString:@""]) {
            if(self.tracker.delegate) {
                if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                    [self.tracker.delegate warningDidOccur:@"TVTracking URL not set"];
                }
            }
        } else {
            NSURL *url = [NSURL URLWithString:urlStr];
            if (url) {
                self.campaignURL = urlStr;
            } else {
                if(self.tracker.delegate) {
                    if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                        [self.tracker.delegate warningDidOccur:@"TVTracking URL is not a valid URL"];
                    }
                }
            }
        }
    } else {
        if(self.tracker.delegate) {
            if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.tracker.delegate warningDidOccur:@"TVTracking URL not set"];
            }
        }
    }
    
    
    NSString *durationStr = [self.tracker.configuration.parameters objectForKey:@"tvtVisitDuration"];
    
    if (durationStr) {
        int duration = [durationStr intValue];
        if (duration > 0) {
            self.visitDuration = duration;
        }
    }
    
}

- (ATTracker *)set {
    NSOperation *configurationOperation = [NSBlockOperation blockOperationWithBlock:^{
        if ([[ATPluginParam list:self.tracker] objectForKey:@"tvt"]) {
            ATParamOption *option = [[ATParamOption alloc] init];
            //option.append = YES;
            option.persistent = YES;
            option.encode = YES;
            [self.tracker setBooleanParam:@"tvt" value:YES options:option];
        } else {
            if(self.tracker.delegate) {
                if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                    [self.tracker.delegate warningDidOccur:@"NuggAd not enabled"];
                }
            }
        }
    }];
    
    [[ATTrackerQueue sharedInstance].queue addOperation:configurationOperation];
    
    return self.tracker;
}

- (ATTracker *)setWithURL:(NSString *)campaignURL {
    NSURL *url = [NSURL URLWithString:campaignURL];
    if (url) {
        self.campaignURL = campaignURL;
    } else {
        if(self.tracker.delegate) {
            if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.tracker.delegate warningDidOccur:@"TVTracking URL is not a valid URL"];
            }
        }
    }
    
    return [self set];
}

- (ATTracker *)setWithURL:(NSString *)campaignURL visitDuration:(int)visitDuration {
    self.visitDuration = visitDuration;
    
    return [self setWithURL:campaignURL];
}

- (void)unset {
    [self.tracker unsetParam:@"tvt"];
    [self configure];
}

@end
