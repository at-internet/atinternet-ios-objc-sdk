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
//  ATInternalSearch.m
//  Tracker
//

#import "ATInternalSearch.h"
#import "ATTracker.h"

@implementation ATInternalSearch

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super initWithTracker:tracker];
    
    if (self) {
        self.keyword = @"";
        self.resultScreenNumber = 1;
        self.resultPosition = -1;
    }
    
    return self;
}

- (void)setEvent {
    [self.tracker setStringParam:@"mc" value:self.keyword];
    [self.tracker setIntParam:@"np" value:self.resultScreenNumber];
    
    if (self.resultPosition > -1) {
        [self.tracker setIntParam:@"mcrg" value:self.resultPosition];
    }
}

@end


@implementation ATInternalSearches

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
    }
    
    return self;
}

- (ATInternalSearch *)addWithKeyword:(NSString *)keyword resultScreenNumber:(int)resultScreenNumber {
    ATInternalSearch *search = [[ATInternalSearch alloc] initWithTracker:self.tracker];
    search.keyword = keyword;
    search.resultScreenNumber = resultScreenNumber;
    
    [self.tracker.businessObjects setObject:search forKey:search._id];
    
    return search;
}

- (ATInternalSearch *)addWithKeyword:(NSString *)keyword resultScreenNumber:(int)resultScreenNumber resultPosition:(int)resultPosition {
    ATInternalSearch *search = [self addWithKeyword:keyword resultScreenNumber:resultScreenNumber];
    search.resultPosition = resultPosition;
    
    return search;
}

@end