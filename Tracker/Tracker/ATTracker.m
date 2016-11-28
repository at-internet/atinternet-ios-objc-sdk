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
//  ATTracker.m
//  Tracker
//

#import <UIKit/UIKit.h>
#import "ATTracker.h"
#import "ATParam.h"
#import "ATParamOption.h"
#import "ATConfiguration.h"
#import "ATLifeCycle.h"
#import "ATBuffer.h"
#import "ATTechnicalContext.h"
#import "ATTrackerQueue.h"
#import "ATCrash.h"
#import "ATTool.h"
#import "ATBuilder.h"
#import "NSString+Tool.h"
#import "ATDebugger.h"
#import "ATScreen.h"
#import "ATGesture.h"
#import "ATIdentifiedVisitor.h"
#import "ATContext.h"
#import "ATCustomObject.h"
#import "ATPublisher.h"
#import "ATSelfPromotion.h"
#import "ATLocation.h"
#import "ATCustomVar.h"
#import "ATOrder.h"
#import "ATAisle.h"
#import "ATCart.h"
#import "ATCampaign.h"
#import "ATInternalSearch.h"
#import "ATNuggAd.h"
#import "ATTVTracking.h"
#import "ATDispatcher.h"
#import "ATOffline.h"
#import "ATEvent.h"
#import "ATProduct.h"
#import "ATCustomTreeStructure.h"
#import "ATMediaPlayer.h"


@interface ATTracker()

- (void)setParam:(NSString *)key value:(NSString* (^)())value type:(ATParamType)type;
- (void)setParam:(NSString *)key value:(NSString* (^)())value type:(ATParamType)type options:(ATParamOption *)options;
- (void)handleNotStringParameterSetting:(NSString *)key value:(id)value type:(ATParamType)type options:(ATParamOption *)options;

@end

@implementation ATTracker

@synthesize gestures = _gestures;
@synthesize screens = _screens;
@synthesize dynamicScreens = _dynamicScreens;
@synthesize identifiedVisitor = _identifiedVisitor;
@synthesize customObjects = _customObjects;
@synthesize context = _context;
@synthesize publishers = _publishers;
@synthesize selfPromotions = _selfPromotions;
@synthesize locations = _locations;
@synthesize customVars = _customVars;
@synthesize orders = _orders;
@synthesize aisles = _aisles;
@synthesize cart = _cart;
@synthesize campaigns = _campaigns;
@synthesize internalSearches = _internalSearches;
@synthesize event = _event;
@synthesize nuggAds = _nuggAds;
@synthesize tvTracking = _tvTracking;
@synthesize offline = _offline;
@synthesize products = _products;
@synthesize customTreeStructures = _customTreeStructures;
@synthesize mediaPlayers = _mediaPlayers;
@synthesize delegate = _delegate;

static BOOL _handleCrash = NO;

- (UIViewController *) debugger {
    ATDebugger *debugger = [ATDebugger sharedInstance];
    debugger.offlineMode = self.configuration.parameters[@"storage"];
    return debugger.viewController;
}

- (void)setDebugger:(UIViewController *)viewDebugger {
    ATDebugger *debugger = [ATDebugger sharedInstance];
    debugger.offlineMode = self.configuration.parameters[@"storage"];
    debugger.viewController = viewDebugger;
}

- (ATGestures *)gestures {
    if(!_gestures) {
        _gestures = [[ATGestures alloc] initWithTracker:self];
    }
    
    return _gestures;
}

- (ATScreens *)screens {
    if(!_screens) {
        _screens = [[ATScreens alloc] initWithTracker:self];
    }
    
    return _screens;
}

- (ATDynamicScreens *)dynamicScreens {
    if(!_dynamicScreens) {
        _dynamicScreens = [[ATDynamicScreens alloc] initWithTracker:self];
    }
    
    return _dynamicScreens;
}

- (ATIdentifiedVisitor *)identifiedVisitor {
    if(!_identifiedVisitor) {
        _identifiedVisitor = [[ATIdentifiedVisitor alloc] initWithTracker:self];
    }
    
    return _identifiedVisitor;
}

- (ATCustomObjects *)customObjects {
    if(!_customObjects) {
        _customObjects = [[ATCustomObjects alloc] initWithTracker:self];
    }
    
    return _customObjects;
}

- (ATContext *)context {
    if(!_context) {
        _context = [[ATContext alloc] initWithTracker:self];
    }
    
    return _context;
}

- (ATPublishers *)publishers {
    if(!_publishers) {
        _publishers = [[ATPublishers alloc] initWithTracker:self];
    }
    
    return _publishers;
}

