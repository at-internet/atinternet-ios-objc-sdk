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
//  ATParameterOption.h
//  Tracker
//


#import <Foundation/Foundation.h>


@interface ATParamOption : NSObject

/**
 Relative position enumeration
 */
typedef NS_ENUM(int, ATRelativePosition) {
    ATRelativePositionNone,
    ATRelativePositionFirst,
    ATRelativePositionLast,
    ATRelativePositionBefore,
    ATRelativePositionAfter
};

/**
 Parameter relative position inside the hit
 */
@property (nonatomic) ATRelativePosition relativePosition;

/**
 Relative parameter reference
 */
@property (nonatomic, strong) NSString *relativeParameterKey;

/**
 Separator to use when the value of the parameter is an NSArray
 */
@property (nonatomic, strong) NSString *separator;

/**
 Parameter value percent encoding
 */
@property (nonatomic, getter = isEncoded) BOOL encode;

/**
 Parameter persistence
 */
@property (nonatomic, getter = isPersistent) BOOL persistent;

/**
 Indicates if value must be appended to the old value of parameter
 */
@property (nonatomic) BOOL append;

/**
 Initialize a new ATParameterOption object
 @returns a newly initialized object
 */
- (id)init;

@end
