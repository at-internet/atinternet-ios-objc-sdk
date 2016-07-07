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
static BOOL _firstSession = YES;
static BOOL _appVersionChanged = NO;
static NSString* _sessionId = nil;
static NSDate* _timeInBackground = nil;


@interface ATLifeCycle()

// List of lifecycle metrics
@property (nonatomic, strong) NSMutableDictionary *parameters;
// Number of days since last app session
@property (nonatomic) NSInteger daysSinceLastSession;
// Calendar type
@property (nonatomic, strong) NSLocale *locale;

@end

@implementation ATLifeCycle

+ (BOOL)isInitialized {
    return _initialized;
}

+ (BOOL)isFirstSession {
    return _firstSession;
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
                    [self updateFirstLaunch];
                    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
                    NSNumber *launchCount = [userDefaults objectForKey:SESSION_COUNT];
                    if(launchCount != nil){
                        [userDefaults setInteger:[launchCount integerValue]+1 forKey:SESSION_COUNT];
                    }
                }
                _timeInBackground = nil;
            }
        }
    }
    
}

+ (void)applicationDidEnterBackground {
    _timeInBackground = [[NSDate alloc] init];
}

+ (void)updateFirstLaunch {
    _firstSession = NO;
    _appVersionChanged = NO;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:0 forKey:FIRST_SESSION];
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
        self.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
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
    dateFormatter.locale = self.locale;
    dateFormatter.dateFormat = @"yyyyMMdd";
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    monthFormatter.locale = self.locale;
    monthFormatter.dateFormat = @"yyyyMM";
    NSDateFormatter *weekFormatter = [[NSDateFormatter alloc] init];
    weekFormatter.locale = self.locale;
    weekFormatter.dateFormat = @"yyyyww";
    
    NSDate *now = [[NSDate alloc] init];
    
    // Not first session
    NSObject *firstSession = [userDefaults objectForKey:FIRST_SESSION];
    if(firstSession){
        _firstSession = NO;
        
        // Last use
        NSDate *lastUse = (NSDate *)[userDefaults objectForKey:LAST_USE];
        if(lastUse){
            self.daysSinceLastSession = [ATTool daysBetweenDates:lastUse toDate:now];
        }
        
        //Session count
        NSNumber *launchCount = [userDefaults objectForKey:SESSION_COUNT];
        if(launchCount != nil){
            [userDefaults setInteger:[launchCount integerValue]+1 forKey:SESSION_COUNT];
        }
        
        //Application version changed
        NSString *appVersion = [userDefaults objectForKey:LAST_APPLICATION_VERSION];
        if(appVersion && ![appVersion isEqualToString:[ATTechnicalContext applicationVersion]]){
            _appVersionChanged = YES;
            [userDefaults setObject:now forKey:APPLICATION_UPDATE];
            [userDefaults setInteger:1 forKey:SESSION_COUNT_SINCE_UPDATE];
            [userDefaults setObject:[ATTechnicalContext applicationVersion] forKey:LAST_APPLICATION_VERSION];
        }else{
            NSInteger launchCountSinceUpdate = [userDefaults integerForKey:SESSION_COUNT_SINCE_UPDATE];
            if(launchCountSinceUpdate){
                [userDefaults setInteger:launchCountSinceUpdate + 1 forKey:SESSION_COUNT_SINCE_UPDATE];
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
        _firstSession = NO;
        [userDefaults setInteger:0 forKey:FIRST_SESSION];
        
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        dateformatter.locale = self.locale;
        dateformatter.dateFormat = @"YYYYMMdd";
        
        NSString *fld = [userDefaults objectForKey:@"firstLaunchDate"];
        [userDefaults setObject:[dateformatter dateFromString:fld]forKey:FIRST_SESSION_DATE];
        [userDefaults setObject:nil forKey:@"firstLaunchDate"];
        
        [userDefaults setInteger:[userDefaults integerForKey:@"ATLaunchCount"] + 1 forKey:SESSION_COUNT];
        
        NSDate *lastUse = (NSDate *)[userDefaults objectForKey:@"lastUseDate"];
        if (lastUse) {
            self.daysSinceLastSession = [ATTool daysBetweenDates:lastUse toDate:now];
        }
        
    } else {
        _firstSession = YES;
        [userDefaults setInteger:1 forKey:FIRST_SESSION];
        [userDefaults setInteger:1 forKey:SESSION_COUNT];
        [userDefaults setObject:now forKey:FIRST_SESSION_DATE];
    }
    
    [userDefaults setObject:now forKey:LAST_USE];
    
    // Application version changed
    [userDefaults setObject:[ATTechnicalContext applicationVersion] forKey:LAST_APPLICATION_VERSION];
    
    [userDefaults synchronize];
}

- (NSString *(^)()) getMetrics {
    return ^NSString *() {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        if (![userDefaults objectForKey:FIRST_SESSION]) {
            [self firstLaunchInit];
        }
        
        NSDate *firstLaunchDate = [userDefaults objectForKey:FIRST_SESSION_DATE];
        NSDate *now = [[NSDate alloc] init];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = self.locale;
        dateFormatter.dateFormat = @"yyyyMMdd";
        
        // First Session
        [self.parameters setObject:[NSNumber numberWithInteger:_firstSession ? 1 : 0] forKey:@"fs"];
        
        // First Session after update
        [self.parameters setObject:[NSNumber numberWithInteger:_appVersionChanged ? 1 : 0] forKey:@"fsau"];
        
        // Session count since update
        if([userDefaults integerForKey:SESSION_COUNT_SINCE_UPDATE]){
            [self.parameters setObject:[NSNumber numberWithInteger:[userDefaults integerForKey:SESSION_COUNT_SINCE_UPDATE]] forKey:@"scsu"];
        }
        
        // Session count
        [self.parameters setObject:[NSNumber numberWithInteger:[userDefaults integerForKey:SESSION_COUNT]] forKey:@"sc"];
        
        // First launch date
        [self.parameters setObject:[NSNumber numberWithInteger:[[dateFormatter stringFromDate:firstLaunchDate] intValue]] forKey:@"fsd"];
        
        // Days since first Session
        [self.parameters setObject:[NSNumber numberWithInteger:[ATTool daysBetweenDates:firstLaunchDate toDate:now]] forKey:@"dsfs"];
        
        // First Session date after update & days since update
        NSDate *applicationUpdate = [userDefaults objectForKey:APPLICATION_UPDATE];
        if(applicationUpdate){
            [self.parameters setObject:[NSNumber numberWithInteger:[[dateFormatter stringFromDate:applicationUpdate] intValue]] forKey:@"fsdau"];
            [self.parameters setObject:[NSNumber numberWithInteger:[ATTool daysBetweenDates:applicationUpdate toDate:now]] forKey:@"dsu"];
        }
        
        // Days since last Session
        [self.parameters setObject:[NSNumber numberWithInteger:self.daysSinceLastSession] forKey:@"dsls"];
        
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
