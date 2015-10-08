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
//  ATAudio.h
//  Tracker
//

#import "ATRichMedia.h"


@interface ATAudio : ATRichMedia

/**
 Media duration
 */
@property (nonatomic) int duration;

/**
 Set parameters in buffer
 */
- (void)setEvent;

/**
 ATAudio initializer
 @param player the player instance
 @return ATAudio instance
 */
- (instancetype)initWithPlayer:(ATMediaPlayer *)player;

@end


@interface ATAudios : NSObject

/**
 List of audios
 */
@property (nonatomic, strong) NSMutableDictionary *list;

/**
 ATAudios initializer
 @param player the player instance
 @return ATAudios instance
 */
- (instancetype)initWithPlayer:(ATMediaPlayer *)player;

/**
 Create a new audio
 @param audio name
 @param audio duration in seconds
 @return ATAudio instance
 */
- (ATAudio *)addWithName:(NSString *)name duration:(int)duration;

/**
 Create a new audio
 @param audio name
 @param first chapter
 @param audio duration in seconds
 @return ATAudio instance
 */
- (ATAudio *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 duration:(int)duration;

/**
 Create a new audio
 @param audio name
 @param first chapter
 @param second chapter
 @param audio duration in seconds
 @return ATAudio instance
 */
- (ATAudio *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2 duration:(int)duration;

/**
 Create a new audio
 @param audio name
 @param first chapter
 @param second chapter
 @param third chapter
 @param audio duration in seconds
 @return ATAudio instance
 */
- (ATAudio *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2 chapter3:(NSString *)chapter3 duration:(int)duration;

/**
 Remove a audio
 @param audio name
 */
- (void)removeWithName:(NSString *)name;

/**
 Remove all audios
 */
- (void)removeAll;

@end
