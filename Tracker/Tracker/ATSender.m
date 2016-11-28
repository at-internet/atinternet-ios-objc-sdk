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
//  ATSender.m
//  Tracker
//


#import <UIKit/UIKit.h>

#import "ATSender.h"
#import "ATTracker.h"
#import "ATStorage.h"
#import "ATTechnicalContext.h"
#import "ATConfiguration.h"
#import "ATHit.h"
#import "ATTrackerQueue.h"
#import "ATDebugger.h"
#import "ATConfiguration.h"

#ifndef AT_EXTENSION
#import "ATBackgroundTask.h"
#endif

@interface ATSender()

/**
 Tracker instance
 */
@property (nonatomic, strong) ATTracker *tracker;

/**
 Retry count allowed
 */
@property (nonatomic) NSInteger retryCount;

/**
 Olt fixed value to use if multihits
 */
@property (nonatomic, strong) NSString *mhOlt;

/**
 Force offline hits to be sent (even if storage mode is set to always)
 */
@property (nonatomic) BOOL forceSendOfflineHits;

@end


@implementation ATSender

/**
 Hit is in processing state
 */
static BOOL processing = NO;

/**
 Hit sending result
 */
static BOOL sentWithSuccess = NO;

/**
 Initialize a sender
 @param tracker instance
 @param hit to send
 @param mh reference to use for sliced hit
 */
- (instancetype)initWithTracker:(ATTracker *)tracker hit:(ATHit *)hit forceSendOfflineHits:(BOOL)forceSendOfflineHits mhOlt:(NSString *)mhOlt {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
        self.hit = hit;
        self.forceSendOfflineHits = forceSendOfflineHits;
        self.mhOlt = mhOlt;
        self.retryCount = 3;
    }
    
    return self;
}

/**
 Main function of NSOperation
 */
- (void)main {
    @autoreleasepool {
        [self sendWithOfflineHits:NO];
    }
}

/**
 Sends hit with offline hits
 */
- (void)sendWithOfflineHits {
    [ATSender sendOfflineHits:self.tracker forceSendOfflineHits:NO async:NO];
    [self sendWithCompletionHandler:nil];
}

/**
 Sends hit
 
 @param with or without offline hit
 */
- (void)sendWithOfflineHits:(BOOL)includeOfflineHit {
    if (includeOfflineHit) {
        [ATSender sendOfflineHits:self.tracker forceSendOfflineHits:NO async:NO];
    }
    
    [self sendWithCompletionHandler:nil];
}

/**
 Sends hit and call a callback to indicate if the hit was sent successfully or not
 @param a callback to call
 */

