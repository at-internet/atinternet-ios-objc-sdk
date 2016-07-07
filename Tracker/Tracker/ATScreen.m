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
//  ATScreen.m
//  Tracker
//

#import "ATScreen.h"
#import "ATEvent.h"
#import "ATTracker.h"
#import "ATParamOption.h"
#import "ATDispatcher.h"


@implementation ATScreenInfo

@end


@implementation ATAbstractScreen

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super initWithTracker:tracker];
    
    if (self) {
        self.name = @"";
        self.action = ATScreenActionView;
    }
    
    return self;
}

- (void)setEvent {
    
    if (self.level2) {
        [self.tracker setIntParam:@"s2" value:self.level2];
    }
    
    if (self.isBasketScreen) {
        [self.tracker setStringParam:@"tp" value:@"cart"];
    }
    
}

- (void)sendView {
    [self.tracker.dispatcher dispatch:@[self]];
}

- (NSString *)getStringAction:(ATScreenAction)action {
    
    NSString *converted;
    
    switch (action) {
        case ATScreenActionView:
            converted = @"view";
            break;
        default:
            converted = @"view";
            break;
    }
    
    return converted;
    
}

@end


@implementation ATScreen

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super initWithTracker:tracker];
    
    if (self) {
        //
    }
    
    return self;
}

- (void)setEvent {
    
    [super setEvent];
    
    [self.tracker.event setWithCategory:@"screen" action:[self getStringAction:self.action] label:[self buildScreenName]];
    
}

- (NSString *)buildScreenName {
    
    NSString *screenName = !self.chapter1 ? @"" : [self.chapter1 stringByAppendingString:@"::"];
    screenName = !self.chapter2 ? screenName : [[screenName stringByAppendingString:self.chapter2] stringByAppendingString:@"::"];
    screenName = !self.chapter3 ? screenName : [[screenName stringByAppendingString:self.chapter3] stringByAppendingString:@"::"];
    screenName = [screenName stringByAppendingString:self.name];
    
    return screenName;
    
}

@end


@interface ATDynamicScreen()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation ATDynamicScreen

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super initWithTracker:tracker];
    
    if (self) {
        self.update = [NSDate date];
        self.dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    return self;
}

- (void)setEvent {
    
    [super setEvent];
    ATParamOption *encodeOption = [[ATParamOption alloc] init];
    encodeOption.encode = YES;
    
    [self.tracker setStringParam:@"pchap" value:[self buildChapters] options:encodeOption];
    
    if([self.screenId length] > 255){
        self.screenId = @"";
        if(self.tracker.delegate){
            if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.tracker.delegate warningDidOccur:@"screenId too long, replaced by empty value"];
            }
        }
    }
    [self.tracker setStringParam:@"pid" value:self.screenId];
    
    self.dateFormatter.dateFormat = @"YYYYMMddHHmm";
    self.dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [self.tracker setStringParam:@"pidt" value:[self.dateFormatter stringFromDate:self.update]];
    
    [self.tracker.event setWithCategory:@"screen" action:[self getStringAction:self.action] label:self.name];
    
}

- (NSString *)buildChapters {
    
    NSMutableString *value = [[NSMutableString alloc] initWithFormat:@""];
    
    if (self.chapter1) {
        [value appendString:self.chapter1];
    }
    
    if (self.chapter2) {
        ([value isEqualToString:@""]) ? [value appendString:self.chapter2] : [value appendFormat:@"::%@", self.chapter2];
    }
    
    if (self.chapter3) {
        ([value isEqualToString:@""]) ? [value appendString:self.chapter3] : [value appendFormat:@"::%@", self.chapter3];
    }
    
    return value;
    
}

@end


@implementation ATScreens

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
    }
    
    return self;
}

- (ATScreen *)add {
    ATScreen *screen = [[ATScreen alloc] initWithTracker:self.tracker];
    
    [self.tracker.businessObjects setObject:screen forKey:screen._id];
    
    return screen;
}

- (ATScreen *)addWithName:(NSString *)name {
    ATScreen *screen = [[ATScreen alloc] initWithTracker:self.tracker];
    screen.name = name;
    
    [self.tracker.businessObjects setObject:screen forKey:screen._id];
    
    return screen;
}

