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
//  ATLiveAudio.h
//  Tracker
//

#import "ATRichMedia.h"


@interface ATLiveAudio : ATRichMedia

/**
 Set parameters in buffer
 */
- (void)setEvent;

/**
 ATLiveAudio initializer
 @param player the player instance
 @return ATLiveAudio instance
 */
- (instancetype)initWithPlayer:(ATMediaPlayer *)player;

@end


@interface ATLiveAudios : NSObject

/**
 List of live audios
 */
@property (nonatomic, strong) NSMutableDictionary *list;

/**
 ATLiveAudios initializer
 @param player the player instance
 @return ATLiveAudios instance
 */
- (instancetype)initWithPlayer:(ATMediaPlayer *)player;

/**
 Create a new live audio
 @param audio name
 @param audio duration in seconds
 @return ATLiveAudio instance
 */
- (ATLiveAudio *)addWithName:(NSString *)name;

/**
 Create a new live audio
 @param audio name
 @param first chapter
 @param audio duration in seconds
 @return ATLiveAudio instance
 */
- (ATLiveAudio *)addWithName:(NSString *)name chapter1:(NSString *)chapter1;

/**
 Create a new live audio
 @param audio name
 @param first chapter
 @param second chapter
 @param audio duration in seconds
 @return ATLiveAudio instance
 */
- (ATLiveAudio *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2;

/**
 Create a new live audio
 @param audio name
 @param first chapter
 @param second chapter
 @param third chapter
 @param audio duration in seconds
 @return ATLiveAudio instance
 */
- (ATLiveAudio *)addWithName:(NSString *)name chapter1:(NSString *)chapter1 chapter2:(NSString *)chapter2 chapter3:(NSString *)chapter3;

/**
 Remove a audio
 @param audio name
 */
- (void)removeWithName:(NSString *)name;

/**
 Remove all live audios
 */
- (void)removeAll;

@end