- (void)sendWithCompletionHandler:(void (^)(BOOL))completionHandler {
    ATStorage *db = [ATStorage sharedInstanceOf:self.tracker.configuration.parameters[@"storage"]];
    
    // Si pas de connexion ou que le mode offline est à "always"
    if (([[self.tracker.configuration.parameters objectForKey:@"storage"] isEqualToString:@"always"] && self.forceSendOfflineHits == NO)
        || ([ATTechnicalContext connectionType] == ATConnectionTypeOffline)
        || (!self.hit.isOffline && [db count] > 0)) {
        
        // Si le mode offline n'est pas sur "never" (pas d'enregistrement)
        if (![[self.tracker.configuration.parameters objectForKey:@"storage"] isEqualToString:@"never"]) {
            
            // Si le hit ne provient pas du stockage offline, on le sauvegarde
            if (!self.hit.isOffline) {
                NSString *pURL = self.hit.url;
                //ATStorage *storage = [ATStorage sharedInstance];
                if ([db insertHit:&pURL mhOlt:self.mhOlt]) {
                    self.hit.url = pURL;
                    if (self.tracker.delegate) {
                        if ([self.tracker.delegate respondsToSelector:@selector(saveDidEnd:)]) {
                            [self.tracker.delegate saveDidEnd:self.hit.url];
                        }
                    }
                    
                    if([ATDebugger sharedInstance].viewController) {
                        [[ATDebugger sharedInstance] addEvent:self.hit.url icon:@"save48"];
                    }
                } else {
                    self.hit.url = pURL;
                    if (self.tracker.delegate) {
                        if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                            [self.tracker.delegate warningDidOccur:[NSString stringWithFormat:@"Hit could not be saved : %@", self.hit.url]];
                        }
                    }
                    
                    if([ATDebugger sharedInstance].viewController) {
                        [[ATDebugger sharedInstance] addEvent:[NSString stringWithFormat:@"Hit could not be saved : %@", self.hit.url] icon:@"warning48"];
                    }
                }
            }
            
        }
        
    } else {
        
        NSURL *url = [NSURL URLWithString:self.hit.url];
        
        if (url) {
            
            // Si l'opération n'a pas été annulée on envoie, sinon on sauvegarde le hit
            if (!self.cancelled) {
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                
                NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
                sessionConfig.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
                NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                        timeoutInterval:30];
                request.networkServiceType = NSURLNetworkServiceTypeBackground;
                
                NSURLSessionDataTask *task =
                [session dataTaskWithRequest:request
                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                               
                               NSInteger statusCode = 0;
                               
                               if (response) {
                                   statusCode = ((NSHTTPURLResponse *)response).statusCode;
                               }
                               
                               // Le hit n'a pas pu être envoyé
                               if (data == nil || error != nil || statusCode != 200) {
                                   // Si le hit ne provient pas du stockage offline,
                                   // on le sauvegarde si le mode offline est différent de "never"
                                   if (![[self.tracker.configuration.parameters objectForKey:@"storage"] isEqualToString:@"never"]) {
                                       if (!self.hit.isOffline) {
                                           NSString *pURL = self.hit.url;
                                           if ([db insertHit:&pURL mhOlt:self.mhOlt]) {
                                               self.hit.url = pURL;
                                               if (self.tracker.delegate) {
                                                   if ([self.tracker.delegate respondsToSelector:@selector(saveDidEnd:)]) {
                                                       [self.tracker.delegate saveDidEnd:self.hit.url];
                                                   }
                                               }
                                               
                                               if([ATDebugger sharedInstance].viewController) {
                                                   [[ATDebugger sharedInstance] addEvent:self.hit.url icon:@"save48"];
                                               }
                                           } else {
                                               self.hit.url = pURL;
                                               if (self.tracker.delegate) {
                                                   if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                                                       [self.tracker.delegate warningDidOccur:[NSString stringWithFormat:@"Hit could not be saved : %@", self.hit.url]];
                                                   }
                                               }
                                               
                                               if([ATDebugger sharedInstance].viewController) {
                                                   [[ATDebugger sharedInstance] addEvent:[NSString stringWithFormat:@"Hit could not be saved : %@", self.hit.url] icon:@"warning48"];
                                               }
                                           }
                                       } else {
                                           NSInteger retryCount = [db getRetryCountForHit:self.hit.url];
                                           if (retryCount < self.retryCount) {
                                               [db setRetryCount:retryCount+1 ForHit:self.hit.url];
                                           } else {
                                               [db delete:self.hit.url];
                                           }
                                       }
                                       
                                       NSString *errorMessage;
                                       if (error) {
                                           errorMessage = [[NSString alloc] initWithFormat:@"%@", [error description]];
                                       } else {
                                           errorMessage = [[NSString alloc] initWithFormat:@""];
                                       }
                                       
                                       // On lève une erreur indiquant qu'une réponse autre que 200 a été reçue
                                       if (self.tracker.delegate) {
                                           if ([self.tracker.delegate respondsToSelector:@selector(sendDidEnd:message:)]) {
                                               [self.tracker.delegate sendDidEnd:ATHitStatusFailed message:errorMessage];
                                           }
                                       }
                                       
                                       if([ATDebugger sharedInstance].viewController) {
                                           [[ATDebugger sharedInstance] addEvent:errorMessage icon:@"error48"];
                                       }
                                       
                                       if (completionHandler) {
                                           completionHandler(NO);
                                       }
                                   }
                               } else {
                                   // Si le hit provient du stockage et que l'envoi a réussi, on le supprime de la base
                                   if (self.hit.isOffline) {
                                       sentWithSuccess = YES;
                                       //ATStorage *storage = [ATStorage sharedInstance];
                                       [db delete:(self.hit.url)];
                                   }
                                   
                                   if (self.tracker.delegate) {
                                       if ([self.tracker.delegate respondsToSelector:@selector(sendDidEnd:message:)]) {
                                           [self.tracker.delegate sendDidEnd:ATHitStatusSuccess message:self.hit.url];
                                       }
                                   }
                                   
                                   if([ATDebugger sharedInstance].viewController) {
                                       [[ATDebugger sharedInstance] addEvent:self.hit.url icon:@"sent48"];
                                   }
                                   
                                   if (completionHandler) {
                                       completionHandler(YES);
                                   }
                               }
                               
                               [session finishTasksAndInvalidate];
                               
                               dispatch_semaphore_signal(semaphore);
                               
                           }];
                
                [task resume];
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                
            } else {
                if (!self.hit.isOffline) {
                    NSString *pURL = self.hit.url;
                    if ([db insertHit:&pURL mhOlt:self.mhOlt]) {
                        self.hit.url = pURL;
                        if (self.tracker.delegate) {
                            if ([self.tracker.delegate respondsToSelector:@selector(saveDidEnd:)]) {
                                [self.tracker.delegate saveDidEnd:self.hit.url];
                            }
                        }
                        
                        if([ATDebugger sharedInstance].viewController) {
                            [[ATDebugger sharedInstance] addEvent:self.hit.url icon:@"save48"];
                        }
                    } else {
                        self.hit.url = pURL;
                        if (self.tracker.delegate) {
                            if ([self.tracker.delegate respondsToSelector:@selector(warningDidOccur:)]) {
                                [self.tracker.delegate warningDidOccur:[NSString stringWithFormat:@"Hit could not be saved: %@", self.hit.url]];
                            }
                        }
                        
                        if([ATDebugger sharedInstance].viewController) {
                            [[ATDebugger sharedInstance] addEvent:[NSString stringWithFormat:@"Hit could not be saved : %@", self.hit.url] icon:@"warning48"];
                        }
                    }
                }
            }
            
        } else {
            
            // On lève une erreur indiquant que le hit n'a pas été correctement construit et n'a pas pu être envoyé
            if (self.tracker.delegate) {
                if ([self.tracker.delegate respondsToSelector:@selector(sendDidEnd:message:)]) {
                    [self.tracker.delegate sendDidEnd:ATHitStatusFailed message:@"Hit could not be parsed and sent"];
                }
            }
            
            if([ATDebugger sharedInstance].viewController) {
                [[ATDebugger sharedInstance] addEvent:[NSString stringWithFormat:@"Hit could not be parsed and sent : %@", self.hit.url] icon:@"error48"];
            }
            
            if (completionHandler) {
                completionHandler(NO);
            }
            
        }
        
    }
}