- (ATSelfPromotions *)selfPromotions {
    if (!_selfPromotions) {
        _selfPromotions = [[ATSelfPromotions alloc] initWithTracker:self];
    }
    
    return _selfPromotions;
}

- (ATLocations *)locations {
    if (!_locations) {
        _locations = [[ATLocations alloc] initWithTracker:self];
    }
    
    return _locations;
}

- (ATCustomVars *)customVars {
    if (!_customVars) {
        _customVars = [[ATCustomVars alloc] initWithTracker:self];
    }
    
    return _customVars;
}

- (ATOrders *)orders {
    if (!_orders) {
        _orders = [[ATOrders alloc] initWithTracker:self];
    }
    
    return _orders;
}

- (ATAisles *)aisles {
    if (!_aisles) {
        _aisles = [[ATAisles alloc] initWithTracker:self];
    }
    
    return _aisles;
}

- (ATCart *)cart {
    if (!_cart) {
        _cart = [[ATCart alloc] initWithTracker:self];
    }
    
    return _cart;
}

- (ATCampaigns *)campaigns {
    if (!_campaigns) {
        _campaigns = [[ATCampaigns alloc] initWithTracker:self];
    }
    
    return _campaigns;
}

- (ATInternalSearches *)internalSearches {
    if (!_internalSearches) {
        _internalSearches = [[ATInternalSearches alloc] initWithTracker:self];
    }
    
    return _internalSearches;
}

- (ATEvent *)event {
    if (!_event) {
        _event = [[ATEvent alloc] initWithTracker:self];
    }
    
    return _event;
}

- (ATNuggAds *)nuggAds {
    if (!_nuggAds) {
        _nuggAds = [[ATNuggAds alloc] initWithTracker:self];
    }
    
    return _nuggAds;
}

- (ATTVTracking *)tvTracking {
    if (!_tvTracking) {
        _tvTracking = [[ATTVTracking alloc] initWithTracker:self];
    }
    
    return _tvTracking;
}

- (ATOffline *)offline {
    if (!_offline) {
        _offline = [[ATOffline alloc] initWithTracker:self];
    }
    
    return _offline;
}

- (ATProducts *)products {
    if (!_products) {
        _products = [[ATProducts alloc] initWithTracker:self];
    }
    
    return _products;
}

- (ATCustomTreeStructures *)customTreeStructures {
    if (!_customTreeStructures) {
        _customTreeStructures = [[ATCustomTreeStructures alloc] initWithTracker:self];
    }
    
    return _customTreeStructures;
}

- (ATMediaPlayers *)mediaPlayers {
    if (!_mediaPlayers) {
        _mediaPlayers = [[ATMediaPlayers alloc] initWithTracker:self];
    }
    
    return _mediaPlayers;
}

- (id)delegate {
    return _delegate;
}

- (void)setDelegate:(id)delegate {
    _delegate = delegate;
    
    if (self.lifeCycle) {
        if ([ATLifeCycle isFirstSession]) {
            if (_delegate) {
                if ([_delegate respondsToSelector:@selector(trackerNeedsFirstLaunchApproval:)]) {
                    [_delegate trackerNeedsFirstLaunchApproval:@"Tracker first launch"];
                }
            }
        }
    }
}

- (instancetype)init {
    return [self init: [[ATConfiguration alloc] init].parameters];
}

