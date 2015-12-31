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
//  ATLifeCycle.m
//  Tracker
//


#import <UIKit/UIKit.h>

#import "ATLifeCycle.h"
#import "ATTechnicalContext.h"
#import "ATTool.h"


static BOOL _initialized = NO;
static BOOL _firstLaunch = YES;
static BOOL _appVersionChanged = NO;
static NSString* _sessionId = nil;
static NSDate* _timeInBackground = nil;


@interface ATLifeCycle()

// List of lifecycle metrics
@property (nonatomic, strong) NSMutableDictionary *parameters;
// Number of days since last app use
@property (nonatomic) NSInteger daysSinceLastUse;
// Calendar type
@property (nonatomic, strong) NSCalendar *calendar;

@end

@implementation ATLifeCycle

+ (BOOL)isInitialized {
    return _initialized;
}

+ (BOOL)isFirstLaunch {
    return _firstLaunch;
}

+ (void)setInitialized:(BOOL)initialized {
    _initialized = initialized;
}

+ (void)applicationDidBecomeActive:(NSDictionary*)parameters {
    int sessionConfig = [[parameters objectForKey:@"sessionBackgroundDuration"] intValue];
    
    if(sessionConfig > 0){
        if(![self assignNewSession]){
            if(_timeInBackground){
                if([ATTool secondsBetweenDates:_timeInBackground toDate:[[NSDate alloc] init]] > sessionConfig){
                    _sessionId = [[NSUUID UUID] UUIDString];
                }
                _timeInBackground = nil;
            }
        }
    }
    
}

+ (void)applicationDidEnterBackground {
    _timeInBackground = [[NSDate alloc] init];
    [self updateFirstLaunch];
}

+ (void)updateFirstLaunch {
    _firstLaunch = NO;
    _appVersionChanged = NO;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:0 forKey:FIRST_LAUNCH];
    [userDefaults synchronize];
}

+ (BOOL)assignNewSession {
    if(_sessionId){
        return false;
    } else {
        _sessionId = [[NSUUID UUID] UUIDString];
        return true;
    }
}

- (instancetype)init {
    if (self = [super init]) {
        self.parameters = [[NSMutableDictionary alloc] init];
        self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        if (!_initialized) {
            [self initMetrics];
        }
    }
    
    return self;
}

- (void)initMetrics {
    NSUserDefaults *userDefaults = [[NSUserDefaults standardUserDefaults] init];
    [userDefaults synchronize];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = self.calendar;
    dateFormatter.dateFormat = @"yyyyMMdd";
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    monthFormatter.calendar = self.calendar;
    monthFormatter.dateFormat = @"yyyyMM";
    NSDateFormatter *weekFormatter = [[NSDateFormatter alloc] init];
    weekFormatter.calendar = self.calendar;
    weekFormatter.dateFormat = @"yyyyww";
    
    NSDate *now = [[NSDate alloc] init];
    
    // Not first launch
    NSObject *firstLaunch = [userDefaults objectForKey:FIRST_LAUNCH];
    if(firstLaunch){
        _firstLaunch = NO;
        
        // Last use
        NSDate *lastUse = (NSDate *)[userDefaults objectForKey:LAST_USE];
        if(lastUse){
            self.daysSinceLastUse = [ATTool daysBetweenDates:lastUse toDate:now];
        }
        
        //Launch count
        NSNumber *launchCount = [userDefaults objectForKey:LAUNCH_COUNT];
        if(launchCount != nil){
            [userDefaults setInteger:[launchCount integerValue]+1 forKey:LAUNCH_COUNT];
        }
        
        //NSNumber of day
        NSNumber *launchDayCount = [userDefaults objectForKey:LAUNCH_DAY_COUNT];
        if(launchDayCount != nil){
            if([[dateFormatter stringFromDate:lastUse] isEqualToString: [dateFormatter stringFromDate:now]]){
                [userDefaults setInteger:[launchDayCount integerValue] + 1 forKey:LAUNCH_DAY_COUNT];
            }else{
                [userDefaults setInteger:1 forKey:LAUNCH_DAY_COUNT];
            }
        }
        
        //Launch of week
        NSNumber *launchWeekCount = [userDefaults objectForKey:LAUNCH_WEEK_COUNT];
        if(launchWeekCount != nil){
            if([[weekFormatter stringFromDate:lastUse] isEqualToString:[weekFormatter stringFromDate:now]]){
                [userDefaults setInteger:[launchWeekCount integerValue] + 1 forKey:LAUNCH_WEEK_COUNT];
            }else{
                [userDefaults setInteger:1 forKey:LAUNCH_WEEK_COUNT];
            }
        }
        
        //Launch of month
        NSNumber *launchMonthCount = [userDefaults objectForKey:LAUNCH_MONTH_COUNT];
        if(launchMonthCount != nil){
            if([[monthFormatter stringFromDate:lastUse] isEqualToString:[monthFormatter stringFromDate:now]]){
                [userDefaults setInteger:[launchMonthCount integerValue]+1 forKey:LAUNCH_MONTH_COUNT];
            }else{
                [userDefaults setInteger:1 forKey:LAUNCH_MONTH_COUNT];
            }
        }
        
        //Application version changed
        NSString *appVersion = [userDefaults objectForKey:LAST_APPLICATION_VERSION];
        if(appVersion && ![appVersion isEqualToString:[ATTechnicalContext applicationVersion]]){
            _appVersionChanged = YES;
            [userDefaults setObject:now forKey:APPLICATION_UPDATE];
            [userDefaults setInteger:1 forKey:LAUNCH_COUNT_SINCE_UPDATE];
            [userDefaults setObject:[ATTechnicalContext applicationVersion] forKey:LAST_APPLICATION_VERSION];
        }else{
            NSInteger launchCountSinceUpdate = [userDefaults integerForKey:LAUNCH_COUNT_SINCE_UPDATE];
            if(launchCountSinceUpdate){
                [userDefaults setInteger:launchCountSinceUpdate + 1 forKey:LAUNCH_COUNT_SINCE_UPDATE];
            }
        }
        
        //Save user defaults
        [userDefaults setObject:now forKey:LAST_USE];
        [userDefaults synchronize];
        
    } else {
        [self firstLaunchInit];
    }
    
    _initialized = YES;
}

