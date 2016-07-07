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
//  ATTracker.h
//  Tracker
//


#import <Foundation/Foundation.h>

@class UIViewController;

@class ATBuffer;
@class ATConfiguration;
@class ATDispatcher;
@class ATLifeCycle;

@class ATContext;
@class ATParamOption;

@class ATAisles;
@class ATCampaigns;
@class ATCart;
@class ATCustomObjects;
@class ATCustomTreeStructures;
@class ATCustomVars;
@class ATDynamicScreens;
@class ATEvent;
@class ATGestures;
@class ATIdentifiedVisitor;
@class ATInternalSearches;
@class ATLocations;
@class ATMediaPlayers;
@class ATOffline;
@class ATOrders;
@class ATProducts;
@class ATPublishers;
@class ATScreens;
@class ATSelfPromotions;

@class ATNuggAds;
@class ATTVTracking;


/**
 Hit status
 */
typedef NS_ENUM(int, ATHitStatus) {
    ATHitStatusFailed = 0,
    ATHitStatusSuccess = 1
};

/**
Offline mode
*/
typedef NS_ENUM(int, ATOfflineMode) {
    ATAlways = 0,
    ATRequired = 1,
    ATNever = 2,
};

/**
 Identifier type
 */
typedef NS_ENUM(int, ATIdentifierType) {
    ATUUID = 0,
    ATIDFV = 1
};

/**
 Identifier type
 */
typedef NS_ENUM(int, ATPluginKey) {
    ATTvTracking = 0,
    ATNuggad = 1
};

#pragma mark Tracker

@interface ATTracker : NSObject

#pragma mark -- Constants Configuration

#define AT_CONF_LOG                             @"log"
#define AT_CONF_LOGSSL                          @"logSSL"
#define AT_CONF_DOMAIN                          @"domain"
#define AT_CONF_PIXEL_PATH                      @"pixelPath"
#define AT_CONF_SITE                            @"site"
#define AT_CONF_IDENTIFIER                      @"identifier"
#define AT_CONF_SECURE                          @"secure"
#define AT_CONF_OFFLINE_MODE                    @"storage"
#define AT_CONF_PLUGINS                         @"plugins"
#define AT_CONF_CAMPAIGN_LIFETIME               @"campaignLifetime"
#define AT_CONF_SESSION_BACKGROUND_DURATION     @"sessionBackgroundDuration"
#define AT_CONF_CAMPAIGN_LAST_PERSISTENCE       @"campaignLastPersistence"
#define AT_CONF_TVTRACKING_URL                  @"tvtURL"
#define AT_CONF_TVTRACKING_VISIT_DURATION       @"tvtVisitDuration"
#define AT_CONF_TVTRACKING_SPOT_VALIDITY_TIME   @"tvtSpotValidityTime"
#define AT_CONF_PERSIST_IDENTIFIED_VISITOR      @"persistIdentifiedVisitor"
#define AT_CONF_HASH_USER_ID                    @"hashUserId"
#define AT_CONF_ENABLE_BACKGROUND_TASK          @"enableBackgroundTask"

#pragma mark - Properties

#pragma mark -- Tool

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) UIViewController *debugger;

#pragma mark -- Internal

@property (nonatomic, strong) NSMutableDictionary *businessObjects;
@property (nonatomic, strong) ATBuffer *buffer;
@property (nonatomic, strong) ATConfiguration *configuration;
@property (nonatomic, strong, readonly) NSDictionary *config;
@property (nonatomic, strong) ATContext *context;
@property (nonatomic, strong) ATDispatcher *dispatcher;
@property (nonatomic, strong) ATLifeCycle *lifeCycle;

#pragma mark -- Helpers

@property (nonatomic, strong) ATAisles *aisles;
@property (nonatomic, strong) ATCampaigns *campaigns;
@property (nonatomic, strong) ATCart *cart;
@property (nonatomic, strong) ATCustomObjects *customObjects;
@property (nonatomic, strong) ATCustomTreeStructures *customTreeStructures;
@property (nonatomic, strong) ATCustomVars *customVars;
@property (nonatomic, strong) ATDynamicScreens *dynamicScreens;
@property (nonatomic, strong) ATEvent *event;
@property (nonatomic, strong) ATGestures *gestures;
@property (nonatomic, strong) ATIdentifiedVisitor *identifiedVisitor;
@property (nonatomic, strong) ATInternalSearches *internalSearches;
@property (nonatomic, strong) ATLocations *locations;
@property (nonatomic, strong) ATMediaPlayers *mediaPlayers;
@property (nonatomic, strong) ATOffline *offline;
@property (nonatomic, strong) ATOrders *orders;
@property (nonatomic, strong) ATProducts *products;
@property (nonatomic, strong) ATPublishers *publishers;
@property (nonatomic, strong) ATScreens *screens;
@property (nonatomic, strong) ATSelfPromotions *selfPromotions;

#pragma mark -- Plugins

@property (nonatomic, strong) ATNuggAds *nuggAds;
@property (nonatomic, strong) ATTVTracking *tvTracking;


