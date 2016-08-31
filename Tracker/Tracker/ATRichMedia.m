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
//  ATRichMedia.m
//  Tracker
//

#import "ATRichMedia.h"
#import "ATTracker.h"
#import "ATMediaPlayer.h"
#import "ATTechnicalContext.h"
#import "ATDispatcher.h"
#import "ATParamOption.h"


@implementation ATRichMedia

- (instancetype)initWithPlayer:(ATMediaPlayer *)player {
    self = [super initWithTracker:player.tracker];
    
    if (self) {
        self.name = @"";
        self.action = ATRichMediaActionPlay;
        self.refreshDuration = 5;
        self.broadCastMode = ATRichMediaBroadcastModeClip;
    }
    
    return self;
}

- (void)setEvent {
    ATParamOption *encodeOption = [[ATParamOption alloc] init];
    encodeOption.encode = YES;
    
    [self.tracker setStringParam:@"p" value:[self buildMediaName] options:encodeOption];
    [self.tracker setIntParam:@"plyr" value:self.player.playerId];
    [self.tracker setStringParam:@"m6" value:[self getStringMode:self.broadCastMode]];
    [self.tracker setStringParam:@"a" value:[self getStringAction:self.action]];
    
    [self.tracker setStringParam:@"m5" value:self.isEmbedded ? @"ext" : @"int"];
    
    if (self.level2 > 0) {
        [self.tracker setIntParam:@"s2" value:self.level2];
    }
    
    if (self.action == ATRichMediaActionPlay) {
        
        [self.tracker setIntParam:@"buf" value:(self.isBuffering ? 1 : 0)];
        
        if (self.isEmbedded) {
            if (self.webdomain) {
                [self.tracker setStringParam:@"m9" value:self.webdomain];
            }
        } else {
            if ([ATTechnicalContext screenName]) {
                if (![[ATTechnicalContext screenName] isEqualToString:@""]) {
                    [self.tracker setStringParam:@"prich" value:[ATTechnicalContext screenName] options:encodeOption];
                }
            }
            
            if ([ATTechnicalContext level2] > 0) {
                [self.tracker setIntParam:@"s2rich" value:[ATTechnicalContext level2]];
            }
        }
    }
}

- (NSString *)getStringAction:(ATRichMediaAction)action {
    
    NSString *converted;
    
    switch (action) {
        case ATRichMediaActionPlay:
            converted = @"play";
            break;
        case ATRichMediaActionPause:
            converted = @"pause";
            break;
        case ATRichMediaActionStop:
            converted = @"stop";
            break;
        case ATRichMediaActionMove:
            converted = @"move";
            break;
        case ATRichMediaActionRefresh:
            converted = @"refresh";
            break;
        default:
            converted = @"play";
            break;
    }
    
    return converted;
    
}

- (NSString *)getStringMode:(ATRichMediaBroadcastMode)mode {
    NSString *converted;
    
    switch (mode) {
        case ATRichMediaBroadcastModeClip:
            converted = @"clip";
            break;
        case ATRichMediaBroadcastModeLive:
            converted = @"live";
            break;
        default:
            converted = @"clip";
            break;
    }
    
    return converted;
}

- (NSString *)buildMediaName {
    NSString *mediaName = !self.chapter1 ? @"" : [self.chapter1 stringByAppendingString:@"::"];
    mediaName = !self.chapter2 ? mediaName : [[mediaName stringByAppendingString:self.chapter2] stringByAppendingString:@"::"];
    mediaName = !self.chapter3 ? mediaName : [[mediaName stringByAppendingString:self.chapter3] stringByAppendingString:@"::"];
    mediaName = [mediaName stringByAppendingString:self.name];
    
    return mediaName;
}

- (void)sendPlay {
    self.action = ATRichMediaActionPlay;
    [self.tracker.dispatcher dispatch:@[self]];
    [self initRefresh];
}

- (void)sendPlayWithRefreshDuration:(int)refreshDuration {
    self.action = ATRichMediaActionPlay;
    [self.tracker.dispatcher dispatch:@[self]];
    
    if (refreshDuration != 0) {
        if (refreshDuration > 5) {
            self.refreshDuration = refreshDuration;
        }
        [self initRefresh];
    }
}

- (void)sendPause {
    if (self.timer) {
        if (self.timer.valid) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
    
    self.action = ATRichMediaActionPause;
    [self.tracker.dispatcher dispatch:@[self]];
}

- (void)sendStop {
    if (self.timer) {
        if (self.timer.valid) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
    
    self.action = ATRichMediaActionStop;
    [self.tracker.dispatcher dispatch:@[self]];
}

- (void)sendMove {
    self.action = ATRichMediaActionMove;
    [self.tracker.dispatcher dispatch:@[self]];
}

- (void)sendRefresh {
    self.action = ATRichMediaActionRefresh;
    [self.tracker.dispatcher dispatch:@[self]];
}

- (void)initRefresh {
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.refreshDuration
                                                      target:self
                                                    selector:@selector(sendRefresh)
                                                    userInfo:nil
                                                     repeats:YES];
        
    }
}

@end
