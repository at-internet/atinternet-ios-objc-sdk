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
//  ATCustomObject.m
//  Tracker
//

#import "ATCustomObject.h"
#import "ATTool.h"
#import "ATParamOption.h"
#import "ATTracker.h"


@implementation ATCustomObject

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super initWithTracker:tracker];
    
    if (self) {
        self.json = @"{}";
    }
    
    return self;
}

- (void)setEvent {
    
    ATParamOption *option = [[ATParamOption alloc] init];
    option.append = YES;
    option.encode = YES;
    
    [self.tracker setStringParam:@"stc" value:self.json options:option];
    
}

@end


@implementation ATCustomObjects

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
    }
    
    return self;
}


- (ATCustomObject *)addWithString:(NSString *)customObject {
    ATCustomObject *customObj = [[ATCustomObject alloc] initWithTracker:self.tracker];
    customObj.json = customObject;
    
    [self.tracker.businessObjects setObject:customObj forKey:customObj._id];
    
    return customObj;
}

- (ATCustomObject *)addWithDictionary:(NSDictionary *)customObject {
    ATCustomObject *customObj = [[ATCustomObject alloc] initWithTracker:self.tracker];
    customObj.json = [ATTool JSONStringify:customObject prettyPrinted:NO];
    
    [self.tracker.businessObjects setObject:customObj forKey:customObj._id];
    
    return customObj;
}

@end
