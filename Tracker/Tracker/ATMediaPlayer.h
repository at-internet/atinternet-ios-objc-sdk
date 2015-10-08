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
//  ATMediaPlayer.h
//  Tracker
//

#import <UIKit/UIKit.h>

@class ATTracker;
@class ATVideos;
@class ATAudios;
@class ATLiveVideos;
@class ATLiveAudios;


@interface ATMediaPlayer : NSObject

/**
 Player ID
 */
@property (nonatomic) int playerId;

/**
 List of videos attached to this player
 */
@property (nonatomic, strong) ATVideos *videos;

/**
 List of audios attached to this player
 */
@property (nonatomic, strong) ATAudios *audios;

/**
 List of live videos attached to this player
 */
@property (nonatomic, strong) ATLiveVideos *liveVideos;

/**
 List of live audios attached to this player
 */
@property (nonatomic, strong) ATLiveAudios *liveAudios;

/**
 Tracker instance
 */
@property (nonatomic, strong) ATTracker *tracker;

/**
 ATMediaPlayer initializer
 @param tracker the tracker instance
 @return ATMediaPlayer instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end


@interface ATMediaPlayers : NSObject

/**
 Player IDs
 */
@property (nonatomic, strong) NSMutableDictionary *playerIds;

/**
 ATMediaPlayers initializer
 @param tracker the tracker instance
 @return ATMediaPlayers instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

/**
 Add a new ATMediaPlayer
 @return ATMediaPlayer instance
 */
- (ATMediaPlayer *)add;

/**
 Add a new ATMediaPlayer
 @param playerId the player identifier
 @return ATMediaPlayer instance
 */
- (ATMediaPlayer *)addWithId:(int)playerId;

/**
 Remove an ATMediaPlayer
 @param playerId the player identifier
 */
- (void)removeWithId:(int)playerId;

/**
 Remove all ATMediaPlayer
 */
- (void)removeAll;

@end
