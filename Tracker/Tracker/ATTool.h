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
//  ATTool.h
//  Tracker

#import <Foundation/Foundation.h>

#import "ATTechnicalContext.h"
#import "ATHit.h"


@interface ATConvertedValue : NSObject

@property (nonatomic, strong) NSString *value;
@property (nonatomic) BOOL success;

- (instancetype)init;

@end


@interface ATTool : NSObject

+ (NSArray *)findParameterPosition:(NSString *)parameterKey array:(NSArray *)array;
+ (ATConvertedValue *)convertToString:(id)value separator:(NSString *)separator;
+ (NSString *)JSONStringify:(id)value prettyPrinted:(BOOL)prettyPrinted;
+ (NSString *)appendParameterValues:(NSString *)parameterKey volatileParameters:(NSArray *)volatileParameters peristentParameters:(NSArray *)persistentParameters;
+ (NSArray *)copyParamArray:(NSArray *)array;

/**
 Convert ConnectionType value to NSString
 
 @param connectionType value
 @return string convert value
 */
+ (NSString *)convertConnectionTypeToString:(ATConnectionType) connectionType;

/**
 Gets the number of days between two dates
 
 @param fromDate
 @param toDate
 @return the number of days between fromDate and toDate
 */
+ (NSInteger)daysBetweenDates:(NSDate *)fromDate toDate:(NSDate *)toDate;

/**
 Gets the number of minutes between two dates
 
 @param fromDate
 @param toDate
 @return the number of minutes between fromDate and toDate
 */
+ (NSInteger)minutesBetweenDates:(NSDate *)fromDate toDate:(NSDate *)toDate;

/**
 Gets the number of seconds between two dates
 
 @param fromDate
 @param toDate
 @return the number of seconds between fromDate and toDate
 */
+ (NSInteger)secondsBetweenDates:(NSDate *)fromDate toDate:(NSDate *)toDate;

/**
 Gets environment
 
 @return YES if testing, NO if not testing
 */
+ (BOOL)isTesting;

@end


@interface ATParamBufferPosition : NSObject

@property (nonatomic) int index;
@property (nonatomic) int arrayIndex;

- (instancetype)init;

@end