+ (void)sendOfflineHits:(ATTracker *)tracker forceSendOfflineHits:(BOOL)forceSendOfflineHits {
    [ATSender sendOfflineHits:tracker forceSendOfflineHits:forceSendOfflineHits async:YES];
}

+ (void)sendOfflineHits:(ATTracker *)tracker forceSendOfflineHits:(BOOL)forceSendOfflineHits async:(BOOL)async {
    
    if ((![[tracker.configuration.parameters objectForKey:@"storage"] isEqualToString:@"always"] || forceSendOfflineHits)
        && ([ATTechnicalContext connectionType] != ATConnectionTypeOffline)) {
        
        
        if (!processing) {
            // Check wether offline hits are already being sent
            NSArray *offlineOperations = [[[ATTrackerQueue sharedInstance] queue] operations];
            
            BOOL isOfflinePending = NO;
            
            for (NSOperation *operation in offlineOperations) {
                
                if ([operation isKindOfClass:[ATSender class]]) {
                    
                    ATSender *sender = (ATSender *)operation;
                    if (sender.hit.isOffline == YES) {
                        isOfflinePending = YES;
                        break;
                    }
                }
                
            }
            
            if (!isOfflinePending) {
                
                // If there's no offline hit being sent
                
                ATStorage *storage = [ATStorage sharedInstanceOf:tracker.configuration.parameters[@"storage"]];
                
                // Check if offline hits exists in database
                if ([storage count] > 0) {
                    
#ifndef AT_EXTENSION
                    // Creates background task for offline hits
                    if ([[UIDevice currentDevice] isMultitaskingSupported]
                        && [[[tracker.configuration.parameters objectForKey:@"enableBackgroundTask"] lowercaseString] isEqualToString:@"true"]) {
                        [[ATBackgroundTask sharedInstance] begin];
                    }
#endif
                    
                    if (async) {
                        for (ATHit *offlineHit in [storage hits]) {
                            ATSender *sender = [[ATSender alloc] initWithTracker:tracker hit:offlineHit forceSendOfflineHits:forceSendOfflineHits mhOlt:nil];
                            [[[ATTrackerQueue sharedInstance] queue] addOperation:sender];
                        }
                    } else {
                        processing = YES;
                        
                        for (ATHit *offlineHit in [storage hits]) {
                            sentWithSuccess = NO;
                            ATSender *sender = [[ATSender alloc] initWithTracker:tracker hit:offlineHit forceSendOfflineHits:forceSendOfflineHits mhOlt:nil];
                            [sender sendWithOfflineHits:NO];
                            
                            if (!sentWithSuccess) {
                                break;
                            }
                        }
                        
                        processing = NO;
                    }
                    
                }
                
            }
            
        }
        
    }
    
}

@end
