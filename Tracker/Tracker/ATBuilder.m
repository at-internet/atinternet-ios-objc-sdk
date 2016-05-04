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
//  ATBuilder.m
//  Tracker
//


#import "ATBuilder.h"
#import "ATTracker.h"
#import "ATConfiguration.h"
#import "ATTechnicalContext.h"
#import "NSString+Tool.h"
#import "ATParam.h"
#import "ATParamOption.h"
#import "ATSender.h"
#import "ATTool.h"
#import "ATPluginProtocol.h"
#import "ATHit.h"


/* --- CONFIGURATION --- */

// Number of configuration part
#define AT_REF_CONFIG_CHUNKS 4

// Constant for secure configuration key
#define AT_SSL_KEY @"secure"

// Constant for log configuration key
#define AT_LOG_KEY @"log"

// Constant for secured log configuration key
#define AT_SSL_LOG_KEY @"logSSL"

// Constant for site configuration key
#define AT_SITE_KEY @"site"

// Constant for pixel path configuration key
#define AT_PIXEL_PATH_KEY @"pixelPath"

// Constant for domain configuration key
#define AT_DOMAIN_KEY @"domain"

// Constant for Ref parameter
#define AT_REF_PARAMETER_KEY @"ref"


/* --- MULTIHITS --- */

// Hit maximum length
#define AT_HIT_MAX_LENGTH 1600

// Mhid maxium length
#define AT_MHID_MAX_LENGTH 30

// Added to slices olt maximum length
#define AT_OLT_MAX_LENGTH 20

// Added to slices idclient maximum length
#define AT_IDCLIENT_MAX_LENGTH 40

// Added to slices separator maximum length
#define AT_SEPARATOR_MAX_LENGTH 5

// Hit max chunks
#define AT_MAX_CHUNKS 999


@interface ATBuilder()

/**
 Tracker instance
 */
@property (nonatomic, strong) ATTracker *tracker;

@end


@implementation ATQueryString

@end


@implementation ATBuilder

/**
 Hit builder initialization
 
 @param tracker
 @param configuration
 @param volatileParameters list of all volatile parameters
 @param persistentParameters list of all parameters that should be sent in all hits
 
 @return A builder instance with default configuration and an empty buffer
 */
- (instancetype)initWithTracker:(ATTracker *)tracker
             volatileParameters:(NSArray *)volatileParameters
           persistentParameters:(NSArray *)persistentParameters {
    
    if (self = [super init]) {
        self.tracker = tracker;
        self.volatileParameters = volatileParameters;
        self.persistentParameters = persistentParameters;
    }
    
    return self;
    
}

/**
 Builds first half of the hit with configuration parameters

 @return A string which represent the beginning of the hit
 */
- (NSString *)buildConfiguration {
    NSMutableString *hitConf = [[NSMutableString alloc] initWithFormat:@""];
    int hitConfChunks = 0;
    
    if ([[[self.tracker.configuration.parameters objectForKey:AT_SSL_KEY] lowercaseString] isEqualToString:@"true"]) {
        NSString *logs = [self.tracker.configuration.parameters objectForKey:AT_SSL_LOG_KEY];
        if (logs != nil && ![logs isEqualToString:@""]) {
            [hitConf appendFormat:@"https://%@.", logs];
            hitConfChunks++;
        }
    } else {
        NSString *log = [self.tracker.configuration.parameters objectForKey:AT_LOG_KEY];
        if (log != nil && ![log isEqualToString:@""]) {
            [hitConf appendFormat:@"http://%@.", log];
            hitConfChunks++;
        }
    }
    
    NSString *domain = [self.tracker.configuration.parameters objectForKey:AT_DOMAIN_KEY];
    if (domain != nil && ![domain isEqualToString:@""]) {
        [hitConf appendString:domain];
        hitConfChunks++;
    }
    
    NSString *pixelpath = [self.tracker.configuration.parameters objectForKey:AT_PIXEL_PATH_KEY];
    if (pixelpath != nil && ![pixelpath isEqualToString:@""]) {
        [hitConf appendString:pixelpath];
        hitConfChunks++;
    }
    
    NSString *site = [self.tracker.configuration.parameters objectForKey:AT_SITE_KEY];
    if (site != nil && ![site isEqualToString:@""]) {
        [hitConf appendFormat:@"?s=%@", site];
        hitConfChunks++;
    }
    
    if (hitConfChunks != AT_REF_CONFIG_CHUNKS) {
        // On lève une erreur indiquant que la configuration est incorrecte
        if (self.tracker.delegate) {
            if ([self.tracker.delegate respondsToSelector:@selector(errorDidOccur:)]) {
                NSString *message = [[NSString alloc] initWithFormat:
                                     @"There is something wrong with configuration: %@. Expected %d configuration keys, found %d",
                                     hitConf, AT_REF_CONFIG_CHUNKS, hitConfChunks];
                [self.tracker.delegate errorDidOccur:message];
            }
        }
        
        hitConf = [@"" mutableCopy];
    }
    
    return hitConf;
}

