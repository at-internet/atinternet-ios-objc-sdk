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
//  ATIdentifiedVisitor.m
//  Tracker
//

#import "ATIdentifiedVisitor.h"
#import "ATTracker.h"
#import "ATParamOption.h"
#import "ATConfiguration.h"

@interface ATIdentifiedVisitor()

@property (nonatomic, strong) ATTracker *tracker;
@property (nonatomic, strong) ATParamOption *option;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end


@implementation ATIdentifiedVisitor


- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
        self.option = [[ATParamOption alloc] init];
        self.option.persistent = YES;
        self.userDefaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (ATTracker *)setWithNumericId:(int)visitorId {
    [self unset];
    [self saveKeyParameter:@"an" keyPersistent:ATIdentifiedVisitorNumeric intValue:visitorId];
    
    return self.tracker;
}

- (ATTracker *)setWithNumericId:(int)visitorId visitorCategory:(int)visitorCategory {
    [self setWithNumericId:visitorId];
    [self saveKeyParameter:@"ac" keyPersistent:ATIdentifiedVisitorCategory intValue:visitorCategory];
    
    return self.tracker;
}

- (ATTracker *)setWithTextId:(NSString *)visitorId {
    [self unset];
    [self saveKeyParameter:@"at" keyPersistent:ATIdentifiedVisitorText stringValue:visitorId];
    
    return self.tracker;
}

- (ATTracker *)setWithTextId:(NSString *)visitorId visitorCategory:(int)visitorCategory {
    [self setWithTextId:visitorId];
    [self saveKeyParameter:@"ac" keyPersistent:ATIdentifiedVisitorCategory intValue:visitorCategory];
    
    return self.tracker;
}

- (ATTracker *)unset {
    [self.tracker unsetParam:@"an"];
    [self.tracker unsetParam:@"at"];
    [self.tracker unsetParam:@"ac"];
    [self.userDefaults removeObjectForKey:ATIdentifiedVisitorNumeric];
    [self.userDefaults removeObjectForKey:ATIdentifiedVisitorText];
    [self.userDefaults removeObjectForKey:ATIdentifiedVisitorCategory];
    [self.userDefaults synchronize];
    
    return self.tracker;
}

- (void)saveKeyParameter:(NSString *)keyParameter keyPersistent:(NSString *)keyPersistent intValue:(int)value {
    [self saveKeyParameter:keyParameter keyPersistent:keyPersistent stringValue:[NSString stringWithFormat:@"%d", value]];
}

- (void)saveKeyParameter:(NSString *)keyParameter keyPersistent:(NSString *)keyPersistent stringValue:(NSString *)value {
    NSString *conf = [self.tracker.configuration.parameters objectForKey:ATIdentifiedVisitorConfiguration];
    if (conf) {
        if ([[conf lowercaseString] isEqualToString:@"true"]) {
            [self.userDefaults setObject:value forKey:keyPersistent];
            [self.userDefaults synchronize];
        } else {
            [self.tracker setStringParam:keyParameter value:value options:self.option];
        }
    } else {
        [self.tracker setStringParam:keyParameter value:value options:self.option];
    }
}

@end
