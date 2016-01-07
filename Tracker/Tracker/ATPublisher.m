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
//  ATPublisher.m
//  Tracker
//

#import "ATPublisher.h"
#import "ATTracker.h"
#import "ATDispatcher.h"
#import "ATParamOption.h"
#import "ATBuffer.h"
#import "ATTool.h"
#import "ATParam.h"


@implementation ATPublisher

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super initWithTracker:tracker];
    
    if (self) {
        self.campaignId = @"";
    }
    
    return self;
}

- (void)setEvent {
    
    NSString *prefix = @"PUB";
    NSString *separator = @"-";
    NSString *defaultType = @"AT";
    NSString *currentType = @"";
    
    NSMutableString *spot = [NSMutableString stringWithFormat:@"%@%@%@%@", prefix, separator, self.campaignId, separator];
    
    if (self.creation) {
        [spot appendFormat:@"%@%@", self.creation, separator];
    } else {
        [spot appendFormat:@"%@", separator];
    }
    
    if (self.variant) {
        [spot appendFormat:@"%@%@", self.variant, separator];
    } else {
        [spot appendFormat:@"%@", separator];
    }
    
    if (self.format) {
        [spot appendFormat:@"%@%@", self.format, separator];
    } else {
        [spot appendFormat:@"%@", separator];
    }
    
    if (self.generalPlacement) {
        [spot appendFormat:@"%@%@", self.generalPlacement, separator];
    } else {
        [spot appendFormat:@"%@", separator];
    }
    
    if (self.detailedPlacement) {
        [spot appendFormat:@"%@%@", self.detailedPlacement, separator];
    } else {
        [spot appendFormat:@"%@", separator];
    }
    
    if (self.advertiserId) {
        [spot appendFormat:@"%@%@", self.advertiserId, separator];
    } else {
        [spot appendFormat:@"%@", separator];
    }
    
    if (self.url) {
        [spot appendFormat:@"%@", self.url];
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


@implementation ATPublishers

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
    }
    
    return self;
}

- (ATPublisher *)addWithId:(NSString *)campaignId {
    ATPublisher *publisher = [[ATPublisher alloc] initWithTracker:self.tracker];
    publisher.campaignId = campaignId;
    
    [self.tracker.businessObjects setObject:publisher forKey:publisher._id];
    
    return publisher;
}

- (void)sendImpressions {
    NSMutableArray *impressions = [[NSMutableArray alloc] init];
    
    for (NSString *key in self.tracker.businessObjects) {
        if ([[self.tracker.businessObjects objectForKey:key] isKindOfClass:[ATPublisher class]]) {
            ATPublisher *publisher = (ATPublisher *)[self.tracker.businessObjects objectForKey:key];
            if (publisher.action == ATAdActionView) {
                [impressions addObject:publisher];
            }
        }
    }
    
    if ([impressions count] > 0) {
        [self.tracker.dispatcher dispatch:impressions];
    }
    
}

@end