- (ATScreen *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 {
    ATScreen *screen = [[ATScreen alloc] initWithTracker:self.tracker];
    screen.name = name;
    screen.chapter1 = chapter1;
    
    [self.tracker.businessObjects setObject:screen forKey:screen._id];
    
    return screen;
}

- (ATScreen *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2 {
    ATScreen *screen = [[ATScreen alloc] initWithTracker:self.tracker];
    screen.name = name;
    screen.chapter1 = chapter1;
    screen.chapter2 = chapter2;
    
    [self.tracker.businessObjects setObject:screen forKey:screen._id];
    
    return screen;
}

- (ATScreen *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2 chapter3:(NSString *)chapter3 {
    ATScreen *screen = [[ATScreen alloc] initWithTracker:self.tracker];
    screen.name = name;
    screen.chapter1 = chapter1;
    screen.chapter2 = chapter2;
    screen.chapter3 = chapter3;
    
    [self.tracker.businessObjects setObject:screen forKey:screen._id];
    
    return screen;
}

@end


@implementation ATDynamicScreens

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
    }
    
    return self;
}

- (ATDynamicScreen *)addWithId:(int)screenId update:(NSDate *)update name:(NSString *)name {
    ATDynamicScreen *dScreen = [[ATDynamicScreen alloc] initWithTracker:self.tracker];
    dScreen.screenId = [NSString stringWithFormat:@"%i", screenId];
    dScreen.update = update;
    dScreen.name = name;
    
    [self.tracker.businessObjects setObject:dScreen forKey:dScreen._id];
    
    return dScreen;
}

- (ATDynamicScreen *)addWithStringId:(NSString *)screenId update:(NSDate *)update name:(NSString *)name {
    ATDynamicScreen *dScreen = [[ATDynamicScreen alloc] initWithTracker:self.tracker];
    dScreen.screenId = screenId;
    dScreen.update = update;
    dScreen.name = name;
    
    [self.tracker.businessObjects setObject:dScreen forKey:dScreen._id];
    
    return dScreen;
}

- (ATDynamicScreen *)addWithId:(int)screenId update:(NSDate *)update name:(NSString *)name chapter1:(NSString *)chapter1 {
    ATDynamicScreen *dScreen = [[ATDynamicScreen alloc] initWithTracker:self.tracker];
    dScreen.screenId = [NSString stringWithFormat:@"%i", screenId];
    dScreen.update = update;
    dScreen.name = name;
    dScreen.chapter1 = chapter1;
    
    [self.tracker.businessObjects setObject:dScreen forKey:dScreen._id];
    
    return dScreen;
}


- (ATDynamicScreen *)addWithStringId:(NSString *)screenId update:(NSDate *)update name:(NSString *)name chapter1:(NSString *)chapter1 {
    ATDynamicScreen *dScreen = [[ATDynamicScreen alloc] initWithTracker:self.tracker];
    dScreen.screenId = screenId;
    dScreen.update = update;
    dScreen.name = name;
    dScreen.chapter1 = chapter1;
    
    [self.tracker.businessObjects setObject:dScreen forKey:dScreen._id];
    
    return dScreen;
}

- (ATDynamicScreen *)addWithId:(int)screenId
                  update:(NSDate *)update
                    name:(NSString *)name
                chapter1:(NSString *)chapter1
                chapter2:(NSString *)chapter2 {
    ATDynamicScreen *dScreen = [[ATDynamicScreen alloc] initWithTracker:self.tracker];
    dScreen.screenId = [NSString stringWithFormat:@"%i", screenId];
    dScreen.update = update;
    dScreen.name = name;
    dScreen.chapter1 = chapter1;
    dScreen.chapter2 = chapter2;
    
    [self.tracker.businessObjects setObject:dScreen forKey:dScreen._id];
    
    return dScreen;
}

- (ATDynamicScreen *)addWithStringId:(NSString *)screenId
                        update:(NSDate *)update
                          name:(NSString *)name
                      chapter1:(NSString *)chapter1
                      chapter2:(NSString *)chapter2 {
    ATDynamicScreen *dScreen = [[ATDynamicScreen alloc] initWithTracker:self.tracker];
    dScreen.screenId = screenId;
    dScreen.update = update;
    dScreen.name = name;
    dScreen.chapter1 = chapter1;
    dScreen.chapter2 = chapter2;
    
    [self.tracker.businessObjects setObject:dScreen forKey:dScreen._id];
    
    return dScreen;
}

- (ATDynamicScreen *)addWithId:(int)screenId
                  update:(NSDate *)update
                    name:(NSString *)name
                chapter1:(NSString *)chapter1
                chapter2:(NSString *)chapter2
                chapter3:(NSString *)chapter3 {
    ATDynamicScreen *dScreen = [[ATDynamicScreen alloc] initWithTracker:self.tracker];
    dScreen.screenId = [NSString stringWithFormat:@"%i", screenId];
    dScreen.update = update;
    dScreen.name = name;
    dScreen.chapter1 = chapter1;
    dScreen.chapter2 = chapter2;
    dScreen.chapter3 = chapter3;
    
    [self.tracker.businessObjects setObject:dScreen forKey:dScreen._id];
    
    return dScreen;
}

- (ATDynamicScreen *)addWithStringId:(NSString *)screenId
                        update:(NSDate *)update
                          name:(NSString *)name
                      chapter1:(NSString *)chapter1
                      chapter2:(NSString *)chapter2
                      chapter3:(NSString *)chapter3 {
    ATDynamicScreen *dScreen = [[ATDynamicScreen alloc] initWithTracker:self.tracker];
    dScreen.screenId = screenId;
    dScreen.update = update;
    dScreen.name = name;
    dScreen.chapter1 = chapter1;
    dScreen.chapter2 = chapter2;
    dScreen.chapter3 = chapter3;
    
    [self.tracker.businessObjects setObject:dScreen forKey:dScreen._id];
    
    return dScreen;
}

@end