/**
 Builds the hit to be sent and slices it to chunks if too long.
 
 @return An array representing the hit(s) to be sent
 */
- (NSArray *)build {
    
    // Hits returned and ready to be sent
    NSMutableArray *hits = [[NSMutableArray alloc] init];
    
    // Hit chunks count
    int chunksCount = 1;

    // Hit construction holder
    NSMutableString *hit = [[NSMutableString alloc] initWithFormat:@""];

    // Get the first part of the hit
    NSString *config = [self buildConfiguration];

    // Get the parameters from the buffer (formatted as &p=v)
    NSArray *formattedParams = [self prepareQuery];
    
    // Reference maximum size
    NSUInteger refMaxSize = AT_HIT_MAX_LENGTH
    - AT_MHID_MAX_LENGTH
    - config.length
    - AT_OLT_MAX_LENGTH
    - AT_IDCLIENT_MAX_LENGTH
    - AT_SEPARATOR_MAX_LENGTH;
    
    // Hit slicing error
    BOOL err = NO;
    NSString *errQuery = [self makeSubQueryForParameter:@"mherr" value:@"1"];
    
    // Idclient added to slices
    NSString *idclient = [ATTechnicalContext userId:[self.tracker.configuration.parameters objectForKey:@"identifier"]];
    
    // For each prebuilt queryString, we check the length
    for (ATQueryString *queryString in formattedParams) {
        
        // If the queryString length is too long
        if (queryString.str.length > refMaxSize) {
            
            // Check if the concerned parameter value in the queryString is allowed to be sliced
            if ([[ATSliceReadyParam list] containsObject:queryString.param.key]) {
                
                NSString *separator;
                if (queryString.param.options.separator != nil
                    && ![queryString.param.options.separator isEqualToString:@""]) {
                    separator = queryString.param.options.separator;
                } else {
                    separator = @",";
                }
                
                // We slice the parameter value on the parameter separator
                NSArray *components = [queryString.str componentsSeparatedByString:@"="];
                NSArray *valChunks = [[components objectAtIndex:1] componentsSeparatedByString:separator];
                
                // Parameter key to re-add on each chunks where the value is spread
                BOOL keyAdded = NO;
                NSString *keySplit = [[NSString alloc] initWithFormat:@"&%@=", queryString.param.key];
                
                // For each sliced value, we check if we can add it to current hit, else we create and add a new hit
                for (NSString *valChunk in valChunks) {
                    if (!keyAdded && [[hit stringByAppendingFormat:@"%@%@", keySplit, valChunk] length] <= refMaxSize) {
                        [hit appendFormat:@"%@%@", keySplit, valChunk];
                        keyAdded = true;
                    } else if (keyAdded && [[hit stringByAppendingFormat:@"%@%@", separator, valChunk] length] < refMaxSize) {
                        [hit appendFormat:@"%@%@", separator, valChunk];
                    } else {
                        chunksCount++;
                        if (![hit isEqualToString:@""]) {
                            [hits addObject:[hit stringByAppendingString:separator]];
                        }
                        hit = [[NSMutableString alloc] initWithFormat:@"%@%@", keySplit, valChunk];
                        if (chunksCount >= AT_MAX_CHUNKS) {
                            // Too much chunks
                            err = YES;
                            break;
                        } else if (hit.length > refMaxSize) {
                            // Value still too long
                            if (self.tracker.delegate) {
                                if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                                    [self.tracker.delegate warningDidOccur:@"Multihits: value still too long after slicing"];
                                }
                            }
                            // Truncate the value
                            hit = [[hit substringToIndex:(refMaxSize - errQuery.length)] mutableCopy];
                            // Check if in the last 5 characters there is msencoded character, if so we truncate again
                            NSString *lastChars = [hit substringFromIndex:(hit.length - 5)];
                            if ([lastChars rangeOfString:@"%"].location == NSNotFound) {
                                hit = [[hit substringToIndex:(hit.length - 5)] mutableCopy];
                            }
                            [hit appendFormat:@"%@", errQuery];
                            err = YES;
                            break;
                        }
                    }
                }
                
                if (err) {
                    break;
                }
                
            } else {
                // Value can't be sliced
                if (self.tracker.delegate) {
                    if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                        [self.tracker.delegate warningDidOccur:@"Multihits: parameter value not allowed to be sliced"];
                    }
                }
                [hit appendFormat:@"%@", errQuery];
                break;
            }
            
        // Else if the current hit + queryString length is not too long, we add it to the current hit
        } else if ([[hit stringByAppendingFormat:@"%@", queryString.str] length] <= refMaxSize) {
            [hit appendFormat:@"%@", queryString.str];
        // Else, we add a new hit
        } else {
            chunksCount++;
            [hits addObject:hit];
            hit = [[NSMutableString alloc] initWithString:queryString.str];
            
            // Too much chunks
            if (chunksCount >= AT_MAX_CHUNKS) {
                break;
            }
        }
        
    }
    
    // We add the current working hit
    [hits addObject:hit];
    
    // If chunksCount > 1, we have sliced a hit
    if (chunksCount > 1) {
        
        NSString *mhidSuffix = [[NSString alloc] initWithFormat:@"-%d-%@", chunksCount, [ATBuilder mhidSuffixGenerator]];
        
        for (int index = 0; index <= [hits count] - 1; index++) {
            
            if (index == (AT_MAX_CHUNKS - 1)) {
                // Too much chunks
                if (self.tracker.delegate) {
                    if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                        [self.tracker.delegate warningDidOccur:@"Multihits: too much hit parts"];
                        [hits replaceObjectAtIndex:index
                                        withObject:[[NSString alloc] initWithFormat:@"%@%@", config, errQuery]];
                    }
                }
            } else {
                // Add the configuration, the mh variable and the idclient
                NSString *idToAdd = (index > 0) ?
                [self makeSubQueryForParameter:@"idclient" value:idclient] : [[NSString alloc] initWithFormat:@""];
                [hits replaceObjectAtIndex:index
                                withObject:[[NSString alloc] initWithFormat:@"%@&mh=%d%@%@%@", config, index+1, mhidSuffix, idToAdd, [hits objectAtIndex:index]]];
            }
            
        }
    
    // Only one hit
    } else {
        [hits replaceObjectAtIndex:0 withObject:[[NSString alloc] initWithFormat:@"%@%@", config, [hits objectAtIndex:0]]];
    }
    
    if (self.tracker.delegate) {
        if ([self.tracker.delegate respondsToSelector:@selector(buildDidEnd:message:)]) {
            NSMutableString *message = [[NSMutableString alloc] initWithFormat:@""];
            for (NSString *hit in hits) {
                [message appendString:[NSString stringWithFormat:@"%@\n", hit]];
            }
            [self.tracker.delegate buildDidEnd:ATHitStatusSuccess message:message];
        }
    }
    
    return hits;
}

