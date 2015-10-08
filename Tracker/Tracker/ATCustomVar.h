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
//  ATCustomVar.h
//  Tracker
//

#import <Foundation/Foundation.h>
#import "ATScreen.h"

@class ATTracker;


@interface ATCustomVar : ATScreenInfo

/**
 Custom var types
 */
typedef NS_ENUM(int, ATCustomVarType) {
    ATCustomVarTypeApp,
    ATCustomVarTypeScreen
};

/**
 ATCustomVar initializer
 @param tracker the tracker instance
 @return ATCustomVar instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

/**
 Prepare parameters for the hit query string
 */
- (void)setEvent;

@end


@interface ATCustomVars : NSObject

/**
 Tracker instance
 */
@property (nonatomic, strong) ATTracker *tracker;

/**
 Add tagging data for a custom variable
 @param varId custom variable identifier
 @param value custom variable value
 @param type custom variable type
 @return the ATCustomVar instance
 */
- (ATCustomVar *)addWithId:(int)varId value:(NSString *)value type:(ATCustomVarType)type;

/**
 ATCustomVars initializer
 @param tracker the tracker instance
 @return ATCustomVars instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end