#pragma mark - Methods

#pragma mark -- Init

/**
 initialize a new ATTracker instance
 
 @return a tracker instance
 */
- (instancetype)init;

/**
 initialize a new ATTracker instance
 @param configuration the configuration of the tracker
 
 @return a tracker instance
 */
- (instancetype)init:(NSDictionary *)configuration NS_DESIGNATED_INITIALIZER;

#pragma mark -- Configuration

/**
 Set a new configuration object
 @param configuration the new complete configuration of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setConfig:(NSDictionary *)configuration override:(BOOL)overrideConfig completionHandler:(void (^)(BOOL))completionHandler;

/**
 Set a new configuration key
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setConfig:(NSString *)key value:(NSString *)value completionHandler:(void (^)(BOOL))completionHandler;

/**
 Set a new log
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setLog:(NSString *)log completionHandler:(void (^)(BOOL))completionHandler;

/**
 Set a new secured log
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setSecuredLog:(NSString *)securedLog completionHandler:(void (^)(BOOL))completionHandler;

/**
 Set a new domain
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setDomain:(NSString *)domain completionHandler:(void (^)(BOOL))completionHandler;

/**
 Set a new site id
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setSiteId:(int)siteId completionHandler:(void (^)(BOOL))completionHandler;

/**
 Set a new offline mode
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setOfflineMode:(ATOfflineMode)offlineMode completionHandler:(void (^)(BOOL))completionHandler;

/**
 Enable secure mode
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setSecureModeEnabled:(BOOL)enabled completionHandler:(void (^)(BOOL))completionHandler;

/**
 Set a new identifier type
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setIdentifierType:(ATIdentifierType)identifierType completionHandler:(void (^)(BOOL))completionHandler;

/**
 Enable hash user id
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setHashUserIdEnabled:(BOOL)enabled completionHandler:(void (^)(BOOL))completionHandler;

/**
 Set new plugins
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setPlugins:(NSArray *)pluginsArray completionHandler:(void (^)(BOOL))completionHandler;

/**
 Set a new pixel path
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setPixelPath:(NSString *)pixelPath completionHandler:(void (^)(BOOL))completionHandler;

/**
 Enable persistence identified visitor
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setPersistentIdentifiedVisitorEnabled:(BOOL)enabled completionHandler:(void (^)(BOOL))completionHandler;

/**
 Enable background task
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setBackgroundTaskEnabled:(BOOL)enabled completionHandler:(void (^)(BOOL))completionHandler;

/**
 Set a new tvt url
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setTvTrackingUrl:(NSString *)url completionHandler:(void (^)(BOOL))completionHandler;

/**
 Set a new tvt visit duration
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setTvTrackingVisitDuration:(int)visitDuration completionHandler:(void (^)(BOOL))completionHandler;

/**
 Set a new tvt visit duration
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setTvTrackingSpotValidityTime:(int)time completionHandler:(void (^)(BOOL))completionHandler;

/**
 Enable campaign last persistence
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setCampaignLastPersistenceEnabled:(BOOL)enabled completionHandler:(void (^)(BOOL))completionHandler;

/**
 Set a new campaign lifetime
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setCampaignLifetime:(int)lifetime completionHandler:(void (^)(BOOL))completionHandler;

/**
 Set a new campaign lifetime
 @param configuration a new configuration key of the tracker
 @param completionHandler this part of code will be executed when the configuration is handled by the tracker
 */
- (void)setSessionBackgroundDuration:(int)duration completionHandler:(void (^)(BOOL))completionHandler;

#pragma mark -- Parameter

/**
 Add a closure parameter to the hit querystring
 @param key parameter key
 @param value parameter value
 
 @return the tracker instance
 */
- (ATTracker *)setClosureParam:(NSString *)key value:(NSString *(^)())value;

/**
 Add a closure parameter to the hit querystring
 @param key parameter key
 @param value parameter value
 @param options parameter options
 
 @return the tracker instance
 */
- (ATTracker *)setClosureParam:(NSString *)key value:(NSString *(^)())value options:(ATParamOption *)options;

/**
 Add a string parameter to the hit querystring
 @param key parameter key
 @param value parameter value
 
 @return the tracker instance
 */
- (ATTracker *)setStringParam:(NSString *)key value:(NSString *)value;

/**
 Add a string parameter to the hit querystring
 @param key parameter key
 @param value parameter value
 @param options parameter options
 
 @return the tracker instance
 */
- (ATTracker *)setStringParam:(NSString *)key value:(NSString *)value options:(ATParamOption *)options;

/**
 Add a number parameter to the hit querystring
 @param key parameter key
 @param value parameter value
 
 @return the tracker instance
 */
- (ATTracker *)setNumberParam:(NSString *)key value:(NSNumber *)value;

/**
 Add a number parameter to the hit querystring
 @param key parameter key
 @param value parameter value
 @param options parameter options
 
 @return the tracker instance
 */
- (ATTracker *)setNumberParam:(NSString *)key value:(NSNumber *)value options:(ATParamOption *)options;

