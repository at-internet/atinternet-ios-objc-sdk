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
//  ATParameter.m
//  Tracker
//


#import "ATParam.h"
#import "ATTracker.h"
#import "ATConfiguration.h"


@implementation ATPluginParam

+ (NSDictionary *) list:(ATTracker *)tracker {
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    
    NSString* plugin = [tracker.configuration.parameters objectForKey:@"plugins"];
    
    NSRange rangeTVT = [[plugin lowercaseString] rangeOfString:[@"tvtracking" lowercaseString]];
    
    if(plugin) {
        if(rangeTVT.location != NSNotFound) {
            [dic setObject:@"ATTVTrackingPlugin" forKey:@"tvt"];
        }
    }
    
    return dic;
}

@end

@implementation ATReadOnlyParam

+ (NSSet *) list {
    static NSSet* list = nil;
    
    if (list == nil)
    {
        list = [NSSet setWithArray:@[@"vtag",
                                     @"lng",
                                     @"mfmd",
                                     @"os",
                                     @"apvr",
                                     @"hl",
                                     @"r",
                                     @"car",
                                     @"cn",
                                     @"ts",
                                     @"olt"]];
        
        return list;
    }
    
    return list;
}
@end

@implementation ATSliceReadyParam

+ (NSSet *) list {
    static NSSet* list = nil;
    
    if (list == nil)
    {
        list = [NSSet setWithArray:@[@"stc",
                                     @"ati",
                                     @"atc",
                                     @"pdtl"]];
        
        return list;
    }
    
    return list;
}
@end


@implementation ATParam

- (instancetype)init {
    return [self init:@"" value:^NSString* () { return @"";} type: ATParamTypeUnknown];
}

- (instancetype)init:(NSString *)key value:(NSString * (^)())value type:(ATParamType)type {
    return [self init: key value: value type: type options:nil];
}

- (instancetype)init:(NSString *)key value:(NSString * (^)())value type:(ATParamType)type options:(ATParamOption *)options {
    if (self = [super init]) {
        self.key = key;
        self.value = value;
        self.options = options;
        self.type = type;
    }
    return self;
}

@end
