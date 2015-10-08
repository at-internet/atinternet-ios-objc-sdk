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
//  ATSelfPromotion.h
//  Tracker
//

#import <Foundation/Foundation.h>
#import "ATOnAppAd.h"

@class ATTracker;


@interface ATSelfPromotion : ATOnAppAd

/**
 Ad identifier
 */
@property (nonatomic) int adId;

/**
 Format
 */
@property (nonatomic, strong) NSString *format;

/**
 Product identifier
 */
@property (nonatomic, strong) NSString *productId;

/**
 Send self promotion touch hit
 */
- (void)sendTouch;

/**
 Send self promotion view hit
 */
- (void)sendImpression;

/**
 ATSelfPromotion initializer
 @param tracker the tracker instance
 @return ATSelfPromotion instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end

@interface ATSelfPromotions : NSObject

/**
 Tracker instance
 */
@property (nonatomic, strong) ATTracker *tracker;

/**
 Add tagging data for self promotion
 @param adId ad identifier
 @return the ATSelfPromotion instance
 */
- (ATSelfPromotion *)addWithId:(int)adId;

/**
 Send self promotion view hits
 */
- (void)sendImpressions;

/**
 ATSelfPromotions initializer
 @param tracker the tracker instance
 @return ATSelfPromotions instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end
