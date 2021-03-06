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
//  ATLocation.m
//  Tracker
//

#import "ATLocation.h"
#import "ATTracker.h"


@implementation ATLocation

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super initWithTracker:tracker];
    
    if (self) {
        self.latitude = 0.0;
        self.longitude = 0.0;
    }
    
    return self;
}

- (void)setEvent {
    [self.tracker setStringParam:@"gy" value:[NSString stringWithFormat:@"%.2f", self.latitude]];
    [self.tracker setStringParam:@"gx" value:[NSString stringWithFormat:@"%.2f", self.longitude]];
}

@end


@implementation ATLocations

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
    }
    
    return self;
}

- (ATLocation *)addWithLatitude:(double)latitude longitude:(double)longitude {
    ATLocation *location = [[ATLocation alloc] initWithTracker:self.tracker];
    location.latitude = latitude;
    location.longitude = longitude;
    
    [self.tracker.businessObjects setObject:location forKey:location._id];
    
    return location;
}

@end
