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
//  ATNuggAd.m
//  Tracker
//

#import "ATNuggAd.h"
#import "ATTracker.h"
#import "ATConfiguration.h"
#import "ATParamOption.h"


@implementation ATNuggAd

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super initWithTracker:tracker];
    
    if (self) {
        self.data = [[NSDictionary alloc] init];
    }
    
    return self;
}

- (void)setEvent {
    
    NSString *plugin = [self.tracker.configuration.parameters objectForKey:@"plugins"];
    NSRange rangeNGA = [[plugin lowercaseString] rangeOfString:[@"nuggad" lowercaseString]];
    
    if(plugin) {
        if(rangeNGA.location != NSNotFound) {
            ATParamOption *option = [[ATParamOption alloc] init];
            option.append = YES;
            option.encode = YES;
            [self.tracker setDictionaryParam:@"stc" value:@{@"nuggad": self.data} options:option];
        } else {
            if(self.tracker.delegate) {
                if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                    [self.tracker.delegate warningDidOccur:@"NuggAd not enabled"];
                }
            }
        }
    } else {
        if(self.tracker.delegate) {
            if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.tracker.delegate warningDidOccur:@"NuggAd not enabled"];
            }
        }
    }
    
}

@end


@implementation ATNuggAds

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
    }
    
    return self;
}

- (ATNuggAd *)addWithData:(NSDictionary *)data {
    ATNuggAd *nuggad = [[ATNuggAd alloc] initWithTracker:self.tracker];
    nuggad.data = [[NSDictionary alloc] initWithDictionary:data];
    
    [self.tracker.businessObjects setObject:nuggad forKey:nuggad._id];
    
    return nuggad;
}

@end
