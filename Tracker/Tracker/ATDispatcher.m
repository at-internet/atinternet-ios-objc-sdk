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
//  ATDispatcher.m
//  Tracker
//

#import "ATDispatcher.h"
#import "ATHit.h"
#import "ATTechnicalContext.h"
#import "ATCrash.h"
#import "ATParamOption.h"
#import "ATTracker.h"
#import "ATBuffer.h"
#import "ATBuilder.h"
#import "ATTool.h"
#import "ATTrackerQueue.h"
#import "ATConfiguration.h"
#import "ATLifeCycle.h"
#import "ATBusinessObject.h"
#import "ATScreen.h"
#import "ATGesture.h"
#import "ATPublisher.h"
#import "ATSelfPromotion.h"
#import "ATCustomObject.h"
#import "ATCustomVar.h"
#import "ATLocation.h"
#import "ATOrder.h"
#import "ATAisle.h"
#import "ATCart.h"
#import "ATNuggAd.h"
#import "ATInternalSearch.h"
#import "ATContext.h"

@interface ATDispatcher()

@property (nonatomic, strong) ATTracker *tracker;

@end


@implementation ATDispatcher

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
    }
    
    return self;
}

- (void)dispatch:(NSArray *)businessObjects {
    
    if (businessObjects) {
        
        for (ATBusinessObject *businessObject in businessObjects) {
            
            if ([businessObject isKindOfClass:[ATAbstractScreen class]]) {
                
                [businessObject setEvent];
                
                BOOL hasOrder = NO;

                NSDictionary *iteratingCollection = [[NSDictionary alloc] initWithDictionary:self.tracker.businessObjects];
                for (NSString *key in iteratingCollection) {
                    
                    ATBusinessObject *sub_businessObject = [self.tracker.businessObjects objectForKey:key];
                    
                    if (([sub_businessObject isKindOfClass:[ATScreenInfo class]] ||
                        [sub_businessObject isKindOfClass:[ATInternalSearch class]] ||
                        [sub_businessObject isKindOfClass:[ATOrder class]] ||
                        ([sub_businessObject isKindOfClass:[ATOnAppAd class]] && ((ATOnAppAd *)sub_businessObject).action == ATAdActionView)) &&
                        sub_businessObject.timeStamp <= businessObject.timeStamp) {
                        
                        if ([sub_businessObject isKindOfClass:[ATOrder class]]) {
                            hasOrder = YES;
                        }
                        
                        [sub_businessObject setEvent];
                        [self.tracker.businessObjects removeObjectForKey:sub_businessObject._id];
                        
                    }
                    
                }
                
                if (![self.tracker.cart.cartId isEqualToString:@""] && (((ATScreen *)businessObject).isBasketScreen || hasOrder)) {
                    [self.tracker.cart setEvent];
                }
                
                [self.tracker.businessObjects removeObjectForKey:businessObject._id];
                
            } else if ([businessObject isKindOfClass:[ATGesture class]]) {
                
                [businessObject setEvent];
                
                if (((ATGesture *)businessObject).action == ATGestureActionSearch) {
                    
                    NSDictionary *iteratingCollection = [[NSDictionary alloc] initWithDictionary:self.tracker.businessObjects];
                    for (NSString *key in iteratingCollection) {
                        
                        ATBusinessObject *sub_businessObject = [self.tracker.businessObjects objectForKey:key];
                        
                        if ([sub_businessObject isKindOfClass:[ATInternalSearch class]] &&
                            sub_businessObject.timeStamp <= businessObject.timeStamp) {
                            
                            [sub_businessObject setEvent];
                            [self.tracker.businessObjects removeObjectForKey:sub_businessObject._id];
                            
                        }
                        
                    }
                    
                }
                
                [self.tracker.businessObjects removeObjectForKey:businessObject._id];
                
            } else {
                
                [businessObject setEvent];
                [self.tracker.businessObjects removeObjectForKey:businessObject._id];
                
            }
            
            NSDictionary *iteratingCollection = [[NSDictionary alloc] initWithDictionary:self.tracker.businessObjects];
            for (NSString *key in iteratingCollection) {
                
                ATBusinessObject *sub_businessObject = [self.tracker.businessObjects objectForKey:key];
                
                if ([sub_businessObject isKindOfClass:[ATCustomObject class]] ||
                    [sub_businessObject isKindOfClass:[ATNuggAd class]] ) {
                    
                    if (sub_businessObject.timeStamp <= businessObject.timeStamp) {
                        [sub_businessObject setEvent];
                        [self.tracker.businessObjects removeObjectForKey:sub_businessObject._id];
                    }
                    
                }
                
            }
            
        }
        
    }

    // Saves screen name and level 2 in context if hit type is Screen
    if([ATHit hitType:self.tracker.buffer.volatileParameters, self.tracker.buffer.persistentParameters] == ATHitTypeScreen) {
        
        ATTechnicalContext.screenName = [ATTool appendParameterValues:@"p" volatileParameters:self.tracker.buffer.volatileParameters peristentParameters:self.tracker.buffer.persistentParameters];
        
        ATTechnicalContext.level2 = [[ATTool appendParameterValues:@"s2" volatileParameters:self.tracker.buffer.volatileParameters peristentParameters:self.tracker.buffer.persistentParameters] integerValue];
        
        [ATCrash lastScreen:ATTechnicalContext.screenName];
        
    }
    
    // Add life cycle metrics in stc variable
    ATParamOption* appendOptionWithEncoding = [[ATParamOption alloc] init];
    appendOptionWithEncoding.append = YES;
    appendOptionWithEncoding.encode = YES;
    
    [self.tracker setClosureParam:@"stc" value:[self.tracker.lifeCycle getMetrics] options:appendOptionWithEncoding];
    
    // Add crash report if available in stc variable
    NSDictionary* report = [ATCrash compute];
    
    if(report) {
        [self.tracker setDictionaryParam:@"stc" value:report options:appendOptionWithEncoding];
    }
    
    // Add persistent identified visitor data if required
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *conf = self.tracker.configuration.parameters[ATIdentifiedVisitorConfiguration];
    
    if (conf) {
        if ([[conf lowercaseString] isEqualToString:@"true"]) {
            NSString *num = [userDefaults objectForKey:ATIdentifiedVisitorNumeric];
            if (num) {
                [self.tracker setStringParam:@"an" value:num];
            }
            NSString *tex = [userDefaults objectForKey:ATIdentifiedVisitorText];
            if (tex) {
                ATParamOption *encodeOption = [[ATParamOption alloc] init];
                encodeOption.encode = YES;
                [self.tracker setStringParam:@"at" value:tex options:encodeOption];
            }
            NSString *cat = [userDefaults objectForKey:ATIdentifiedVisitorCategory];
            if (cat) {
                [self.tracker setStringParam:@"ac" value:cat];
            }
        }
    }
    
    // Creation of hit builder task to execute in background thread
    ATBuilder *builder = [[ATBuilder alloc] initWithTracker:self.tracker
                                         volatileParameters:[ATTool copyParamArray:self.tracker.buffer.volatileParameters]
                                       persistentParameters:[ATTool copyParamArray:self.tracker.buffer.persistentParameters]];
    
    
    // Remove all non persistent parameters from buffer
    [self.tracker.buffer.volatileParameters removeAllObjects];
    
    // Add hit builder task to queue
    [[[ATTrackerQueue sharedInstance] queue] addOperation:builder];
    
    // Set level2 context param back in case level2 id were overriden for one hit
    self.tracker.context.level2 = self.tracker.context.level2;
}

@end
