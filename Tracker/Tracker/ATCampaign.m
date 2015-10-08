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
//  ATCampaign.m
//  Tracker
//

#import "ATCampaign.h"
#import "ATTracker.h"
#import "ATTool.h"
#import "ATConfiguration.h"
#import "ATParamOption.h"

@implementation ATCampaign

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super initWithTracker:tracker];
    
    if (self) {
        self.campaignId = @"";
    }
    
    return self;
}

- (void)setEvent {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *remanentCampaign = [userDefaults objectForKey:@"ATCampaign"];
    NSDate *campaignDate = [userDefaults objectForKey:@"ATCampaignDate"];
    ATParamOption *encodeOption = [[ATParamOption alloc] init];
    encodeOption.encode = YES;
    
    
    if (remanentCampaign && campaignDate) {
        
        NSInteger nbDays = [ATTool daysBetweenDates:campaignDate toDate:[NSDate date]];
        
        NSString *strLifetime = [self.tracker.configuration.parameters objectForKey:@"campaignLifetime"];
        if (strLifetime) {
            if (nbDays > [strLifetime intValue]) {
                [userDefaults removeObjectForKey:@"ATCampaign"];
                [userDefaults synchronize];
            } else {
                [self.tracker setStringParam:@"xtor" value:remanentCampaign options:encodeOption];
            }
        }
        
    } else {
        
        [userDefaults setObject:[NSDate date] forKey:@"ATCampaignDate"];
        [userDefaults setObject:self.campaignId forKey:@"ATCampaign"];
        [userDefaults synchronize];
        
    }
    
    [self.tracker setStringParam:@"xto" value:self.campaignId options:encodeOption];
    
    NSString *lastPersistence = [self.tracker.configuration.parameters objectForKey:@"campaignLastPersistence"];
    if (lastPersistence) {
        if ([[lastPersistence lowercaseString] isEqualToString:@"true"]) {
            [userDefaults setObject:[NSDate date] forKey:@"ATCampaignDate"];
            [userDefaults setObject:self.campaignId forKey:@"ATCampaign"];
            [userDefaults synchronize];
        }
    }
    
}

@end


@implementation ATCampaigns

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
    }
    
    return self;
}

- (ATCampaign *)addWithId:(NSString *)campaignId {
    ATCampaign *camp = [[ATCampaign alloc] initWithTracker:self.tracker];
    camp.campaignId = campaignId;
    
    [self.tracker.businessObjects setObject:camp forKey:camp._id];
    
    return camp;
}

@end
