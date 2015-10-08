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
//  ATCustomVar.m
//  Tracker
//

#import "ATCustomVar.h"
#import "ATTracker.h"
#import "ATParamOption.h"


@interface ATCustomVar()

@property (nonatomic) int varId;
@property (nonatomic) ATCustomVarType type;
@property (nonatomic, strong) NSString *value;

@end

@implementation ATCustomVar

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super initWithTracker:tracker];
    
    if (self) {
        self.value = @"";
        self.type = ATCustomVarTypeApp;
        self.varId = 1;
    }
    
    return self;
}

- (void)setEvent {
    
    if (self.varId < 1) {
        self.varId = 1;
    }
    
    ATParamOption *encodeOption = [[ATParamOption alloc] init];
    encodeOption.encode = YES;
    
    NSString *key = [[NSString alloc] initWithFormat:@"%@%d", [self getStringType:self.type], self.varId];
    [self.tracker setStringParam:key value:self.value options:encodeOption];
}

- (NSString *)getStringType:(ATCustomVarType)type {
    
    NSString *converted;
    
    switch (type) {
        case ATCustomVarTypeApp:
            converted = @"x";
            break;
        case ATCustomVarTypeScreen:
            converted = @"f";
            break;
        default:
            converted = @"x";
            break;
    }
    
    return converted;
    
}

@end


@implementation ATCustomVars

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
    }
    
    return self;
}

- (ATCustomVar *)addWithId:(int)varId value:(NSString *)value type:(ATCustomVarType)type {
    ATCustomVar *customVar = [[ATCustomVar alloc] initWithTracker:self.tracker];
    customVar.varId = varId;
    customVar.value = value;
    customVar.type = type;
    
    [self.tracker.businessObjects setObject:customVar forKey:customVar._id];
    
    return customVar;
}

@end