- (void)firstLaunchInit {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *now = [[NSDate alloc] init];
    
    // Update Lifecycle from SDK V1
    if([userDefaults objectForKey:@"firstLaunchDate"]){
        _firstLaunch = NO;
        [userDefaults setInteger:0 forKey:FIRST_LAUNCH];
        
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        dateformatter.calendar = self.calendar;
        dateformatter.dateFormat = @"YYYYMMdd";
        
        NSString *fld = [userDefaults objectForKey:@"firstLaunchDate"];
        [userDefaults setObject:[dateformatter dateFromString:fld]forKey:FIRST_LAUNCH_DATE];
        [userDefaults setObject:nil forKey:@"firstLaunchDate"];
        
        [userDefaults setInteger:[userDefaults integerForKey:@"ATLaunchCount"] + 1 forKey:LAUNCH_COUNT];
        
        NSDate *lastUse = (NSDate *)[userDefaults objectForKey:@"lastUseDate"];
        if (lastUse) {
            self.daysSinceLastUse = [ATTool daysBetweenDates:lastUse toDate:now];
        }
        
    } else {
        _firstLaunch = YES;
        [userDefaults setInteger:1 forKey:FIRST_LAUNCH];
        [userDefaults setInteger:1 forKey:LAUNCH_COUNT];
        [userDefaults setObject:now forKey:FIRST_LAUNCH_DATE];
    }
    
    [userDefaults setObject:now forKey:LAST_USE];
    
    // Launch of day
    [userDefaults setInteger:1 forKey:LAUNCH_DAY_COUNT];
    
    // Launch of week
    [userDefaults setInteger:1 forKey:LAUNCH_WEEK_COUNT];
    
    // Launch of month
    [userDefaults setInteger:1 forKey:LAUNCH_MONTH_COUNT];
    
    // Application version changed
    [userDefaults setObject:[ATTechnicalContext applicationVersion] forKey:LAST_APPLICATION_VERSION];
    
    [userDefaults synchronize];
}

- (NSString *(^)()) getMetrics {
    return ^NSString *() {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        if (![userDefaults objectForKey:FIRST_LAUNCH]) {
            [self firstLaunchInit];
        }
        
        NSDate *firstLaunchDate = [userDefaults objectForKey:FIRST_LAUNCH_DATE];
        NSDate *now = [[NSDate alloc] init];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.calendar = self.calendar;
        dateFormatter.dateFormat = @"yyyyMMdd";
        
        // First Launch
        [self.parameters setObject:[NSNumber numberWithInteger:_firstLaunch ? 1 : 0] forKey:@"fl"];
        
        // First Launch after update
        [self.parameters setObject:[NSNumber numberWithInteger:_appVersionChanged ? 1 : 0] forKey:@"flau"];
        
        // Launch count of day
        [self.parameters setObject:[NSNumber numberWithInteger:[userDefaults integerForKey:LAUNCH_DAY_COUNT]] forKey:@"ldc"];
        
        // Launch count of week
        [self.parameters setObject:[NSNumber numberWithInteger:[userDefaults integerForKey:LAUNCH_WEEK_COUNT]] forKey:@"lwc"];
        
        // Launch count of month
        [self.parameters setObject:[NSNumber numberWithInteger:[userDefaults integerForKey:LAUNCH_MONTH_COUNT]] forKey:@"lmc"];
        
        // Launch count since update
        if([userDefaults integerForKey:LAUNCH_COUNT_SINCE_UPDATE]){
            [self.parameters setObject:[NSNumber numberWithInteger:[userDefaults integerForKey:LAUNCH_COUNT_SINCE_UPDATE]] forKey:@"lcsu"];
        }
        
        // Launch count
        [self.parameters setObject:[NSNumber numberWithInteger:[userDefaults integerForKey:LAUNCH_COUNT]] forKey:@"lc"];
        
        // First launch date
        [self.parameters setObject:[NSNumber numberWithInteger:[[dateFormatter stringFromDate:firstLaunchDate] intValue]] forKey:@"fld"];
        
        // Days since first launch
        [self.parameters setObject:[NSNumber numberWithInteger:[ATTool daysBetweenDates:firstLaunchDate toDate:now]] forKey:@"dsfl"];
        
        // Update launch date & days since update
        NSDate *applicationUpdate = [userDefaults objectForKey:APPLICATION_UPDATE];
        if(applicationUpdate){
            [self.parameters setObject:[NSNumber numberWithInteger:[[dateFormatter stringFromDate:applicationUpdate] intValue]] forKey:@"uld"];
            [self.parameters setObject:[NSNumber numberWithInteger:[ATTool daysBetweenDates:applicationUpdate toDate:now]] forKey:@"dsu"];
        }
        
        // Days since last use
        [self.parameters setObject:[NSNumber numberWithInteger:self.daysSinceLastUse] forKey:@"dslu"];
        
        // SessionId
        [self.parameters setObject:_sessionId forKey:@"sessionId"];
        
        NSString *json = [ATTool JSONStringify:
                          [[NSDictionary alloc] initWithObjectsAndKeys:self.parameters, @"lifecycle", nil]
                                 prettyPrinted:NO];
        
        [self.parameters removeAllObjects];
        
        return json;
    };
}

@end
