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
//  ATInternalSearch.h
//  Tracker
//

#import "ATTracker.h"
#import "ATBusinessObject.h"

@class ATTracker;


@interface ATInternalSearch : ATBusinessObject

/**
 Keyword
 */
@property (nonatomic, strong) NSString *keyword;

/**
 Screen number
 */
@property (nonatomic) int resultScreenNumber;

/**
 Position
 */
@property (nonatomic) int resultPosition;

/**
 Prepare parameters for the hit query string
 */
- (void)setEvent;

/**
 ATInternalSearch initializer
 @param tracker the tracker instance
 @return ATInternalSearch instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end


@interface ATInternalSearches : NSObject

/**
 Tracker instance
 */
@property (nonatomic, strong) ATTracker *tracker;

/**
 Add tagging data for an internal search
 @param keyword keyword search
 @param resultScreenNumber screen number result
 @return the ATInternalSearch instance
 */
- (ATInternalSearch *)addWithKeyword:(NSString *)keyword resultScreenNumber:(int)resultScreenNumber;

/**
 Add tagging data for an internal search
 @param keyword keyword search
 @param resultScreenNumber result screen number
 @param resultPosition result position
 @return the ATInternalSearch instance
 */
- (ATInternalSearch *)addWithKeyword:(NSString *)keyword resultScreenNumber:(int)resultScreenNumber resultPosition:(int)resultPosition;

/**
 ATInternalSearches initializer
 @param tracker the tracker instance
 @return ATInternalSearches instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end
