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
//  ATCustomObject.h
//  Tracker
//

#import <Foundation/Foundation.h>
#import "ATBusinessObject.h"

@class ATTracker;


@interface ATCustomObject : ATBusinessObject

/**
 Serialized JSON object
 */
@property (nonatomic, strong) NSString *json;

/**
 Prepare parameters for the hit query string
 */
- (void)setEvent;

/**
 ATCustomObject initializer
 @param tracker the tracker instance
 @return ATCustomObject instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end


@interface ATCustomObjects : NSObject

/**
 Tracker instance
 */
@property (nonatomic, strong) ATTracker *tracker;

/**
 Add tagging data for custom object
 @param customObject serialized custom object
 @return the ATCustomObject instance
 */
- (ATCustomObject *)addWithString:(NSString *)customObject;

/**
 Add tagging data for custom object
 @param customObject not serialized custom object
 @return the ATCustomObject instance
 */
- (ATCustomObject *)addWithDictionary:(NSDictionary *)customObject;

/**
 ATCustomObjects initializer
 @param tracker the tracker instance
 @return ATCustomObjects instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end
