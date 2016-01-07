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
//  ATTool.m
//  Tracker

#import "ATTool.h"
#import "ATParam.h"
#import "ATParamOption.h"

@implementation ATParamBufferPosition

- (instancetype)init {
    if (self = [super init]) {

    }
    return self;
}

@end

@implementation ATConvertedValue

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

@end

@implementation ATTool

+ (NSString *)convertConnectionTypeToString:(ATConnectionType)connectionType {
    switch (connectionType) {
        case ATConnectionTypeEdge:
            return @"edge";
        case ATConnectionTypeGprs:
            return @"gprs";
        case ATConnectionTypeTwog:
            return @"2g";
        case ATConnectionTypeThreeg:
            return @"3g";
        case ATConnectionTypeThreegplus:
            return @"3g+";
        case ATConnectionTypeFourg:
            return @"4g";
        case ATConnectionTypeWifi:
            return @"wifi";
        case ATConnectionTypeOffline:
            return @"offline";
        default:
            return @"unknown";
    }
}

+ (NSArray *)findParameterPosition:(NSString *)parameterKey array:(NSArray *)array {
    NSMutableArray* indexes = [[NSMutableArray alloc] init];
    
    for(int arrayIndex = 0; arrayIndex < [array count]; arrayIndex++) {
        for (int parameterIndex = 0; parameterIndex < [array[arrayIndex] count]; parameterIndex++) {
            if([array[arrayIndex][parameterIndex] isKindOfClass:[ATParam class]]) {
                ATParam* parameter = (ATParam *)array[arrayIndex][parameterIndex];
                
                if([parameter.key isEqualToString:parameterKey]) {
                    ATParamBufferPosition *position = [[ATParamBufferPosition alloc] init];
                    position.index = parameterIndex;
                    position.arrayIndex = arrayIndex;
                    
                    [indexes addObject:position];
                }
            }
        }
    }
    return indexes;
}

+ (NSString *)JSONStringify:(id)value prettyPrinted:(BOOL)prettyPrinted {
    if([NSJSONSerialization isValidJSONObject:value]) {
        NSData* data = [NSJSONSerialization dataWithJSONObject:value options:(prettyPrinted ? NSJSONWritingPrettyPrinted : kNilOptions) error:nil];

        if(data) {
            NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            return (string) ? string : @"";
        }
    }
    
    return @"";
}

+ (ATConvertedValue *)convertToString:(id)value separator:(NSString *)separator {
    ATConvertedValue* convertedValue = [[ATConvertedValue alloc] init];
    
    if(separator == nil) {
        separator = @",";
    }
    
    if([value isKindOfClass:[NSArray class]]) {
        NSString* stringFromArray = @"";
        BOOL convertSuccess = YES;
        NSArray* array = (NSArray *)value;
        
        for(int i = 0; i < [array count]; i++) {
            id val = array[i];
            
            if(i > 0) {
                stringFromArray = [stringFromArray stringByAppendingString:separator];
            }
            
            ATConvertedValue* stringValue = [self convertToString:val separator:separator];
            stringFromArray = [stringFromArray stringByAppendingString:stringValue.value];
            
            if(stringValue.success == NO) {
                convertSuccess = stringValue.success;
            }
        }
        convertedValue.value = stringFromArray;
        convertedValue.success = convertSuccess;
        return convertedValue;
    } else if([value isKindOfClass:[NSDictionary class]]) {
        NSString* JSON = [self JSONStringify:value prettyPrinted:NO];
        
        if([JSON isEqualToString:@""]) {
            convertedValue.value = @"";
            convertedValue.success = NO;
        } else {
            convertedValue.value = JSON;
            convertedValue.success = YES;
        }
        
        return convertedValue;
    } else if([value isKindOfClass:[NSString class]]) {
        convertedValue.value = (NSString *)value;
        convertedValue.success = YES;
        return convertedValue;
    } else if([value isKindOfClass:[NSNumber class]]) {
        Class boolClass = [[NSNumber numberWithBool:YES] class];
        
        if([value isKindOfClass:boolClass]) {
            
            BOOL isTrue;
            if ([[value stringValue] isEqualToString:@"0"]) {
                isTrue = NO;
            } else {
                isTrue = YES;
            }
            
            if(isTrue) {
                convertedValue.value = @"true";
                convertedValue.success = YES;
            } else {
                convertedValue.value = @"false";
                convertedValue.success = YES;
            }
            
        } else {
            convertedValue.value = [value stringValue];
            convertedValue.success = YES;
        }
        
        return convertedValue;
    } else {
        convertedValue.value = @"";
        convertedValue.success = NO;
        
        return convertedValue;
    }
}

+ (NSInteger)daysBetweenDates:(NSDate *)fromDate toDate:(NSDate *)toDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    int unitFlags = NSCalendarUnitDay;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:fromDate toDate:toDate options:0];
    
    if(dateComponents){
        return dateComponents.day;
    }
    return 0;
}

+ (NSInteger)minutesBetweenDates:(NSDate *)fromDate toDate:(NSDate *)toDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    int unitFlags = NSCalendarUnitMinute;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:fromDate toDate:toDate options:0];
    
    if(dateComponents){
        return dateComponents.minute;
    }
    return 0;
}

+ (NSInteger)secondsBetweenDates:(NSDate *)fromDate toDate:(NSDate *)toDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    int unitFlags = NSCalendarUnitSecond;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:fromDate toDate:toDate options:0];
    
    if(dateComponents){
        return dateComponents.second;
    }
    return 0;
}

+ (BOOL)isTesting {
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    return [environment objectForKey:@"TEST"] != nil;
}

+ (NSString *)appendParameterValues:(NSString *)parameterKey volatileParameters:(NSArray *)volatileParameters peristentParameters:(NSArray *)persistentParameters {
    NSArray *bufferCollections = [[NSArray alloc] initWithObjects:volatileParameters, persistentParameters, nil];
    
    NSArray* paramPositions = [self findParameterPosition:parameterKey array:bufferCollections];
    
    NSString* value = @"";
    
    if([paramPositions count] > 0) {
        int i = 0;
        for(ATParamBufferPosition* position in paramPositions) {
            ATParam* param = (position.arrayIndex == 0) ? volatileParameters[position.index] : persistentParameters[position.index];
        
            if(i > 0) {
                if(param.options) {
                    value = [value stringByAppendingString:param.options.separator];
                } else {
                    value = [value stringByAppendingString:@","];
                }
            }
            
            value = [value stringByAppendingString:param.value()];
        
            i++;
        }
    }
    
    return value;
}

+ (NSArray *)copyParamArray:(NSArray *)array {
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    
    for (ATParam *param in array) {
        ATParam *copyParam = [[ATParam alloc] init:param.key value:param.value type:param.type options:param.options];
        [newArray addObject:copyParam];
    }
    
    return (NSArray *)newArray;
}

@end
