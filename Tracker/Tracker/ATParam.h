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
//  ATParameter.h
//  Tracker
//


#import <Foundation/Foundation.h>

@class ATParamOption;


@class ATTracker;

@interface ATPluginParam : NSObject
+ (NSDictionary *) list:(ATTracker *)tracker;
@end

@interface ATReadOnlyParam : NSObject
+ (NSSet *) list;
@end

@interface ATSliceReadyParam : NSObject
+ (NSSet *) list;
@end


@interface ATParam : NSObject

/**
 Parameter types
 */
typedef NS_ENUM(int, ATParamType) {
    ATParamTypeUnknown = 0,
    ATParamTypeInteger = 1,
    ATParamTypeDouble = 2,
    ATParamTypeFloat = 3,
    ATParamTypeString = 4,
    ATParamTypeBool = 5,
    ATParamTypeArray = 6,
    ATParamTypeJSON = 7,
    ATParamTypeClosure = 8,
    ATParamTypeNumber = 9
};

/**
 Parameter key
 */
@property (nonatomic, strong) NSString *key;

/**
 Parameter value
 */
@property (nonatomic, copy) NSString * (^value)();
/**
 Parameter options
 */
@property (nonatomic, strong) ATParamOption *options;
/**
 Parameter type
 */
@property (nonatomic) ATParamType type;

/**
 Initialize a new ATParameter object with no key and no value
 @returns a newly initialized object
 */
- (instancetype)init;

/**
 Initialize a new ATParameter object with a key and a value
 @param key parameter key
 @param value parameter value
 @returns a newly initialized object
 */
- (instancetype)init:(NSString *)key value:(NSString * (^)())value type:(ATParamType)type;

/**
 Initialize a new ATParameter object with a key, a value and options
 @param key parameter key
 @param value parameter value
 @param options parameter options
 @returns a newly initialized object
 */
- (instancetype)init:(NSString *)key value:(NSString * (^)())value type:(ATParamType)type options:(ATParamOption *)options NS_DESIGNATED_INITIALIZER;
@end
