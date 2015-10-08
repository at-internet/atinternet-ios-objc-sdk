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
//  ATAisle.h
//  Tracker
//

#import <Foundation/Foundation.h>
#import "ATScreen.h"

@class ATTracker;


@interface ATAisle : ATScreenInfo

/**
 Aisle level1 label
 */
@property (nonatomic, strong) NSString *level1;

/**
 Aisle level2 label
 */
@property (nonatomic, strong) NSString *level2;

/**
 Aisle level3 label
 */
@property (nonatomic, strong) NSString *level3;

/**
 Aisle level4 label
 */
@property (nonatomic, strong) NSString *level4;

/**
 Aisle level5 label
 */
@property (nonatomic, strong) NSString *level5;

/**
 Aisle level6 label
 */
@property (nonatomic, strong) NSString *level6;

/**
 Prepare parameters for the hit query string
 */
- (void)setEvent;

/**
 ATAisle initializer
 @param tracker the tracker instance
 @return ATAisle instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end


@interface ATAisles : NSObject

/**
 Tracker instance
 */
@property (nonatomic, strong) ATTracker *tracker;

/**
 Add tagging data for an aisle
 @param level1 level1 label
 @return the ATAisle instance
 */
- (ATAisle *)addWithLevel1:(NSString *)level1;

/**
 Add tagging data for an aisle
 @param level1 level1 label
 @param level2 level2 label
 @return the ATAisle instance
 */
- (ATAisle *)addWithLevel1:(NSString *)level1 level2:(NSString *)level2;

/**
 Add tagging data for an aisle
 @param level1 level1 label
 @param level2 level2 label
 @param level3 level3 label
 @return the ATAisle instance
 */
- (ATAisle *)addWithLevel1:(NSString *)level1 level2:(NSString *)level2 level3:(NSString *)level3;

/**
 Add tagging data for an aisle
 @param level1 level1 label
 @param level2 level2 label
 @param level3 level3 label
 @param level4 level4 label
 @return the ATAisle instance
 */
- (ATAisle *)addWithLevel1:(NSString *)level1 level2:(NSString *)level2 level3:(NSString *)level3 level4:(NSString *)level4;

/**
 Add tagging data for an aisle
 @param level1 level1 label
 @param level2 level2 label
 @param level3 level3 label
 @param level4 level4 label
 @param level5 level5 label
 @return the ATAisle instance
 */
- (ATAisle *)addWithLevel1:(NSString *)level1 level2:(NSString *)level2 level3:(NSString *)level3 level4:(NSString *)level4 level5:(NSString *)level5;

/**
 Add tagging data for an aisle
 @param level1 level1 label
 @param level2 level2 label
 @param level3 level3 label
 @param level4 level4 label
 @param level5 level5 label
 @param level6 level6 label
 @return the ATAisle instance
 */
- (ATAisle *)addWithLevel1:(NSString *)level1 level2:(NSString *)level2 level3:(NSString *)level3 level4:(NSString *)level4 level5:(NSString *)level5  level6:(NSString *)level6;

/**
 ATAisles initializer
 @param tracker the tracker instance
 @return ATAisles instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end