/**
 Sends hit
 */
- (void)main {
    @autoreleasepool {
        // Build the hit
        NSArray *hits = [self build];
        
        // Prepare a fixed olt in case of multihits and offline
        NSString *mhOlt;
        
        if ([hits count] > 1) {
            mhOlt = [[NSString alloc] initWithFormat:@"%f", [NSDate date].timeIntervalSince1970];
        } else {
            mhOlt = nil;
        }
        
        for (NSString *hit in hits) {
            // Wrap a hit to a sender object
            ATSender *sender = [[ATSender alloc] initWithTracker:self.tracker hit:[[ATHit alloc] init:hit] forceSendOfflineHits:NO mhOlt:mhOlt];
            [sender sendWithOfflineHits];
        }
    }
}

/**
 Sort parameters depending on their position
 
 @param an array of parameter to sort
 
 @return An array of sorted parameters
 */

- (NSArray *)organizeParameters:(NSMutableArray *)parameters {

    NSArray *mock = [[NSArray alloc] initWithObjects:[[ATParam alloc] init], nil];
    NSArray *templateParameters = [[NSArray alloc] initWithObjects:mock, parameters, nil];
    NSArray *refParamPositions = [ATTool findParameterPosition:AT_REF_PARAMETER_KEY array:templateParameters];
    NSUInteger refParamIndex = -1;
    
    if ([refParamPositions count] > 0) {
        refParamIndex = ((ATParamBufferPosition *)[refParamPositions lastObject]).index;
    }
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    
    // Parameter with relative position set to last
    ATParam *lastParameter;
    
    // Parameter with relative position set to first
    ATParam *firstParameter;
    
    // ref= Parameter
    ATParam *refParameter;
    
    // Handle ref= parameter which have to be in last position
    if(refParamIndex > -1) {
        refParameter = parameters[refParamIndex];
        [parameters removeObjectAtIndex:refParamIndex];
        
        if (refParameter) {
            if (refParameter.options) {
                if (refParameter.options.relativePosition != ATRelativePositionNone
                    && refParameter.options.relativePosition != ATRelativePositionLast) {
                    // Raise a warning explaining ref will always be set in last position
                    if (self.tracker.delegate) {
                        if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                            [self.tracker.delegate warningDidOccur:@"ref= parameter will be put in last position"];
                        }
                    }
                }
            }
        }
    }
    
    for (ATParam *parameter in parameters) {
        if (parameter.options) {
            switch (parameter.options.relativePosition) {
                // A parameter is set in first position
                case ATRelativePositionFirst:
                    if (firstParameter) {
                        if (self.tracker.delegate) {
                            if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                                [self.tracker.delegate warningDidOccur:@"Found more than one parameter with relative position set to first"];
                            }
                        }
                        [params addObject:parameter];
                    } else {
                        [params insertObject:parameter atIndex:0];
                        firstParameter = parameter;
                    }
                    break;
                    
                // A parameter is set in first position
                case ATRelativePositionLast:
                    if (lastParameter) {
                        // Raise a warning explaining there are multiple parameters with a last position indicator
                        if (self.tracker.delegate) {
                            if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                                [self.tracker.delegate warningDidOccur:@"Found more than one parameter with relative position set to last"];
                            }
                        }
                        [params addObject:parameter];
                    } else {
                        lastParameter = parameter;
                    }
                    break;
                    
                // A parameter is set before an other parameter
                case ATRelativePositionBefore:
                    if (parameter.options.relativeParameterKey) {
                        NSArray *relativePosParam = [ATTool findParameterPosition:parameter.options.relativeParameterKey array:templateParameters];
                        //NSArray *relativePosParam = [ATTool findParameterPosition:parameter.options.relativeParameterKey array:parameters];
                        if ([relativePosParam count] > 0) {
                            //NSUInteger lastIndex = [relativePosParam indexOfObject:[relativePosParam lastObject]];
                            [params insertObject:parameter atIndex:((ATParamBufferPosition *)[relativePosParam lastObject]).index];
                        } else {
                            [params addObject:parameter];
                            // Raise a warning explaining that relative parameter has not been found
                            if (self.tracker.delegate) {
                                if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                                    NSString *message = [[NSString alloc] initWithFormat:@"Relative parameter with key %@ could not be found. Parameter will be appended", parameter.options.relativeParameterKey];
                                    [self.tracker.delegate warningDidOccur:message];
                                }
                            }
                        }
                    }
                    break;
                    
                // A parameter is set after an other parameter
                case ATRelativePositionAfter:
                    if (parameter.options.relativeParameterKey) {
                        NSArray *relativePosParam = [ATTool findParameterPosition:parameter.options.relativeParameterKey array:templateParameters];
                        if ([relativePosParam count] > 0) {
                            [params insertObject:parameter atIndex:(((ATParamBufferPosition *)[relativePosParam lastObject]).index+1)];
                        } else {
                            [params addObject:parameter];
                            // Raise a warning explaining that relative parameter has not been found
                            if (self.tracker.delegate) {
                                if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                                    NSString *message = [[NSString alloc] initWithFormat:@"Relative parameter with key %@ could not be found. Parameter will be appended", parameter.options.relativeParameterKey];
                                    [self.tracker.delegate warningDidOccur:message];
                                }
                            }
                        }
                    }
                    break;
                    
                default:
                    [params addObject:parameter];
            }
        } else {
            [params addObject:parameter];
        }
    }
    
    // Add the parameter marked as "last" in the collection if there is one
    if (lastParameter) {
        [params addObject:lastParameter];
    }
    
    // Always add the parameter ref, if it exists, in last position
    if (refParameter) {
        [params addObject:refParameter];
    }
    
    return params;
    
}

