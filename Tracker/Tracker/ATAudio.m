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
//  ATAudio.m
//  Tracker
//

#import "ATAudio.h"
#import "ATTracker.h"
#import "ATParamOption.h"
#import "ATMediaPlayer.h"


@interface ATAudio()

/**
 Media type
 */
@property (nonatomic, strong) NSString *type;

@end


@implementation ATAudio

- (instancetype)initWithPlayer:(ATMediaPlayer *)player {
    self = [super initWithPlayer:player];
    
    if (self) {
        self.type = @"audio";
        self.player = player;
    }
    
    return self;
}

- (void)setEvent {
    [super setEvent];
    
    if (self.duration > 86400) {
        self.duration = 86400;
    }
    
    [self.tracker setIntParam:@"m1" value:self.duration];
    [self.tracker setStringParam:@"type" value:self.type];
}

@end


@interface ATAudios()

@property (nonatomic, strong) ATMediaPlayer *player;

@end

@implementation ATAudios

- (instancetype)initWithPlayer:(ATMediaPlayer *)player {
    self = [super init];
    
    if (self) {
        self.list = [[NSMutableDictionary alloc] init];
        self.player = player;
    }
    
    return self;
}

- (ATAudio *)addWithName:(NSString *)name duration:(int)duration {
    if ([self.list objectForKey:name]) {
        if (self.player.tracker.delegate) {
            if ([self.player.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.player.tracker.delegate warningDidOccur:@"An Audio with the same name already exists."];
            }
        }
        
        return [self.list objectForKey:name];
    } else {
        ATAudio *audio = [[ATAudio alloc] initWithPlayer:self.player];
        audio.name = name;
        audio.duration = duration;
        
        [self.list setObject:audio forKey:audio.name];
        
        return audio;
    }
}

- (ATAudio *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 duration:(int)duration {
    if ([self.list objectForKey:name]) {
        if (self.player.tracker.delegate) {
            if ([self.player.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.player.tracker.delegate warningDidOccur:@"An Audio with the same name already exists."];
            }
        }
        
        return [self.list objectForKey:name];
    } else {
        ATAudio *audio = [[ATAudio alloc] initWithPlayer:self.player];
        audio.name = name;
        audio.chapter1 = chapter1;
        audio.duration = duration;
        
        [self.list setObject:audio forKey:audio.name];
        
        return audio;
    }
}

- (ATAudio *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2 duration:(int)duration {
    if ([self.list objectForKey:name]) {
        if (self.player.tracker.delegate) {
            if ([self.player.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.player.tracker.delegate warningDidOccur:@"An Audio with the same name already exists."];
            }
        }
        
        return [self.list objectForKey:name];
    } else {
        ATAudio *audio = [[ATAudio alloc] initWithPlayer:self.player];
        audio.name = name;
        audio.chapter1 = chapter1;
        audio.chapter2 = chapter2;
        audio.duration = duration;
        
        [self.list setObject:audio forKey:audio.name];
        
        return audio;
    }
}

- (ATAudio *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2 chapter3:(NSString *)chapter3 duration:(int)duration {
    if ([self.list objectForKey:name]) {
        if (self.player.tracker.delegate) {
            if ([self.player.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.player.tracker.delegate warningDidOccur:@"An Audio with the same name already exists."];
            }
        }
        
        return [self.list objectForKey:name];
    } else {
        ATAudio *audio = [[ATAudio alloc] initWithPlayer:self.player];
        audio.name = name;
        audio.chapter1 = chapter1;
        audio.chapter2 = chapter2;
        audio.chapter3 = chapter3;
        audio.duration = duration;
        
        [self.list setObject:audio forKey:audio.name];
        
        return audio;
    }
}

- (void)removeWithName:(NSString *)name {
    NSTimer *timer = ((ATAudio *)[self.list objectForKey:name]).timer;
    if (timer) {
        if (timer.valid) {
            [((ATAudio *)[self.list objectForKey:name]) sendStop];
        }
    }
    [self.list removeObjectForKey:name];
}

- (void)removeAll {
    for (ATAudio *audio in self.list.allValues) {
        if (audio.timer) {
            if (audio.timer.valid) {
                [audio sendStop];
            }
        }
    }
    [self.list removeAllObjects];
}

@end
