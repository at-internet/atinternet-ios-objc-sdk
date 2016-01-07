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
//  ATSelfPromotion.m
//  Tracker
//

#import "ATSelfPromotion.h"
#import "ATTracker.h"
#import "ATDispatcher.h"
#import "ATParamOption.h"
#import "ATBuffer.h"
#import "ATTool.h"
#import "ATParam.h"


@implementation ATSelfPromotion

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super initWithTracker:tracker];
    
    if (self) {
        self.adId = 0;
    }
    
    return self;
}

- (void)setEvent {
    
    NSString *prefix = @"INT";
    NSString *separator = @"-";
    NSString *doubleSeparator = @"||";
    NSString *defaultType = @"AT";
    NSString *currentType = @"";
    
    NSMutableString *spot = [NSMutableString stringWithFormat:@"%@%@%d%@", prefix, separator, self.adId, separator];
    
    if (self.format) {
        [spot appendString:self.format];
    }
    
    [spot appendString:doubleSeparator];
    
    if (self.productId) {
        [spot appendString:self.productId];
    }
    
    NSArray *bufferCollections = [[NSArray alloc] initWithObjects:self.tracker.buffer.persistentParameters, self.tracker.buffer.volatileParameters, nil];
    NSArray *positions = [ATTool findParameterPosition:@"type" array:bufferCollections];
    
    if ([positions count] > 0) {
        for (ATParamBufferPosition *position in positions) {
            if (position.arrayIndex == 0) {
                currentType = ((ATParam *)[self.tracker.buffer.persistentParameters objectAtIndex:position.index]).value();
            } else {
                currentType = ((ATParam *)[self.tracker.buffer.volatileParameters objectAtIndex:position.index]).value();
            }
        }
    }
    
    if (![currentType isEqualToString:@"screen"] && ![currentType isEqualToString:defaultType]) {
        [self.tracker setStringParam:@"type" value:defaultType];
    }
    
    ATParamOption *option = [[ATParamOption alloc] init];
    option.append = YES;
    option.encode = YES;
    [self.tracker setStringParam:[self getStringAction:self.action] value:spot options:option];
    
    if (self.action == ATAdActionTouch) {
        if(![ATTechnicalContext.screenName isEqualToString:@""]) {
            ATParamOption *encodeOption = [[ATParamOption alloc] init];
            encodeOption.encode = YES;
            [self.tracker setStringParam:@"patc" value:ATTechnicalContext.screenName options:encodeOption];
        }
        
        if (ATTechnicalContext.level2 > 0) {
            [self.tracker setIntParam:@"s2atc" value:ATTechnicalContext.level2];
        }
    }
    
}

- (void)sendTouch {
    self.action = ATAdActionTouch;
    [self.tracker.dispatcher dispatch:@[self]];
}

- (void)sendImpression {
    self.action = ATAdActionView;
    [self.tracker.dispatcher dispatch:@[self]];
}

@end


@implementation ATSelfPromotions

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
    }
    
    return self;
}

- (ATSelfPromotion *)addWithId:(int)adId {
    ATSelfPromotion *selfPromotion = [[ATSelfPromotion alloc] initWithTracker:self.tracker];
    selfPromotion.adId = adId;
    
    [self.tracker.businessObjects setObject:selfPromotion forKey:selfPromotion._id];
    
    return selfPromotion;
}

- (void)sendImpressions {
    NSMutableArray *impressions = [[NSMutableArray alloc] init];
    
    for (NSString *key in self.tracker.businessObjects) {
        if ([[self.tracker.businessObjects objectForKey:key] isKindOfClass:[ATSelfPromotion class]]) {
            ATSelfPromotion *selfPromotion = (ATSelfPromotion *)[self.tracker.businessObjects objectForKey:key];
            if (selfPromotion.action == ATAdActionView) {
                [impressions addObject:selfPromotion];
            }
        }
    }
    
    if ([impressions count] > 0) {
        [self.tracker.dispatcher dispatch:impressions];
    }
    
}

@end
