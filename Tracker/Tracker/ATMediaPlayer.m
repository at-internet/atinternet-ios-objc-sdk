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
//  ATMediaPlayer.m
//  Tracker
//

#import "ATMediaPlayer.h"
#import "ATTracker.h"
#import "ATVideo.h"
#import "ATAudio.h"
#import "ATLiveVideo.h"
#import "ATLiveAudio.h"


@implementation ATMediaPlayer

- (instancetype)initWithTracker:(ATTracker *)tracker {
    if (self = [super init]) {
        self.tracker = tracker;
        self.videos = [[ATVideos alloc] initWithPlayer:self];
        self.audios = [[ATAudios alloc] initWithPlayer:self];
        self.liveVideos = [[ATLiveVideos alloc] initWithPlayer:self];
        self.liveAudios = [[ATLiveAudios alloc] initWithPlayer:self];
    }
    
    return self;
}

@end


@interface ATMediaPlayers()

@property (nonatomic, strong) ATTracker *tracker;

@end

@implementation ATMediaPlayers

- (instancetype)initWithTracker:(ATTracker *)tracker {
    if (self = [super init]) {
        self.tracker = tracker;
        self.playerIds = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (ATMediaPlayer *)add {
    ATMediaPlayer *player = [[ATMediaPlayer alloc] initWithTracker:self.tracker];
    
    if ([self.playerIds count] > 0) {
        player.playerId = [[self.playerIds.allKeys valueForKeyPath:@"@max.intValue"] intValue] + 1;
    } else {
        player.playerId = 1;
    }
    
    [self.playerIds setObject:player forKey:[NSNumber numberWithInt:player.playerId]];
    
    return player;
}

- (ATMediaPlayer *)addWithId:(int)playerId {
    if ([self.playerIds objectForKey:[NSNumber numberWithInt:playerId]] != nil) {
        if (self.tracker.delegate) {
            if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.tracker.delegate warningDidOccur:@"A player with the same id already exists."];
            }
        }
        return [self.playerIds objectForKey:[NSNumber numberWithInt:playerId]];
    } else {
        ATMediaPlayer *player = [[ATMediaPlayer alloc] initWithTracker:self.tracker];
        player.playerId = playerId;
        [self.playerIds setObject:player forKey:[NSNumber numberWithInt:playerId]];
        return player;
    }
}

- (void)removeWithId:(int)playerId {
    ATMediaPlayer *player = [self.playerIds objectForKey:[NSNumber numberWithInt:playerId]];
    if (player) {
        [self sendStopsForPlayer:player];
    }
    
    [self.playerIds removeObjectForKey:[NSNumber numberWithInt:playerId]];
}

- (void)removeAll {
    for (ATMediaPlayer *player in self.playerIds.allValues) {
        [self sendStopsForPlayer:player];
    }
    
    [self.playerIds removeAllObjects];
}

- (void)sendStopsForPlayer:(ATMediaPlayer *)player {
    
    for (ATVideo *video in player.videos.list.allValues) {
        if (video.timer) {
            if (video.timer.valid) {
                [video sendStop];
            }
        }
    }
    
    for (ATAudio *audio in player.audios.list.allValues) {
        if (audio.timer) {
            if (audio.timer.valid) {
                [audio sendStop];
            }
        }
    }
    
    for (ATLiveVideo *video in player.liveVideos.list.allValues) {
        if (video.timer) {
            if (video.timer.valid) {
                [video sendStop];
            }
        }
    }
    
    for (ATLiveAudio *audio in player.liveAudios.list.allValues) {
        if (audio.timer) {
            if (audio.timer.valid) {
                [audio sendStop];
            }
        }
    }
    
}

@end
