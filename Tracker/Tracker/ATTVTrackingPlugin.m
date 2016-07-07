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
//  ATTVTrackingPlugin.m
//  Tracker
//

#import "ATTVTrackingPlugin.h"
#import "ATTool.h"
#import "ATNuggAd.h"
#import "ATTracker.h"
#import "ATPluginProtocol.h"
#import "ATTVTracking.h"
#import "ATConfiguration.h"

#define TVT_PARAM                   @"ATTVTParam"
#define TVT_LAST_SESSION_START      @"ATTVTLastSessionStart"
#define TVT_REMANENT_SPOT           @"ATTVTRemanentSpot"
#define TVT_VERSION                 @"1.2.2m"


@interface ATTVTrackingPlugin() <ATPluginProtocol>

typedef NS_ENUM(NSInteger, ATTVTrackingPluginStatusCase) {
    ATTVTrackingPluginStatusCaseChannelUndefined,
    ATTVTrackingPluginStatusCaseChannelError,
    ATTVTrackingPluginStatusCaseNoData,
    ATTVTrackingPluginStatusCaseTimeError,
    ATTVTrackingPluginStatusCaseOk
};

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) NSMutableDictionary *spot;
@property (nonatomic) BOOL isValidSpot;
@property (nonatomic) BOOL isSpotFirstTimeSaved;
@property (nonatomic) BOOL isVisitOver;
@property (nonatomic) NSString *timeData;
@property (nonatomic) ATTVTrackingPluginStatusCase statusCase;

@end


@implementation ATTVTrackingPlugin

@synthesize response;
@synthesize tracker;
@synthesize paramKey;
@synthesize responseType;
@synthesize spot = _spot;
@synthesize isValidSpot = _isValidSpot;
@synthesize isSpotFirstTimeSaved = _isSpotFirstTimeSaved;


- (void)setSpot:(NSMutableDictionary *)spot {
    if (!spot) {
        _spot = [[NSMutableDictionary alloc] init];
    } else {
        _spot = spot;
    }
}

- (NSMutableDictionary *)spot {
    if ([_spot objectForKey:@"priority"] == nil) {
        [_spot setObject:@"30" forKey:@"priority"];
    }
    
    if ([_spot objectForKey:@"lifetime"] == nil) {
        [_spot setObject:@"1" forKey:@"lifetime"];
    }
    
    return _spot;
}

