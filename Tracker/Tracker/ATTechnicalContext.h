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
//  ATTechnicalContext.h
//  Tracker
//


#import <Foundation/Foundation.h>
#import "ATTracker.h"


@interface ATTechnicalContext : NSObject

/**
 Enum for different connection type
 */
typedef NS_ENUM(int, ATConnectionType) {
    ATConnectionTypeOffline,
    ATConnectionTypeGprs,
    ATConnectionTypeEdge,
    ATConnectionTypeTwog,
    ATConnectionTypeThreeg,
    ATConnectionTypeThreegplus,
    ATConnectionTypeFourg,
    ATConnectionTypeWifi,
    ATConnectionTypeUnknown
};

/**
 Name of the last tracked screen
 */
+ (NSString *)screenName;
+ (void)setScreenName:(NSString *)value;

/**
 ID of the last level2 set in parameters
 */
+ (NSInteger)level2;
+ (void)setLevel2:(NSInteger)value;

/**
 Enable or disable tracking
 */
+ (BOOL)doNotTrack;
+ (void)setDoNotTrack:(BOOL)value;

/**
 Unique user id
 @param identifier
 @return the unique user id
 */
+ (NSString *)userId:(NSString *)identifier;

/**
 Unique user id
 @param identifier
 @return the unique user id
 */
+ (NSString *)downloadSource:(ATTracker *)tracker;

/**
 SDK Version
 @return the sdk version
 */
+ (NSString *)sdkVersion;

/**
 Device Language
 @return the language
 */
+ (NSString *)language;

/**
 Device Type
 @return the device model
 */
+ (NSString *)device;

/**
 Device OS
 @return the device operating system
 */
+ (NSString *)operatingSystem;

/**
 Application Identifier
 @return the application identifier
 */
+ (NSString *)applicationIdentifier;

/**
 Application Version
 @return the application version
 */
+ (NSString *)applicationVersion;

/**
 Local Hour
 @return the device local hour
 */
+ (NSString *)localHour;

/**
 Screen Resolution
 @return the screen resolution
 */
+ (NSString *)screenResolution;

/**
 Carrier
 @return the device carrier
 */
+ (NSString *)carrier;

/**
 Connection Type
 @return the current connection type
 */
+ (ATConnectionType)connectionType;

@end
