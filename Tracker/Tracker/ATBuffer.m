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
//  ATBuffer.m
//  Tracker
//


#import "ATBuffer.h"
#import "ATParam.h"
#import "ATParamOption.h"
#import "ATTechnicalContext.h"
#import "ATTool.h"
#import "ATTracker.h"
#import "ATConfiguration.h"


@implementation ATBuffer

- (instancetype)initWithTracker:(ATTracker *) tracker {
    if (self = [super init]) {
        self.tracker = tracker;
        self.persistentParameters = [[NSMutableArray alloc] init];
        self.volatileParameters = [[NSMutableArray alloc] init];
        
        [self addContextVariables];
    }
    return self;
}

- (void) addContextVariables {
    ATParamOption *persistentOption = [[ATParamOption alloc] init];
    persistentOption.persistent = YES;
    
    ATParamOption *persistentOptionWithEncoding = [[ATParamOption alloc] init];
    persistentOptionWithEncoding.persistent = YES;
    persistentOptionWithEncoding.encode = YES;
    
    
    // Add sdk version
    NSString *sdkVersion = [ATTechnicalContext sdkVersion];
    [self.persistentParameters addObject:[[ATParam alloc] init:@"vtag" value:^NSString* () {return sdkVersion;} type:ATParamTypeString options:persistentOption]];
    // Add Platform type
    [self.persistentParameters addObject:[[ATParam alloc] init:@"ptag" value:^NSString* () {return @"ios";} type:ATParamTypeString options:persistentOption]];
    // Add device language
    [self.persistentParameters addObject:[[ATParam alloc] init:@"lng" value:^NSString* () {return [ATTechnicalContext language];} type:ATParamTypeString options:persistentOption]];
    // Add device information
    NSString *device = [ATTechnicalContext device];
    [self.persistentParameters addObject:[[ATParam alloc] init:@"mfmd" value:^NSString* () {return device;} type:ATParamTypeString options:persistentOption]];
    // Add OS Information
    NSString *operatingSystem = [ATTechnicalContext operatingSystem];
    [self.persistentParameters addObject:[[ATParam alloc]init:@"os" value:^NSString* () {return operatingSystem;} type:ATParamTypeString options:persistentOption]];
    // Add application identifier
    NSString *applicationIdentifier = [ATTechnicalContext applicationIdentifier];
    [self.persistentParameters addObject:[[ATParam alloc]init:@"apid" value:^NSString* () {return applicationIdentifier;} type:ATParamTypeString options:persistentOption]];
    // Add application version
    NSString *applicationVersion = [ATTechnicalContext applicationVersion];
    [self.persistentParameters addObject:[[ATParam alloc]init:@"apvr" value:^NSString* () {return applicationVersion;} type:ATParamTypeString options:persistentOptionWithEncoding]];
    // Add local hour
    [self.persistentParameters addObject:[[ATParam alloc]init:@"hl" value:^NSString* () {return [ATTechnicalContext localHour];} type:ATParamTypeString options:persistentOption]];
    // Add screen resolution
    [self.persistentParameters addObject:[[ATParam alloc]init:@"r" value:^NSString* () {return [ATTechnicalContext screenResolution];} type:ATParamTypeString options:persistentOption]];
    // Add carrier
    [self.persistentParameters addObject:[[ATParam alloc]init:@"car" value:^NSString* () {return [ATTechnicalContext carrier];} type:ATParamTypeString options:persistentOptionWithEncoding]];
    // Add connection information
    [self.persistentParameters addObject:[[ATParam alloc]init:@"cn" value:^NSString* () {return [ATTool convertConnectionTypeToString:[ATTechnicalContext connectionType]];} type:ATParamTypeString options:persistentOptionWithEncoding]];
    // Add time stamp for cache
    [self.persistentParameters addObject:[[ATParam alloc]init:@"ts" value:^NSString* () {return [NSString stringWithFormat:@"%f",[[NSDate alloc]init].timeIntervalSince1970];} type:ATParamTypeString options:persistentOption]];
    // Add download source
    [self.persistentParameters addObject:[[ATParam alloc]init:@"dls" value:^NSString* () {return [ATTechnicalContext downloadSource:self.tracker];} type:ATParamTypeString options:persistentOption]];
    // Add userId
    [self.persistentParameters addObject:[[ATParam alloc]init:@"idclient" value:^NSString* () {return [ATTechnicalContext userId:[self.tracker.configuration.parameters objectForKey:@"identifier"]];} type:ATParamTypeString options:persistentOption]];
    
}

@end