- (BOOL)isValidSpot {
    NSString *value = (NSString *)[self.spot objectForKey:@"channel"];
    self.timeData = @"";
    
    if (value) {
        if (![value isEqualToString:@"undefined"]) {
            if (self.spot[@"time"]) {
                self.timeData = self.spot[@"time"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
                dateFormatter.timeZone = [[NSTimeZone alloc] initWithName:@"UTC"];
                
                NSDate *date = [dateFormatter dateFromString:self.spot[@"time"]];
                if(date){
                    NSString *tvtSpotValidityTime = self.tracker.configuration.parameters[@"tvtSpotValidityTime"];
                    
                    if([ATTool minutesBetweenDates:date toDate:[[NSDate alloc] init]] > [tvtSpotValidityTime intValue]){
                        self.statusCase = ATTVTrackingPluginStatusCaseTimeError;
                        return NO;
                    } else {
                        return YES;
                    }
                } else {
                    self.statusCase = ATTVTrackingPluginStatusCaseTimeError;
                    return NO;
                }
            } else {
                self.statusCase = ATTVTrackingPluginStatusCaseTimeError;
                return NO;
            }
        } else {
            self.statusCase = ATTVTrackingPluginStatusCaseChannelUndefined;
            return NO;
        }
    } else {
        self.statusCase = ATTVTrackingPluginStatusCaseChannelError;
        return NO;
    }
}

- (BOOL)isSpotFirstTimeSaved {
    return ([self.userDefaults objectForKey:TVT_PARAM] == nil);
}

- (BOOL)isVisitOver {
    BOOL isOver = NO;
    
    NSDate *lastSession = (NSDate *)[self.userDefaults objectForKey:TVT_LAST_SESSION_START];
    
    double diffTimeSession = 0;
    if (lastSession) {
        diffTimeSession = [[NSDate date] timeIntervalSinceDate:lastSession];
    }
    
    if ((diffTimeSession / 60 > (double)self.tracker.tvTracking.visitDuration) || self.isSpotFirstTimeSaved) {
        [self.userDefaults setObject:[NSDate date] forKey:TVT_LAST_SESSION_START];
        [self.userDefaults synchronize];
        isOver = YES;
    } else if (diffTimeSession / 60 < (double)self.tracker.tvTracking.visitDuration) {
        [self.userDefaults setObject:[NSDate date] forKey:TVT_LAST_SESSION_START];
        [self.userDefaults synchronize];
    }
    
    return isOver;
}

- (instancetype)initWithTracker:(ATTracker *)aTracker {
    self = [super init];
    
    if (self) {
        self.response = [[NSString alloc] initWithFormat:@"{}"];
        self.tracker = aTracker;
        self.paramKey = @"stc";
        self.responseType = ATParamTypeJSON;
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        self.statusCase = ATTVTrackingPluginStatusCaseOk;
    }
    
    return self;
}

- (void)execute {
    
    if (self.isSpotFirstTimeSaved) {
        [self.userDefaults setObject:[NSDate date] forKey:TVT_LAST_SESSION_START];
        [self.userDefaults synchronize];
    }
    
    if (self.isVisitOver) {
        
        [self.userDefaults setObject:[NSDate date] forKey:TVT_LAST_SESSION_START];
        [self.userDefaults synchronize];
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        
        if (self.tracker.tvTracking.campaignURL) {
            NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                            initWithURL:[NSURL URLWithString:self.tracker.tvTracking.campaignURL]
                                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                            timeoutInterval:5.0];
            
            NSURLSessionDataTask *task =
            [session dataTaskWithRequest:request
                       completionHandler:^(NSData *data, NSURLResponse *urlResponse, NSError *error) {
                           
                           self.response = [ATTool JSONStringify:[self buildTVTParam:data urlResponse:urlResponse error:error] prettyPrinted:NO];
                           
                           if (self.tracker.delegate && self.response) {
                               if ([self.tracker.delegate respondsToSelector:@selector(didCallPartner:)]) {
                                   [self.tracker.delegate didCallPartner:[NSString stringWithFormat:@"TV Tracking:\r%@", self.response]];
                               }
                           }
                           
                           [session finishTasksAndInvalidate];
                           
                           dispatch_semaphore_signal(semaphore);
                           
                       }];
            
            [task resume];
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
    } else {
        
        ATParam *param = (ATParam *)[self.userDefaults objectForKey:TVT_PARAM];
        self.response = [ATTool JSONStringify:param prettyPrinted:NO];
        
    }
    
}

- (NSMutableDictionary *)buildTVTParam:(NSData *)data urlResponse:(NSURLResponse *)urlResponse error:(NSError *)error {
    
    NSMutableDictionary *tvtParam = [[NSMutableDictionary alloc] init];
    
    BOOL spotSet = NO;
    
    if (data != nil && error == nil) {
        
        id serializedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        if (serializedData) {
            
            self.spot = serializedData;
            spotSet = YES;
            
            NSMutableDictionary *directSpot = [[NSMutableDictionary alloc] init];
            [directSpot setObject:self.spot forKey:@"direct"];
            
            if (self.isValidSpot) {
                [tvtParam setObject:directSpot forKey:@"tvtracking"];
            } else {
                [tvtParam setObject:[[NSMutableDictionary alloc] init] forKey:@"tvtracking"];
            }
            
        } else {
            
            self.statusCase = ATTVTrackingPluginStatusCaseNoData;
            
        }
        
    } else {
        
        self.statusCase = ATTVTrackingPluginStatusCaseNoData;
        
    }
    
    NSMutableDictionary *remanentSpot = [[self.userDefaults objectForKey:TVT_REMANENT_SPOT] mutableCopy];
    
    if (remanentSpot) {
        
        NSDate *date = (NSDate *)[remanentSpot objectForKey:@"date"];
        int diffTime = (int)round([[NSDate date] timeIntervalSinceDate:date]);
        
        NSMutableDictionary *remanentSpotContent = [[NSMutableDictionary alloc] init];
        [remanentSpotContent setObject:[remanentSpot objectForKey:@"spot"] forKey:@"remanent"];
        
        NSMutableDictionary *r = [remanentSpotContent objectForKey:@"remanent"];
        NSString *lifetime = [r objectForKey:@"lifetime"];
        
        if ( (diffTime / (60*60*24)) < lifetime.intValue ) {
            if (!spotSet) {
                [tvtParam setObject:[[NSMutableDictionary alloc] init] forKey:@"tvtracking"];
            }
            [[tvtParam objectForKey:@"tvtracking"] setObject:[remanentSpot objectForKey:@"spot"] forKey:@"remanent"];
        } else {
            [self.userDefaults removeObjectForKey:TVT_REMANENT_SPOT];
            [self.userDefaults synchronize];
        }
        
        if (spotSet && self.isValidSpot) {
            [[tvtParam objectForKey:@"tvtracking"] setObject:self.spot forKey:@"direct"];
        }
        
    }
    
    if(![tvtParam objectForKey:@"tvtracking"]){
        NSMutableDictionary *dico = [[NSMutableDictionary alloc] init];
        [tvtParam setObject:dico forKey:@"tvtracking"];
    }
    
    [[tvtParam objectForKey:@"tvtracking"] setObject:[self buildTVTInfo:urlResponse] forKey:@"info"];
    
    if (spotSet
        && [self isValidSpot]
        && (self.isSpotFirstTimeSaved || [((NSString *)[self.spot objectForKey:@"priority"]) isEqualToString:@"1"])) {
        
        NSDictionary *d = [[NSDictionary alloc] initWithObjectsAndKeys:self.spot, @"spot", [NSDate date], @"date", nil];
        [self.userDefaults setObject:d forKey:TVT_REMANENT_SPOT];
        [self.userDefaults synchronize];
        
    }
    
    [self.userDefaults setObject:tvtParam forKey:TVT_PARAM];
    [self.userDefaults synchronize];
    
    return tvtParam;
    
}

- (NSMutableDictionary *)buildTVTInfo:(NSURLResponse *)urlResponse {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[[NSMutableDictionary alloc] init] forKey:@"info"];
    
    NSString *code = @"Unknown";
    
    if (response != nil) {
        code = [NSString stringWithFormat:@"%ld", (long)((NSHTTPURLResponse *)urlResponse).statusCode];
    }
    
    [[dic objectForKey:@"info"] setObject:TVT_VERSION forKey:@"version"];
    
    switch (self.statusCase) {
        case ATTVTrackingPluginStatusCaseChannelError:
            [[dic objectForKey:@"info"] setObject:code forKey:@"message"];
            [[dic objectForKey:@"info"] setObject:@"noChannel" forKey:@"errors"];
            break;
        case ATTVTrackingPluginStatusCaseChannelUndefined:
            [[dic objectForKey:@"info"] setObject: [NSString stringWithFormat:@"%@-channelUndefined", code] forKey:@"message"];
            break;
        case ATTVTrackingPluginStatusCaseNoData:
            [[dic objectForKey:@"info"] setObject:code forKey:@"message"];
            [[dic objectForKey:@"info"] setObject:@"noData" forKey:@"errors"];
            break;
        case ATTVTrackingPluginStatusCaseTimeError:
            [[dic objectForKey:@"info"] setObject: [NSString stringWithFormat:@"%@-%@", code, self.timeData] forKey:@"message"];
            [[dic objectForKey:@"info"] setObject:@"timeError" forKey:@"errors"];
            break;
        default:
            [[dic objectForKey:@"info"] setObject:code forKey:@"message"];
            break;
    }
    
    return [dic objectForKey:@"info"];
    
}

@end
