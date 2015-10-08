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
//  ATContext.m
//  Tracker
//

#import "ATContext.h"
#import "ATTracker.h"
#import "ATParamOption.h"

#define AT_BACKGROUND_MODE_KEY  @"bg"
#define AT_LEVEL_2_KEY          @"s2"

@interface ATContext()

@property (nonatomic, strong) ATTracker *tracker;
@property (nonatomic, strong) ATParamOption *option;

@end


@implementation ATContext

@synthesize backgroundMode = _backgroundMode;
@synthesize level2 = _level2;

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
        self.option = [[ATParamOption alloc] init];
        self.option.persistent = YES;
        _backgroundMode = ATBackgroundModeNormal;
        _level2 = 0;
    }
    
    return self;
}

- (ATBackgroundMode)backgroundMode {
    return _backgroundMode;
}

- (void)setBackgroundMode:(ATBackgroundMode)backgroundMode {
    _backgroundMode = backgroundMode;
    
    switch (self.backgroundMode) {
        case ATBackgroundModeFetch:
            [self.tracker setStringParam:AT_BACKGROUND_MODE_KEY value:@"fetch" options:self.option];
            break;
        case ATBackgroundModeTask:
            [self.tracker setStringParam:AT_BACKGROUND_MODE_KEY value:@"task" options:self.option];
            break;
        default:
            [self.tracker unsetParam:AT_BACKGROUND_MODE_KEY];
            break;
    }
}

- (int)level2 {
    return _level2;
}

- (void)setLevel2:(int)level2 {
    _level2 = level2;
    
    if (_level2 > 0) {
        [self.tracker setIntParam:AT_LEVEL_2_KEY value:_level2 options:self.option];
    } else {
        [self.tracker unsetParam:AT_LEVEL_2_KEY];
    }
    
    
}

@end