- (instancetype)init:(NSMutableDictionary *)configuration {
    if (self = [super init]) {
        self.buffer = [[ATBuffer alloc] initWithTracker:self];
        self.configuration = [[ATConfiguration alloc] initWithDictionary: configuration];
        if(![ATLifeCycle isInitialized]){
            NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
            [notificationCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
            [ATLifeCycle applicationDidBecomeActive:self.configuration.parameters];
        }
        self.lifeCycle = [[ATLifeCycle alloc] init];
        self.businessObjects = [[NSMutableDictionary alloc] init];
        self.dispatcher = [[ATDispatcher alloc] initWithTracker:self];
    }
    return self;
}

-(void)applicationDidEnterBackground:(NSNotification*)notification {
    [ATLifeCycle applicationDidEnterBackground];
}

-(void)applicationDidBecomeActive:(NSNotification*)notification {
    [ATLifeCycle applicationDidBecomeActive:self.configuration.parameters];
}


- (NSString *)userId {
    NSString* hash = self.configuration.parameters[@"hashUserId"];
    
    return (hash && [[hash lowercaseString] isEqualToString:@"true"]) ? [[ATTechnicalContext userId:[self.configuration.parameters objectForKey:@"identifier"]] sha256Value] : [ATTechnicalContext userId:[self.configuration.parameters objectForKey:@"identifier"]];
}

+ (BOOL)doNotTrack {
    return ATTechnicalContext.doNotTrack;
}

+ (void)setDoNotTrack:(BOOL)enable {
    ATTechnicalContext.doNotTrack = enable;
}

- (void)setLog:(NSString *)log completionHandler:(void (^)(BOOL))completionHandler {
    if (log) {
        [self setConfig:AT_CONF_LOG value:log completionHandler:completionHandler];
    } else {
        if(self.delegate) {
            if ([self.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.delegate warningDidOccur:@"Bad value for log, default value retained"];
            }
        }
    }
}

- (void)setSecuredLog:(NSString *)securedLog completionHandler:(void (^)(BOOL))completionHandler {
    if (securedLog) {
        [self setConfig:AT_CONF_LOGSSL value:securedLog completionHandler:completionHandler];
    } else {
        if(self.delegate) {
            if ([self.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.delegate warningDidOccur:@"Bad value for secured log, default value retained"];
            }
        }
    }
}

- (void)setSiteId:(int)siteId completionHandler:(void (^)(BOOL))completionHandler {
    if (siteId > 0) {
        [self setConfig:AT_CONF_SITE value:[NSString stringWithFormat:@"%d", siteId] completionHandler:completionHandler];
    } else {
        if(self.delegate) {
            if ([self.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.delegate warningDidOccur:@"Bad value for site id, default value retained"];
            }
        }
    }
}

- (void)setDomain:(NSString *)domain completionHandler:(void (^)(BOOL))completionHandler {
    if (domain) {
        [self setConfig:AT_CONF_DOMAIN value:domain completionHandler:completionHandler];
    } else {
        if(self.delegate) {
            if ([self.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.delegate warningDidOccur:@"Bad value for domain, default value retained"];
            }
        }
    }
}

- (void)setOfflineMode:(ATOfflineMode)offlineMode completionHandler:(void (^)(BOOL))completionHandler {
    NSString* value;
    switch (offlineMode) {
        case ATAlways:
            value = @"always";
            break;
        case ATNever:
            value = @"never";
            break;
        default:
            value = @"required";
            break;
    }
    [self setConfig:AT_CONF_OFFLINE_MODE value:value completionHandler:completionHandler];
}

- (void)setSecureModeEnabled:(BOOL)enabled completionHandler:(void (^)(BOOL))completionHandler {
    if(enabled){
        [self setConfig:AT_CONF_SECURE value:@"true" completionHandler:completionHandler];
    } else {
        [self setConfig:AT_CONF_SECURE value:@"false" completionHandler:completionHandler];
    }
}

- (void)setIdentifierType:(ATIdentifierType)identifierType completionHandler:(void (^)(BOOL))completionHandler {
    if(identifierType == ATIDFV){
        [self setConfig:AT_CONF_IDENTIFIER value:@"idfv" completionHandler:completionHandler];
    } else {
        [self setConfig:AT_CONF_IDENTIFIER value:@"uuid" completionHandler:completionHandler];
    }
}

- (void)setHashUserIdEnabled:(BOOL)enabled completionHandler:(void (^)(BOOL))completionHandler {
    if(enabled){
        [self setConfig:AT_CONF_HASH_USER_ID value:@"true" completionHandler:completionHandler];
    } else {
        [self setConfig:AT_CONF_HASH_USER_ID value:@"false" completionHandler:completionHandler];
    }
}

- (void)setPlugins:(NSArray *)pluginArray completionHandler:(void (^)(BOOL))completionHandler {
    NSMutableString* plugins = [[NSMutableString alloc] initWithString:@""];
    for (id obj in pluginArray) {
        if ([obj integerValue] == 0) {
            if(![plugins isEqualToString:@""]){
                [plugins appendString:@","];
            }
            [plugins appendString:@"tvtracking"];
        } else if ([obj integerValue] == 1) {
            if(![plugins isEqualToString:@""]){
                [plugins appendString:@","];
            }
            [plugins appendString:@"nuggad"];
        }
    }
    [self setConfig:AT_CONF_PLUGINS value:plugins completionHandler:completionHandler];
}

- (void)setPixelPath:(NSString *)pixelPath completionHandler:(void (^)(BOOL))completionHandler {
    if (pixelPath) {
        [self setConfig:AT_CONF_PIXEL_PATH value:pixelPath completionHandler:completionHandler];
    } else {
        if(self.delegate) {
            if ([self.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.delegate warningDidOccur:@"Bad value for pixel path, default value retained"];
            }
        }
    }
}

- (void)setPersistentIdentifiedVisitorEnabled:(BOOL)enabled completionHandler:(void (^)(BOOL))completionHandler {
    if(enabled){
        [self setConfig:AT_CONF_PERSIST_IDENTIFIED_VISITOR value:@"true" completionHandler:completionHandler];
    } else {
        [self setConfig:AT_CONF_PERSIST_IDENTIFIED_VISITOR value:@"false" completionHandler:completionHandler];
    }
}

- (void)setTvTrackingUrl:(NSString *)url completionHandler:(void (^)(BOOL))completionHandler {
    if (url) {
        [self setConfig:AT_CONF_TVTRACKING_URL value:url completionHandler:completionHandler];
    } else {
        if(self.delegate) {
            if ([self.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.delegate warningDidOccur:@"Bad value for tvtracking url, default value retained"];
            }
        }
    }
}

- (void)setTvTrackingVisitDuration:(int)visitDuration completionHandler:(void (^)(BOOL))completionHandler {
    if (visitDuration > 0) {
        [self setConfig:AT_CONF_TVTRACKING_VISIT_DURATION value:[NSString stringWithFormat:@"%d", visitDuration] completionHandler:completionHandler];
    } else {
        if(self.delegate) {
            if ([self.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.delegate warningDidOccur:@"Bad value for tvtracking visit duration, default value retained"];
            }
        }
    }
}

- (void)setTvTrackingSpotValidityTime:(int)time completionHandler:(void (^)(BOOL))completionHandler {
    if (time > 0) {
        [self setConfig:AT_CONF_TVTRACKING_SPOT_VALIDITY_TIME value:[NSString stringWithFormat:@"%d", time] completionHandler:completionHandler];
    } else {
        if(self.delegate) {
            if ([self.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.delegate warningDidOccur:@"Bad value for tvtracking spot validity time, default value retained"];
            }
        }
    }
}

- (void)setBackgroundTaskEnabled:(BOOL)enabled completionHandler:(void (^)(BOOL))completionHandler {
    if(enabled){
        [self setConfig:AT_CONF_ENABLE_BACKGROUND_TASK value:@"true" completionHandler:completionHandler];
    } else {
        [self setConfig:AT_CONF_ENABLE_BACKGROUND_TASK value:@"false" completionHandler:completionHandler];
    }
}

- (void)setCampaignLastPersistenceEnabled:(BOOL)enabled completionHandler:(void (^)(BOOL))completionHandler {
    if(enabled){
        [self setConfig:AT_CONF_CAMPAIGN_LAST_PERSISTENCE value:@"true" completionHandler:completionHandler];
    } else {
        [self setConfig:AT_CONF_CAMPAIGN_LAST_PERSISTENCE value:@"false" completionHandler:completionHandler];
    }
}

- (void)setCampaignLifetime:(int)lifetime completionHandler:(void (^)(BOOL))completionHandler {
    if (lifetime > 0) {
        [self setConfig:AT_CONF_CAMPAIGN_LIFETIME value:[NSString stringWithFormat:@"%d", lifetime] completionHandler:completionHandler];
    } else {
        if(self.delegate) {
            if ([self.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.delegate warningDidOccur:@"Bad value for scampaign lifetime, default value retained"];
            }
        }
    }
}

- (void)setSessionBackgroundDuration:(int)duration completionHandler:(void (^)(BOOL))completionHandler {
    if (duration > 0) {
        [self setConfig:AT_CONF_SESSION_BACKGROUND_DURATION value:[NSString stringWithFormat:@"%d", duration] completionHandler:completionHandler];
    } else {
        if(self.delegate) {
            if ([self.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.delegate warningDidOccur:@"Bad value for session background duration, default value retained"];
            }
        }
    }
}

- (void)setConfig:(NSDictionary *)configuration override:(BOOL)overrideConfig completionHandler:(void (^)(BOOL isSet))completionHandler {

    int keyCount = 0;
    
    if(overrideConfig == YES) {
        [self.configuration.parameters removeAllObjects];
    }
    
    for (NSString *key in configuration) {
        
        keyCount++;
        
        if(![[ATReadOnlyConfiguration list] containsObject:key]) {
            
            NSOperation *configurationOperation = [NSBlockOperation blockOperationWithBlock:^{
                [self.configuration.parameters setObject:[configuration objectForKey:key] forKey:key];
            }];
            
            if(completionHandler != nil && keyCount == [configuration count]) {
                configurationOperation.completionBlock = ^{
                    completionHandler(YES);
                };
            }
            
            [[ATTrackerQueue sharedInstance].queue addOperation:configurationOperation];
            
        } else {
            
            if(completionHandler != nil && keyCount == [configuration count]) {
                completionHandler(NO);
            }
            
            if(self.delegate) {
                if ([self.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                    [self.delegate warningDidOccur:[NSString stringWithFormat:@"Configuration %@ is read only. Value will not be updated", key]];
                }
            }
            
        }
        
    }
}

- (void)setConfig:(NSString *)key value:(NSString *)value completionHandler:(void (^)(BOOL isSet))completionHandler {
    
    if(![[ATReadOnlyConfiguration list] containsObject:key]) {
        
        NSOperation *configurationOperation = [NSBlockOperation blockOperationWithBlock:^{
            [self.configuration.parameters setObject:value forKey:key];
        }];
        
        if(completionHandler != nil) {
            configurationOperation.completionBlock = ^{
                completionHandler(YES);
            };
        }
        
        [[ATTrackerQueue sharedInstance].queue addOperation:configurationOperation];
        
    } else {
        
        if(completionHandler != nil) {
            completionHandler(NO);
        }
        
        if(self.delegate) {
            if ([self.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.delegate warningDidOccur:[NSString stringWithFormat:@"Configuration %@ is read only. Value will not be updated", key]];
            }
        }
        
    }
    
}

- (void)setParam:(NSString *)key value:(NSString* (^)())value type:(ATParamType)type {
    // Check whether the parameter is not in read only mode
    if(![[ATReadOnlyParam list] containsObject:key]) {
        ATParam* param = [[ATParam alloc] init:key value:value type:type];
        NSArray *bufferCollections = [[NSArray alloc] initWithObjects:self.buffer.persistentParameters, self.buffer.volatileParameters, nil];
        NSArray* positions = [ATTool findParameterPosition:key array: bufferCollections];
        NSInteger nbPositions = [positions count];
        
        if(nbPositions > 0) {
            for(int i = 0; i < nbPositions; i++) {
                ATParamBufferPosition* paramPosition = (ATParamBufferPosition *)positions[i];
                
                if(i == 0) {
                    (paramPosition.arrayIndex == 0) ? (self.buffer.persistentParameters[paramPosition.index] = param) :(self.buffer.volatileParameters[paramPosition.index] = param);
                } else {
                     (paramPosition.arrayIndex == 0) ? ([self.buffer.persistentParameters removeObjectAtIndex:paramPosition.index]) :([self.buffer.volatileParameters removeObjectAtIndex:paramPosition.index]);
                }
            }
        } else {
            [self.buffer.volatileParameters addObject:param];
        }
    } else {
        if(self.delegate) {
            if ([self.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.delegate warningDidOccur:[NSString stringWithFormat:@"Parameter %@ is read only. Value will not be updated", key]];
            }
        }
    }
}

- (void)setParam:(NSString *)key value:(NSString* (^)())value type:(ATParamType)type options:(ATParamOption *)options {
    // Check whether the parameter is not in read only mode
    if(![[ATReadOnlyParam list] containsObject:key]) {
        ATParam* param = [[ATParam alloc] init:key value:value type:type options:options];
        NSArray *bufferCollections = [[NSArray alloc] initWithObjects:self.buffer.persistentParameters, self.buffer.volatileParameters, nil];
        NSArray* positions = [ATTool findParameterPosition:key array: bufferCollections];
        NSInteger nbPositions = [positions count];
        
        if(options.append) {
            // Check if parameter is already set
            for(int i = 0; i < nbPositions; i++) {
                ATParamBufferPosition* paramPosition = (ATParamBufferPosition *)positions[i];
                // If new parameter is set to be persistent we move old parameters into the right buffer array
                if(options.persistent) {
                    // If old parameter was in volatile buffer, we place it into the persistent buffer
                    if(paramPosition.arrayIndex > 0) {
                        ATParam* existingParam = self.buffer.volatileParameters[paramPosition.index];
                        [self.buffer.volatileParameters removeObjectAtIndex:paramPosition.index];
                        [self.buffer.persistentParameters addObject:existingParam];
                    }
                } else {
                    if(paramPosition.arrayIndex == 0) {
                        //ATParam* existingParam = self.buffer.volatileParameters[paramPosition.index];
                        ATParam* existingParam = self.buffer.persistentParameters[paramPosition.index];
                        [self.buffer.persistentParameters removeObjectAtIndex:paramPosition.index];
                        [self.buffer.volatileParameters addObject:existingParam];
                    }
                }
            }
            
            (options.persistent) ? [self.buffer.persistentParameters addObject:param] : [self.buffer.volatileParameters addObject:param];
        } else {
            // Check if parameter is already set
            if(nbPositions > 0) {
                for(int i = 0; i < nbPositions; i++) {
                    ATParamBufferPosition* paramPosition = (ATParamBufferPosition *)positions[i];
                    
                    if(i == 0) {
                        if(paramPosition.arrayIndex == 0) {
                            if(options.persistent) {
                                self.buffer.persistentParameters[paramPosition.index] = param;
                            } else {
                                [self.buffer.persistentParameters removeObjectAtIndex:paramPosition.index];
                                [self.buffer.volatileParameters addObject:param];
                            }
                        } else {
                            if(options.persistent) {
                                [self.buffer.volatileParameters removeObjectAtIndex:paramPosition.index];
                                [self.buffer.persistentParameters addObject:param];
                            } else {
                                self.buffer.volatileParameters[paramPosition.index] = param;
                            }
                        }
                    } else {
                        (paramPosition.arrayIndex == 0) ? [self.buffer.persistentParameters removeObjectAtIndex:paramPosition.index] : [self.buffer.volatileParameters removeObjectAtIndex:paramPosition.index];
                    }
                }
            } else {
                (options.persistent) ? [self.buffer.persistentParameters addObject:param] : [self.buffer.volatileParameters addObject:param];
            }
        }
    } else {
        if(self.delegate) {
            if ([self.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.delegate warningDidOccur:[NSString stringWithFormat:@"Parameter %@ is read only. Value will not be updated", key]];
            }
        }
    }
}

- (NSDictionary*)config {
    return self.configuration.parameters;
}

- (ATTracker *)setClosureParam:(NSString *)key value:(NSString *(^)())value {
    [self setParam:key value:value type: ATParamTypeClosure];
    
    return self;
}

- (ATTracker *)setClosureParam:(NSString *)key value:(NSString *(^)())value options:(ATParamOption *)options {
    [self setParam:key value:value type: ATParamTypeClosure options:options];
    
    return self;
}

- (ATTracker *)setStringParam:(NSString *)key value:(NSString *)value {
    if([value parseJSONString] == nil) {
        [self setParam:key value:^NSString* () { return value; } type: ATParamTypeString];
    } else {
        [self setParam:key value:^NSString* () { return value; } type: ATParamTypeJSON];
    }
    
    return self;
}

- (ATTracker *)setStringParam:(NSString *)key value:(NSString *)value options:(ATParamOption *)options {
    if([value parseJSONString] == nil) {
        [self setParam:key value:^NSString* () { return value; } type: ATParamTypeString options: options];
    } else {
        [self setParam:key value:^NSString* () { return value; } type: ATParamTypeJSON options: options];
    }
    
    return self;
}

- (ATTracker *)setNumberParam:(NSString *)key value:(NSNumber *)value {
    [self handleNotStringParameterSetting:key value:value type:ATParamTypeNumber options:nil];
    
    return self;
}

- (ATTracker *)setNumberParam:(NSString *)key value:(NSNumber *)value options:(ATParamOption *)options {
    [self handleNotStringParameterSetting:key value:value type:ATParamTypeNumber options:options];
    
    return self;
}

- (ATTracker *)setIntParam:(NSString *)key value:(NSInteger)value {
    NSNumber* intValue = [NSNumber numberWithLong:value];
    
    [self handleNotStringParameterSetting:key value:intValue type:ATParamTypeInteger options:nil];
    
    return self;
}

- (ATTracker *)setIntParam:(NSString *)key value:(NSInteger)value options:(ATParamOption *)options {
    NSNumber* intValue = [NSNumber numberWithLong:value];

    [self handleNotStringParameterSetting:key value:intValue type:ATParamTypeInteger options:options];
    
    return self;
}

- (ATTracker *)setFloatParam:(NSString *)key value:(float)value {
    NSNumber* floatValue = [NSNumber numberWithFloat:value];
    
    [self handleNotStringParameterSetting:key value:floatValue type:ATParamTypeFloat options:nil];
    
    return self;
}

- (ATTracker *)setFloatParam:(NSString *)key value:(float)value options:(ATParamOption *)options {
    NSNumber* floatValue = [NSNumber numberWithFloat:value];
    
    [self handleNotStringParameterSetting:key value:floatValue type:ATParamTypeFloat options:options];
    
    return self;
}

- (ATTracker *)setDoubleParam:(NSString *)key value:(double)value {
    NSNumber* doubleValue = [NSNumber numberWithDouble:value];
    
    [self handleNotStringParameterSetting:key value:doubleValue type:ATParamTypeDouble options:nil];
    
    return self;
}

- (ATTracker *)setDoubleParam:(NSString *)key value:(double)value options:(ATParamOption *)options {
    NSNumber* doubleValue = [NSNumber numberWithDouble:value];
    
    [self handleNotStringParameterSetting:key value:doubleValue type:ATParamTypeDouble options:options];
    
    return self;
}

- (ATTracker *)setBooleanParam:(NSString *)key value:(BOOL)value {
    NSNumber* boolValue = [NSNumber numberWithBool:value];
    
    [self handleNotStringParameterSetting:key value:boolValue type:ATParamTypeBool options:nil];
    
    return self;
}

- (ATTracker *)setBooleanParam:(NSString *)key value:(BOOL)value options:(ATParamOption *)options {
    NSNumber* boolValue = [NSNumber numberWithBool:value];
    
    [self handleNotStringParameterSetting:key value:boolValue type:ATParamTypeBool options:options];
    
    return self;
}

- (ATTracker *)setArrayParam:(NSString *)key value:(NSArray *)value {
    [self handleNotStringParameterSetting:key value:value type:ATParamTypeArray options:nil];
    
    return self;
}

- (ATTracker *)setArrayParam:(NSString *)key value:(NSArray *)value options:(ATParamOption *)options {
    [self handleNotStringParameterSetting:key value:value type:ATParamTypeArray options:options];
    
    return self;
}

- (ATTracker *)setDictionaryParam:(NSString *)key value:(NSDictionary *)value {
    [self handleNotStringParameterSetting:key value:value type:ATParamTypeJSON options:nil];
    
    return self;
}

- (ATTracker *)setDictionaryParam:(NSString *)key value:(NSDictionary *)value options:(ATParamOption *)options{
    [self handleNotStringParameterSetting:key value:value type:ATParamTypeJSON options:options];
    
    return self;
}

- (void)unsetParam:(NSString *)param {
    NSArray *bufferCollections = [[NSArray alloc] initWithObjects:self.buffer.persistentParameters, self.buffer.volatileParameters, nil];
    NSArray *positions = [ATTool findParameterPosition:param array:bufferCollections];
    
    if ([positions count] > 0) {
        for (ATParamBufferPosition *position in positions) {
            if (position.arrayIndex == 0) {
                [self.buffer.persistentParameters removeObjectAtIndex:position.index];
            } else {
                [self.buffer.volatileParameters removeObjectAtIndex:position.index];
            }
        }
    }
}

- (void)handleNotStringParameterSetting:(NSString *)key value:(id)value type:(ATParamType)type options:(ATParamOption *)options {
    ATConvertedValue* stringValue;
    
    if(options) {
        stringValue = [ATTool convertToString:value separator:options.separator];
        
        if(stringValue.success) {
            [self setParam:key value:^NSString* () { return stringValue.value; } type: type options: options];
        } else {
            if(self.delegate) {
                if ([self.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                    [self.delegate warningDidOccur:[NSString stringWithFormat:@"Parameter %@ could not be inserted in hit. Parameter will be ignored", key]];
                }
            }
        }
    } else {
        stringValue = [ATTool convertToString:value separator:nil];
        
        if(stringValue.success) {
            [self setParam:key value:^NSString* () { return stringValue.value; } type:type];
        } else if(self.delegate) {
            if ([self.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                [self.delegate warningDidOccur:[NSString stringWithFormat:@"Parameter %@ could not be inserted in hit. Parameter will be ignored", key]];
            }
        }
    }
}

- (void)dispatch {
    if ([self.businessObjects count] > 0) {
        
        NSMutableArray *onAppAds = [[NSMutableArray alloc] init];
        NSMutableArray *customObjects = [[NSMutableArray alloc] init];
        NSMutableArray *screenObjects = [[NSMutableArray alloc] init];
        NSMutableArray *salesTrackerObjects = [[NSMutableArray alloc] init];
        NSMutableArray *internalSearchObjects = [[NSMutableArray alloc] init];
        NSMutableArray *products = [[NSMutableArray alloc] init];
        
        NSArray *sortedObjects = [[self.businessObjects allValues] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES]]];
        
        for (id object in sortedObjects) {
            
            if (![object isKindOfClass:[ATProduct class]]) {
                [self dispatchObjects:products customObjects:customObjects];
            }
            
            if (! ([object isKindOfClass:[ATOnAppAd class]] ||
                  [object isKindOfClass:[ATScreenInfo class]] ||
                  [object isKindOfClass:[ATAbstractScreen class]] ||
                  [object isKindOfClass:[ATInternalSearch class]] ||
                  [object isKindOfClass:[ATCart class]] ||
                  [object isKindOfClass:[ATOrder class]])
                || ([object isKindOfClass:[ATOnAppAd class]] && ((ATOnAppAd *)object).action == ATAdActionTouch)) {
                
                [self dispatchObjects:onAppAds customObjects:customObjects];
                
            }
            
            if ([object isKindOfClass:[ATOnAppAd class]]) {
                
                if (((ATOnAppAd *)object).action == ATAdActionView) {
                    [onAppAds addObject:object];
                } else {
                    [customObjects addObject:object];
                    [self.dispatcher dispatch:customObjects];
                    [customObjects removeAllObjects];
                }
                
            } else if ([object isKindOfClass:[ATProduct class]]) {
                
                [products addObject:object];
                
            } else if ([object isKindOfClass:[ATCustomObject class]] || [object isKindOfClass:[ATNuggAd class]]) {
                
                [customObjects addObject:object];
                
            } else if ([object isKindOfClass:[ATOrder class]] || [object isKindOfClass:[ATCart class]]) {
                
                [salesTrackerObjects addObject:object];
                
            } else if ([object isKindOfClass:[ATScreenInfo class]]) {
                
                [screenObjects addObject:object];
                
            } else if ([object isKindOfClass:[ATInternalSearch class]]) {
                
                [internalSearchObjects addObject:object];
                
            } else if ([object isKindOfClass:[ATAbstractScreen class]]) {
                
                [onAppAds addObjectsFromArray:customObjects];
                [onAppAds addObjectsFromArray:screenObjects];
                [onAppAds addObjectsFromArray:internalSearchObjects];
                
                NSMutableArray *orders = [[NSMutableArray alloc] init];
                ATCart *cart;
                
                if ([salesTrackerObjects count] > 0) {
                    for (id stObject in salesTrackerObjects) {
                        if ([stObject isKindOfClass:[ATCart class]]) {
                            cart = stObject;
                        } else {
                            [orders addObject:stObject];
                        }
                    }
                }
                
                if (cart) {
                    if (((ATAbstractScreen *)object).isBasketScreen || [orders count] > 0) {
                        [onAppAds addObject:cart];
                    }
                }
                
                [onAppAds addObjectsFromArray:orders];
                [onAppAds addObject:object];
                
                [self.dispatcher dispatch:(onAppAds)];
                
                [screenObjects removeAllObjects];
                [salesTrackerObjects removeAllObjects];
                [internalSearchObjects removeAllObjects];
                [onAppAds removeAllObjects];
                [customObjects removeAllObjects];
                
            } else {
                
                if ([object isKindOfClass:[ATGesture class]] && ((ATGesture *)object).action == ATGestureActionSearch) {
                    [onAppAds addObjectsFromArray:internalSearchObjects];
                    [internalSearchObjects removeAllObjects];
                }
                
                [onAppAds addObjectsFromArray:customObjects];
                [onAppAds addObject:object];
                [self.dispatcher dispatch:(onAppAds)];
                
                [onAppAds removeAllObjects];
                [customObjects removeAllObjects];
                
            }
            
        }
        
        [self dispatchObjects:onAppAds customObjects:customObjects];
        [self dispatchObjects:products customObjects:customObjects];
        
        if ([customObjects count] > 0 || [internalSearchObjects count] > 0 || [screenObjects count] > 0) {
            
            [customObjects addObjectsFromArray:internalSearchObjects];
            [customObjects addObjectsFromArray:screenObjects];
            [self.dispatcher dispatch:customObjects];
            [customObjects removeAllObjects];
            [internalSearchObjects removeAllObjects];
            [screenObjects removeAllObjects];
            
        }
        
    } else {
        [self.dispatcher dispatch:nil];
    }
    
}

- (void)dispatchObjects:(inout NSMutableArray *)objects customObjects:(inout NSMutableArray *)customObjects {
    
    if ([objects count] > 0) {
        
        [objects addObjectsFromArray:customObjects];
        [self.dispatcher dispatch:objects];
        
        [customObjects removeAllObjects];
        [objects removeAllObjects];
        
    }
    
}

+ (BOOL)handleCrash {
    return _handleCrash;
}

+ (void)setHandleCrash:(BOOL)value {
    if (!_handleCrash) {
        _handleCrash = value;
        
        if (_handleCrash) {
            [ATCrash handle];
        }
    }
}

@end
