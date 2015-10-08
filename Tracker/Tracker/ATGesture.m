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
//  ATGesture.m
//  Tracker
//

#import "ATGesture.h"
#import "ATTechnicalContext.h"
#import "ATEvent.h"
#import "ATTracker.h"
#import "ATDispatcher.h"
#import "ATParamOption.h"


@interface ATGesture()

@property (nonatomic, strong, readonly) ATEvent* event;

@end


@implementation ATGesture

@synthesize event = _event;

- (ATEvent *)event {
    if(!_event) {
        _event = [[ATEvent alloc] initWithTracker:self.tracker];
    }
    
    return _event;
}

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super initWithTracker:tracker];
    
    if (self) {
        self.name = @"";
        self.action = ATGestureActionTouch;
    }
    
    return self;
}

- (void)setEvent {
    
    if(![ATTechnicalContext.screenName isEqualToString:@""]) {
        ATParamOption *encodingOption = [[ATParamOption alloc] init];
        encodingOption.encode = YES;
        [self.tracker setStringParam:@"pclick" value:ATTechnicalContext.screenName options:encodingOption];
    }
    
    if(ATTechnicalContext.level2 > 0) {
        [self.tracker setIntParam:@"s2click" value:ATTechnicalContext.level2];
    }
    
    if (self.level2) {
        [self.tracker setIntParam:@"s2" value:self.level2];
    }
    
    [self.tracker setStringParam:@"click" value:[self getStringAction:self.action]];
    [self.event setWithCategory:@"click" action:[self getStringAction:self.action] label:[self buildGestureName]];
    
}

- (void)sendNavigation {
    self.action = ATGestureActionNavigate;
    [self.tracker.dispatcher dispatch:@[self]];
}

- (void)sendExit {
    self.action = ATGestureActionExit;
    [self.tracker.dispatcher dispatch:@[self]];
}

- (void)sendDownload {
    self.action = ATGestureActionDownload;
    [self.tracker.dispatcher dispatch:@[self]];
}

- (void)sendTouch {
    self.action = ATGestureActionTouch;
    [self.tracker.dispatcher dispatch:@[self]];
}

- (void)sendSearch {
    self.action = ATGestureActionSearch;
    [self.tracker.dispatcher dispatch:@[self]];
}

- (NSString *)getStringAction:(ATGestureAction)action {
    
    NSString *converted;
    
    switch (action) {
        case ATGestureActionTouch:
            converted = @"A";
            break;
        case ATGestureActionNavigate:
            converted = @"N";
            break;
        case ATGestureActionDownload:
            converted = @"T";
            break;
        case ATGestureActionExit:
            converted = @"S";
            break;
        case ATGestureActionSearch:
            converted = @"IS";
            break;
        default:
            converted = @"A";
            break;
    }
    
    return converted;
    
}

- (NSString *)buildGestureName {
    
    NSString *touchName = !self.chapter1 ? @"" : [self.chapter1 stringByAppendingString:@"::"];
    touchName = !self.chapter2 ? touchName : [[touchName stringByAppendingString:self.chapter2] stringByAppendingString:@"::"];
    touchName = !self.chapter3 ? touchName : [[touchName stringByAppendingString:self.chapter3] stringByAppendingString:@"::"];
    touchName = [touchName stringByAppendingString:self.name];
    
    return touchName;
    
}

@end


@implementation ATGestures

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
    }
    
    return self;
}

- (ATGesture *)add {
    ATGesture *gesture = [[ATGesture alloc] initWithTracker:self.tracker];
    
    [self.tracker.businessObjects setObject:gesture forKey:gesture._id];
    
    return gesture;
}

- (ATGesture *)addWithName:(NSString *)name {
    ATGesture *gesture = [[ATGesture alloc] initWithTracker:self.tracker];
    gesture.name = name;
    
    [self.tracker.businessObjects setObject:gesture forKey:gesture._id];
    
    return gesture;
}

- (ATGesture *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 {
    ATGesture *gesture = [[ATGesture alloc] initWithTracker:self.tracker];
    gesture.name = name;
    gesture.chapter1 = chapter1;
    
    [self.tracker.businessObjects setObject:gesture forKey:gesture._id];
    
    return gesture;
}

- (ATGesture *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2 {
    ATGesture *gesture = [[ATGesture alloc] initWithTracker:self.tracker];
    gesture.name = name;
    gesture.chapter1 = chapter1;
    gesture.chapter2 = chapter2;
    
    [self.tracker.businessObjects setObject:gesture forKey:gesture._id];
    
    return gesture;
}

- (ATGesture *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2 chapter3:(NSString *)chapter3 {
    ATGesture *gesture = [[ATGesture alloc] initWithTracker:self.tracker];
    gesture.name = name;
    gesture.chapter1 = chapter1;
    gesture.chapter2 = chapter2;
    gesture.chapter3 = chapter3;
    
    [self.tracker.businessObjects setObject:gesture forKey:gesture._id];
    
    return gesture;
}

@end
