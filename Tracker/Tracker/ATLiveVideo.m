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
//  ATLiveVideo.m
//  Tracker
//

#import "ATLiveVideo.h"
#import "ATTracker.h"
#import "ATParamOption.h"
#import "ATMediaPlayer.h"


@interface ATLiveVideo()

/**
 Media type
 */
@property (nonatomic, strong) NSString *type;

@end


@implementation ATLiveVideo

- (instancetype)initWithPlayer:(ATMediaPlayer *)player {
    self = [super initWithPlayer:player];
    
    if (self) {
        self.type = @"video";
        self.broadCastMode = ATRichMediaBroadcastModeLive;
        self.player = player;
    }
    
    return self;
}

- (void)setEvent {
    [super setEvent];
    
    [self.tracker setStringParam:@"type" value:self.type];
}

@end


@interface ATLiveVideos()

@property (nonatomic, strong) ATMediaPlayer *player;

@end

@implementation ATLiveVideos

- (instancetype)initWithPlayer:(ATMediaPlayer *)player {
    self = [super init];
    
    if (self) {
        self.list = [[NSMutableDictionary alloc] init];
        self.player = player;
    }
    
    return self;
}

- (ATLiveVideo *)addWithName:(NSString *)name {
    if ([self.list objectForKey:name]) {
        if (self.player.tracker.delegate) {
            if ([self.player.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.player.tracker.delegate warningDidOccur:@"A LiveVideo with the same name already exists."];
            }
        }
        
        return [self.list objectForKey:name];
    } else {
        ATLiveVideo *video = [[ATLiveVideo alloc] initWithPlayer:self.player];
        video.name = name;
        
        [self.list setObject:video forKey:video.name];
        
        return video;
    }
}

- (ATLiveVideo *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 {
    if ([self.list objectForKey:name]) {
        if (self.player.tracker.delegate) {
            if ([self.player.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.player.tracker.delegate warningDidOccur:@"A LiveVideo with the same name already exists."];
            }
        }
        
        return [self.list objectForKey:name];
    } else {
        ATLiveVideo *video = [[ATLiveVideo alloc] initWithPlayer:self.player];
        video.name = name;
        video.chapter1 = chapter1;
        
        [self.list setObject:video forKey:video.name];
        
        return video;
    }
}

- (ATLiveVideo *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2 {
    if ([self.list objectForKey:name]) {
        if (self.player.tracker.delegate) {
            if ([self.player.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.player.tracker.delegate warningDidOccur:@"A LiveVideo with the same name already exists."];
            }
        }
        
        return [self.list objectForKey:name];
    } else {
        ATLiveVideo *video = [[ATLiveVideo alloc] initWithPlayer:self.player];
        video.name = name;
        video.chapter1 = chapter1;
        video.chapter2 = chapter2;
        
        [self.list setObject:video forKey:video.name];
        
        return video;
    }
}

- (ATLiveVideo *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2 chapter3:(NSString *)chapter3 {
    if ([self.list objectForKey:name]) {
        if (self.player.tracker.delegate) {
            if ([self.player.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.player.tracker.delegate warningDidOccur:@"A LiveVideo with the same name already exists."];
            }
        }
        
        return [self.list objectForKey:name];
    } else {
        ATLiveVideo *video = [[ATLiveVideo alloc] initWithPlayer:self.player];
        video.name = name;
        video.chapter1 = chapter1;
        video.chapter2 = chapter2;
        video.chapter3 = chapter3;
        
        [self.list setObject:video forKey:video.name];
        
        return video;
    }
}

- (void)removeWithName:(NSString *)name {
    NSTimer *timer = ((ATLiveVideo *)[self.list objectForKey:name]).timer;
    if (timer) {
        if (timer.valid) {
            [((ATLiveVideo *)[self.list objectForKey:name]) sendStop];
        }
    }
    [self.list removeObjectForKey:name];
}

- (void)removeAll {
    for (ATLiveVideo *video in self.list.allValues) {
        if (video.timer) {
            if (video.timer.valid) {
                [video sendStop];
            }
        }
    }
    [self.list removeAllObjects];
}

@end
