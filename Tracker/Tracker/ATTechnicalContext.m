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
//  ATTechnicalContext.m
//  Tracker
//


#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <sys/utsname.h>

#import "ATTechnicalContext.h"
#import "ATReachability.h"
#import "ATTool.h"
#import "ATConfiguration.h"

#define AT_SDK_VERSION @"2.2.7"


@implementation ATTechnicalContext

static NSString* _screenName = @"";
static NSInteger _level2 = 0;

+ (NSString *)screenName {
    @synchronized(self) {
        return _screenName;
    }
}

+ (void)setScreenName:(NSString *)value {
    @synchronized(self) {
        _screenName = value;
    }
}

+ (NSInteger)level2 {
    @synchronized(self) {
        return _level2;
    }
}

+ (void)setLevel2:(NSInteger)value {
    @synchronized(self) {
        _level2 = value;
    }
}

+ (BOOL) doNotTrack {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    if(![userDefaults objectForKey:@"ATDoNotTrack"]) {
        return NO;
    } else {
        return [userDefaults boolForKey:@"ATDoNotTrack"];
    }
}

+ (void)setDoNotTrack:(BOOL)value {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setBool:value forKey:@"ATDoNotTrack"];
    [userDefaults synchronize];
}

+ (NSString *)userId:(NSString *)identifier {
    
    if([self doNotTrack] == NO) {
        
        if([identifier.lowercaseString isEqualToString:@"idfv"]){
            return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        }

        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ATIdclient"]) {
            return [[NSUserDefaults standardUserDefaults] objectForKey:@"ATIdclient"];
        } else if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ApplicationUniqueIdentifier"]){
            return [[NSUserDefaults standardUserDefaults] objectForKey:@"ApplicationUniqueIdentifier"];
        } else {
            NSString *uuid = [[NSUUID UUID] UUIDString];
            [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"ApplicationUniqueIdentifier"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return uuid;
        }
        
    } else {
        
        return @"opt-out";
        
    }
    
}

+ (NSString *)sdkVersion {
    return AT_SDK_VERSION;
}

+ (NSString *)language {
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

+ (NSString *)device {
    struct utsname systemInfo;
    uname(&systemInfo);
        
    return [NSString stringWithFormat:@"[apple]-[%@]", [NSString stringWithCString:systemInfo.machine
                                                                          encoding:NSUTF8StringEncoding]];
}

+ (NSString *)operatingSystem {
    NSString * systemName = [[[UIDevice currentDevice] systemName].lowercaseString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [NSString stringWithFormat:@"[%@]-[%@]", systemName, [[UIDevice currentDevice] systemVersion]];
}

+ (NSString *)applicationIdentifier {
    return [ATTool isTesting] ?
    [NSString stringWithFormat:@"%@", [NSBundle bundleForClass:[self class]].infoDictionary[@"CFBundleIdentifier"]] :
    [NSString stringWithFormat:@"%@", [NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"]];
}

+ (NSString *)applicationVersion {
    return [ATTool isTesting] ?
    [NSString stringWithFormat:@"[%@]", [NSBundle bundleForClass:[self class]].infoDictionary[@"CFBundleShortVersionString"]] :
    [NSString stringWithFormat:@"[%@]", [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]];
}

+ (NSString *)localHour {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH'x'mm'x'ss";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    return [formatter stringFromDate:[[NSDate alloc] init]];
}

+ (NSString *)screenResolution {
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGSize bounds = mainScreen.bounds.size;
    CGFloat scale = mainScreen.scale;
  
    return [NSString stringWithFormat:@"%ix%i", (int)(bounds.width * scale), (int)(bounds.height * scale)];
}

+ (NSString *)carrier {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *provider = networkInfo.subscriberCellularProvider;
    
    if(provider){
        NSString *carrier = provider.carrierName;
        return carrier ? carrier : @"";
    }
    
    return @"";
}

+ (NSString *)downloadSource:(ATTracker *)tracker {
    
    if([tracker.configuration.parameters objectForKey:@"downloadSource"]){
        return [tracker.configuration.parameters objectForKey:@"downloadSource"];
    } else {
        return @"ext";
    }
}

+ (ATConnectionType)connectionType {
    ATReachability *reachability = [ATReachability reachabilityForInternetConnection];
    
    if(reachability.currentReachabilityStatus == ReachableViaWiFi){
        return ATConnectionTypeWifi;
    } else if(reachability.currentReachabilityStatus == NotReachable) {
        return ATConnectionTypeOffline;
    } else {
        CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
        NSString *radioType = telephonyInfo.currentRadioAccessTechnology;
        
        if (radioType) {
            if([radioType isEqualToString:CTRadioAccessTechnologyGPRS]){
                return ATConnectionTypeGprs;
            } else if ([radioType isEqualToString:CTRadioAccessTechnologyEdge]){
                return ATConnectionTypeEdge;
            } else if ([radioType isEqualToString:CTRadioAccessTechnologyCDMA1x]){
                return ATConnectionTypeTwog;
            } else if ([radioType isEqualToString:CTRadioAccessTechnologyWCDMA]){
                return ATConnectionTypeThreeg;
            } else if ([radioType isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]){
                return ATConnectionTypeThreeg;
            } else if ([radioType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]){
                return ATConnectionTypeThreeg;
            } else if ([radioType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]){
                return ATConnectionTypeThreeg;
            } else if ([radioType isEqualToString:CTRadioAccessTechnologyeHRPD]){
                return ATConnectionTypeThreegplus;
            } else if ([radioType isEqualToString:CTRadioAccessTechnologyHSDPA]){
                return ATConnectionTypeThreegplus;
            } else if ([radioType isEqualToString:CTRadioAccessTechnologyHSUPA]){
                return ATConnectionTypeThreegplus;
            } else if ([radioType isEqualToString:CTRadioAccessTechnologyLTE]){
                return ATConnectionTypeFourg;
            } else {
                return ATConnectionTypeUnknown;
            }
        } else {
            return ATConnectionTypeUnknown;
        }
    }
}

@end