/**
 Prepares parameters (organize, stringify, encode) stored in the buffer to be used in the hit
 
 @return An array of prepared parameters
 */
- (NSArray *)prepareQuery {
    NSMutableArray *params = [[NSMutableArray alloc] init];
    
    NSArray *bufferParams = [self organizeParameters:[[self.persistentParameters arrayByAddingObjectsFromArray:self.volatileParameters] mutableCopy]];
    
    for(ATParam *parameter in bufferParams) {
        NSString* value = @"";
        
        // Plugin management
        NSString* pluginClass = (NSString *)[[ATPluginParam list:self.tracker] objectForKey:parameter.key];
        
        if(pluginClass) {
            Class className = NSClassFromString(pluginClass);
            NSObject <ATPluginProtocol>* plugin = [[className alloc] initWithTracker:self.tracker];
            [plugin execute];
            parameter.key = plugin.paramKey;
            parameter.type = plugin.responseType;
            value = plugin.response;
        } else {
            value = parameter.value();
        }
        
        if(parameter.type == ATParamTypeClosure && [value parseJSONString]) {
            parameter.type = ATParamTypeJSON;
        }
        
        // User id hash management
        if ([parameter.key isEqualToString:@"idclient"]) {
            if (!ATTechnicalContext.doNotTrack) {
                NSString *hash = self.tracker.configuration.parameters[@"hashUserId"];
                if(hash && [[hash lowercaseString] isEqualToString:@"true"]) {
                    value = [value sha256Value];
                }
            } else {
                value = @"opt-out";
            }
        }
        
        // Referrer processing
        if([parameter.key isEqualToString:@"ref"]){
            value = [[[value stringByReplacingOccurrencesOfString:@"&" withString:@"$"] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
        }
        
        if(parameter.options) {
            if(parameter.options.encode) {
                value = [value percentEncodedString];
                parameter.options.separator = [parameter.options.separator percentEncodedString];
            }
        }
        
        NSInteger duplicateParamIndex = -1;
        
        int i = 0;
        for(ATQueryString* param in params) {
            if([param.param.key isEqualToString:parameter.key]) {
                duplicateParamIndex = i;
                break;
            }
            i++;
        }
        
        if(duplicateParamIndex > -1) {
            ATQueryString* duplicateParam = params[duplicateParamIndex];
            
            if(parameter.type == ATParamTypeJSON) {
                NSObject* json = [[[duplicateParam.str componentsSeparatedByString:@"="][1] percentDecodedString] parseJSONString];
                NSObject* newJson = [[value percentDecodedString] parseJSONString];
                
                if([json isKindOfClass:[NSMutableDictionary class]]) {
                    if([newJson isKindOfClass:[NSMutableDictionary class]]) {
                        [((NSMutableDictionary *)json) addEntriesFromDictionary:(NSMutableDictionary *)newJson];
                        
                        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:(NSMutableDictionary *)json options:kNilOptions error:nil];
                        NSString* strJsonData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        
                        ATQueryString* newParam = [[ATQueryString alloc] init];
                        newParam.param = duplicateParam.param;
                        newParam.str = [self makeSubQueryForParameter:parameter.key value:[strJsonData percentEncodedString]];
                        
                        [params replaceObjectAtIndex:duplicateParamIndex withObject:newParam];
                    } else {
                        if(self.tracker.delegate) {
                            if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                                [self.tracker.delegate warningDidOccur:@"Couldn't append value to a dictionnary"];
                            }
                        }
                    }
                } else if([json isKindOfClass:[NSMutableArray class]]) {
                    if([newJson isKindOfClass:[NSMutableArray class]]) {
                        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[((NSMutableArray *)json) arrayByAddingObjectsFromArray:(NSMutableArray *)newJson] options:kNilOptions error:nil];
                        
                        NSString* strJsonData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        
                        ATQueryString* newParam = [[ATQueryString alloc] init];
                        newParam.param = duplicateParam.param;
                        newParam.str = [self makeSubQueryForParameter:parameter.key value:[strJsonData percentEncodedString]];
                        
                        [params replaceObjectAtIndex:duplicateParamIndex withObject:newParam];
                    } else {
                        if(self.tracker.delegate) {
                            if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                                [self.tracker.delegate warningDidOccur:@"Couldn't append value to an array"];
                            }
                        }
                    }
                } else {
                    if(self.tracker.delegate) {
                        if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                            [self.tracker.delegate warningDidOccur:@"Couldn't append a JSON"];
                        }
                    }
                }
            } else {
                if(duplicateParam.param.type == ATParamTypeJSON) {
                    if(self.tracker.delegate) {
                        if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                            [self.tracker.delegate warningDidOccur:@"Couldn't append value to a JSON Object"];
                        }
                    }
                } else {
                    NSString* separator;
                    
                    if(!parameter.options) {
                        separator = @",";
                    } else {
                        separator = parameter.options.separator;
                    }
                    
                    ATQueryString* newParam = [[ATQueryString alloc] init];
                    newParam.param = duplicateParam.param;
                    newParam.str = [[duplicateParam.str stringByAppendingString:separator] stringByAppendingString:value];
                    
                    [params replaceObjectAtIndex:duplicateParamIndex withObject:newParam];
                }
            }
        } else {
            ATQueryString* newParam = [[ATQueryString alloc] init];
            newParam.param = parameter;
            newParam.str = [self makeSubQueryForParameter:parameter.key value:value];
            
            [params addObject:newParam];

        }
    }
    
    return params;
}

/**
 Builds the querystring parameters
 
 @param parameter key
 @param parameter value
 
 @return A string containing a querystring parameter
 */
- (NSString *)makeSubQueryForParameter:(NSString *)key value:(NSString *)value {
    return [[NSString alloc] initWithFormat:@"&%@=%@", key, value];
}

/**
 Builds a mhid suffix parameter
 
 @return A string mhid suffix
 */

+ (NSString *)mhidSuffixGenerator {
    unsigned long randId = arc4random_uniform(10000000);
    
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitHour fromDate:date];
    unsigned long hour = [components hour];
    components = [calendar components:NSCalendarUnitMinute fromDate:date];
    unsigned long minute = [components minute];
    components = [calendar components:NSCalendarUnitSecond fromDate:date];
    unsigned long second = [components second];
    
    NSString *mhidSuffix = [NSString stringWithFormat:@"%lu%lu%lu%lu", hour, minute, second, randId];
    
    return mhidSuffix;
}

@end