/**
 Add an integer parameter to the hit querystring
 @param key parameter key
 @param value parameter value
 
 @return the tracker instance
 */
- (ATTracker *)setIntParam:(NSString *)key value:(NSInteger)value;

/**
 Add an integer parameter to the hit querystring
 @param key parameter key
 @param value parameter value
 @param options parameter options
 
 @return the tracker instance
 */
- (ATTracker *)setIntParam:(NSString *)key value:(NSInteger)value options:(ATParamOption *)options;

/**
 Add a float parameter to the hit querystring
 @param key parameter key
 @param value parameter value
 
 @return the tracker instance
 */
- (ATTracker *)setFloatParam:(NSString *)key value:(float)value;

/**
 Add a float parameter to the hit querystring
 @param key parameter key
 @param value parameter value
 @param options parameter options
 
 @return the tracker instance
 */
- (ATTracker *)setFloatParam:(NSString *)key value:(float)value options:(ATParamOption *)options;

/**
 Add a double parameter to the hit querystring
 @param key parameter key
 @param value parameter value
 
 @return the tracker instance
 */
- (ATTracker *)setDoubleParam:(NSString *)key value:(double)value;

/**
 Add a double parameter to the hit querystring
 @param key parameter key
 @param value parameter value
 @param options parameter options
 
 @return the tracker instance
 */
- (ATTracker *)setDoubleParam:(NSString *)key value:(double)value options:(ATParamOption *)options;

/**
 Add a boolean parameter to the hit querystring
 @param key parameter key
 @param value parameter value
 
 @return the tracker instance
 */
- (ATTracker *)setBooleanParam:(NSString *)key value:(BOOL)value;

/**
 Add a boolean parameter to the hit querystring
 @param key parameter key
 @param value parameter value
 @param options parameter options
 
 @return the tracker instance
 */
- (ATTracker *)setBooleanParam:(NSString *)key value:(BOOL)value options:(ATParamOption *)options;

/**
 Add an array parameter to the hit querystring
 @param key parameter key
 @param value parameter value
 
 @return the tracker instance
 */
- (ATTracker *)setArrayParam:(NSString *)key value:(NSArray *)value;

/**
 Add an array parameter to the hit querystring
 @param key parameter key
 @param value parameter value
 @param options parameter options
 
 @return the tracker instance
 */
- (ATTracker *)setArrayParam:(NSString *)key value:(NSArray *)value options:(ATParamOption *)options;

/**
 Add a dictionary parameter to the hit querystring
 @param key parameter key
 @param value parameter value
 
 @return the tracker instance
 */
- (ATTracker *)setDictionaryParam:(NSString *)key value:(NSDictionary *)value;

/**
 Add a dictionary parameter to the hit querystring
 @param key parameter key
 @param value parameter value
 @param options parameter options
 
 @return the tracker instance
 */
- (ATTracker *)setDictionaryParam:(NSString *)key value:(NSDictionary *)value options:(ATParamOption *)options;

/**
 Remove a parameter from the hit querystring
 @param key parameter key
 */
- (void)unsetParam:(NSString *)param;

#pragma mark -- Dispatch

/**
 Send the built hit
 */
- (void)dispatch;

#pragma mark -- User identifier

/**
 Get the user identifier
 
 @return the user identifier according to the configuration (UUID, IDFV)
 */
- (NSString *)userId;

#pragma mark -- Do not track

/**
 Get the do not track state
 */
+ (BOOL)doNotTrack;

/**
 Enable or disable identifier tracking
 @param do not track state
 */
+ (void)setDoNotTrack:(BOOL)enable;

#pragma mark -- Crash

/**
 Get the crash tracking state
 */
+ (BOOL)handleCrash;

/**
 Enable or disable crash tracking
 Use only if you don't already use another crash analytics solution
 Once enabled, tracker crash handler can't be disabled until tracker instance termination
 @param crash tracking state
 */
+ (void)setHandleCrash:(BOOL)value;

@end


#pragma mark Tracker Delegate

/**
 Tracker's delegate
 */
@protocol ATTrackerDelegate

@optional

/**
 First launch of the tracker
 @param message approval message for confidentiality
 */
- (void)trackerNeedsFirstLaunchApproval:(NSString *)message;

/**
 Building of hit done
 @param status result of hit building
 @param message info about hit building
 */
- (void)buildDidEnd:(ATHitStatus)status message:(NSString *)message;

/**
 Sending of hit done
 @param status sending result
 @param message information about sending result
 */
- (void)sendDidEnd:(ATHitStatus)status message:(NSString *)message;

/**
 Saving of hit done (offline)
 @param message information about saving result
 */
- (void)saveDidEnd:(NSString *)message;

/**
 Partner call done
 @param response the response received from the partner
 */
- (void)didCallPartner:(NSString *)response;

/**
 Received a warning message (does not stop hit sending)
 @param message the warning message
 */
- (void)warningDidOccur:(NSString *)message;

/**
 Received an error message (stop hit sending)
 @param message the error message
 */
- (void)errorDidOccur:(NSString *)message;

@end
