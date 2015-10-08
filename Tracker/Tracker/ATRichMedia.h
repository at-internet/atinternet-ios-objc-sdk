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
//  ATRichMedia.h
//  Tracker
//

#import <Foundation/Foundation.h>
#import "ATBusinessObject.h"

@class ATTracker;
@class ATMediaPlayer;


@interface ATRichMedia : ATBusinessObject

/**
 Rich media broadcast type
 */
typedef NS_ENUM(int, ATRichMediaBroadcastMode) {
    ATRichMediaBroadcastModeClip,
    ATRichMediaBroadcastModeLive
};

/**
 Rich media hit status
 */
typedef NS_ENUM(int, ATRichMediaAction) {
    ATRichMediaActionPlay,
    ATRichMediaActionPause,
    ATRichMediaActionStop,
    ATRichMediaActionMove,
    ATRichMediaActionRefresh
};

/**
 Player instance
 */
@property (nonatomic, strong) ATMediaPlayer *player;

/**
 Player identifier
 */
@property (nonatomic) int playerId;

/**
 Refresh timer
 */
@property (nonatomic, strong) NSTimer *timer;

/**
 Refresh duration
 */
@property (nonatomic) int refreshDuration;

/**
 Media is buffering
 */
@property (nonatomic) BOOL isBuffering;

/**
 Media is embedded in app
 */
@property (nonatomic) BOOL isEmbedded;

/**
 Media is live or clip
 */
@property (nonatomic) ATRichMediaBroadcastMode broadCastMode;

/**
 Media name
 */
@property (nonatomic, strong) NSString *name;

/**
 First chapter
 */
@property (nonatomic, strong) NSString *chapter1;

/**
 Second chapter
 */
@property (nonatomic, strong) NSString *chapter2;

/**
 Third chapter
 */
@property (nonatomic, strong) NSString *chapter3;

/**
 Level 2
 */
@property (nonatomic) int level2;

/**
 Action
 */
@property (nonatomic) ATRichMediaAction action;

/**
 Web domain
 */
@property (nonatomic, strong) NSString *webdomain;

/**
 ATRichMedia initializer
 @param player the player instance
 @return ATRichMedia instance
 */
- (instancetype)initWithPlayer:(ATMediaPlayer *)player;

/**
 Send hit when media is played
 Refresh is enabled with default duration
 */
- (void)sendPlay;

/**
 Send hit when media is played
 Refresh is enabled if resfreshDuration is not equal to 0
 @param resfreshDuration duration between refresh hits
 */
- (void)sendPlayWithRefreshDuration:(int)refreshDuration;

/**
 Send hit when media is paused
 */
- (void)sendPause;

/**
 Send hit when media is stopped
 */
- (void)sendStop;

/**
 Send hit when media cursor position is moved
 */
- (void)sendMove;

@end
