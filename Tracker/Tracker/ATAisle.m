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
//  ATAisle.m
//  Tracker
//

#import "ATAisle.h"
#import "ATTracker.h"
#import "ATParamOption.h"


@implementation ATAisle

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super initWithTracker:tracker];
    
    if (self) {
    }
    
    return self;
}

- (void)setEvent {
    
    NSMutableString *value = [[NSMutableString alloc] initWithFormat:@""];
    
    if (self.level1) {
        [value appendString:self.level1];
    }
    
    if (self.level2) {
        if ([value isEqualToString:@""]) {
            [value appendString:self.level2];
        } else {
            [value appendFormat:@"::%@", self.level2];
        }
    }
    
    if (self.level3) {
        if ([value isEqualToString:@""]) {
            [value appendString:self.level3];
        } else {
            [value appendFormat:@"::%@", self.level3];
        }
    }
    
    if (self.level4) {
        if ([value isEqualToString:@""]) {
            [value appendString:self.level4];
        } else {
            [value appendFormat:@"::%@", self.level4];
        }
    }
    
    if (self.level5) {
        if ([value isEqualToString:@""]) {
            [value appendString:self.level5];
        } else {
            [value appendFormat:@"::%@", self.level5];
        }
    }
    
    if (self.level6) {
        if ([value isEqualToString:@""]) {
            [value appendString:self.level6];
        } else {
            [value appendFormat:@"::%@", self.level6];
        }
    }
    
    if (value) {
        ATParamOption *encodeOption = [[ATParamOption alloc] init];
        encodeOption.encode = YES;
        [self.tracker setStringParam:@"aisl" value:value options:encodeOption];
    }
    
}

@end

@implementation ATAisles

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
    }
    
    return self;
}

- (ATAisle *)addWithLevel1:(NSString *)level1 {
    ATAisle *aisle = [[ATAisle alloc] initWithTracker:self.tracker];
    aisle.level1 = level1;
    
    [self.tracker.businessObjects setObject:aisle forKey:aisle._id];
    
    return aisle;
}

- (ATAisle *)addWithLevel1:(NSString *)level1 level2:(NSString *)level2 {
    ATAisle *aisle = [self addWithLevel1:level1];
    aisle.level2 = level2;
    
    return aisle;
}

- (ATAisle *)addWithLevel1:(NSString *)level1 level2:(NSString *)level2 level3:(NSString *)level3 {
    ATAisle *aisle = [self addWithLevel1:level1 level2:level2];
    aisle.level3 = level3;
    
    return aisle;
}

- (ATAisle *)addWithLevel1:(NSString *)level1 level2:(NSString *)level2 level3:(NSString *)level3 level4:(NSString *)level4 {
    ATAisle *aisle = [self addWithLevel1:level1 level2:level2 level3:level3];
    aisle.level4 = level4;
    
    return aisle;
}

- (ATAisle *)addWithLevel1:(NSString *)level1 level2:(NSString *)level2 level3:(NSString *)level3 level4:(NSString *)level4 level5:(NSString *)level5 {
    ATAisle *aisle = [self addWithLevel1:level1 level2:level2 level3:level3 level4:level4];
    aisle.level5 = level5;
    
    return aisle;
}

- (ATAisle *)addWithLevel1:(NSString *)level1 level2:(NSString *)level2 level3:(NSString *)level3 level4:(NSString *)level4 level5:(NSString *)level5  level6:(NSString *)level6 {
    ATAisle *aisle = [self addWithLevel1:level1 level2:level2 level3:level3 level4:level4 level5:level5];
    aisle.level6 = level6;
    
    return aisle;
}

@end
