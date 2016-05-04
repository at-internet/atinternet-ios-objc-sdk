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
//  ATStorage.m
//  Tracker
//


#import "ATStorage.h"
#import "ATHit.h"
#import "ATTool.h"


@interface ATStorage()

- (NSString *)buildHitToStore:(NSString *)hit olt:(NSString *)olt;

@end

@implementation ATStorage

@synthesize databaseDirectory = _databaseDirectory;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectContext = _managedObjectContext;

NSString* entityName = @"ATStoredOfflineHit";

+ (id) sharedInstance {
    static ATStorage *sharedStorage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStorage = [[self alloc] init];
    });
    return sharedStorage;
}

-(id)init {
    self = [super init];
    return self;
}

- (NSURL *)databaseDirectory {
    if(!_databaseDirectory) {
        NSArray* urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains: NSUserDomainMask];
        
        _databaseDirectory = urls[[urls count] - 1];
    }
    
    return _databaseDirectory;
}

- (NSManagedObjectModel *)managedObjectModel {
    if(!_managedObjectModel) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ATAssets" ofType:@"bundle"];
        
        if(!bundlePath){
            bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ATAssets" ofType:@"bundle"];
        }
        
        NSBundle* bundle = [NSBundle bundleWithPath:bundlePath];
        if(bundle) {
            NSString* modelPath = [bundle pathForResource:@"ATTracker" ofType:@"momd"];
            NSURL* modelURL = [NSURL fileURLWithPath:modelPath];
            
            _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
        } else {
            _managedObjectModel = nil;
        }
    }
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if(!_persistentStoreCoordinator) {
        NSPersistentStoreCoordinator* coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        NSURL* url = self.databaseDirectory;
        
        NSError *error;
        if (! [[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"%@", error);
        }
        NSURL* sqliteURL = [url URLByAppendingPathComponent:@"Tracker.sqlite"];
        
        if(coordinator) {
            if([coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sqliteURL options:kNilOptions error:nil] == nil) {
                _persistentStoreCoordinator = nil;
            } else {
                _persistentStoreCoordinator = coordinator;
            }
        } else {
            _persistentStoreCoordinator = nil;
        }
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    if(!_managedObjectContext) {
        NSPersistentStoreCoordinator* coordinator = self.persistentStoreCoordinator;
        
        if(!coordinator) {
            _managedObjectContext = nil;
        }
        
        NSManagedObjectContext* managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        managedObjectContext.persistentStoreCoordinator = coordinator;
        _managedObjectContext = managedObjectContext;
    }
    
    return _managedObjectContext;
}

- (BOOL)saveContext {
    if(self.managedObjectContext) {
        __block BOOL done;
        [self.managedObjectContext performBlockAndWait:^{
            if(self.managedObjectContext.hasChanges){
                done = [self.managedObjectContext save:nil];
            } else {
                done = NO;
            }
        }];
        
        return done;
    } else {
        return NO;
    }
}

- (BOOL)insertHit:(NSString **)hit mhOlt:(NSString *)mhOlt {
    if(self.managedObjectContext) {
        NSDate* now = [NSDate date];
        NSString* olt;
        
        if(mhOlt) {
            olt = mhOlt;
        } else {
            olt = [[NSString alloc] initWithFormat:@"%f", now.timeIntervalSince1970];
        }
        
        *hit = [self buildHitToStore:*hit olt:olt];
        
        if([self exists:*hit] == NO) {
            [self.managedObjectContext performBlockAndWait:^{
                ATStoredOfflineHit* managedHit = (ATStoredOfflineHit *)[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
                managedHit.hit = *hit;
                managedHit.date = now;
                managedHit.retry = 0;
            }];
            
            return [self saveContext];
        } else {
            return YES;
        }
    }
    
    return NO;
}

- (NSArray *)hits {
    NSMutableArray* hits = [[NSMutableArray alloc] init];
    
    if(self.managedObjectContext) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
        
        [self.managedObjectContext performBlockAndWait:^{
            NSArray* storedHits = [self.managedObjectContext executeFetchRequest:request error:nil];
            
            if(storedHits) {
                for(ATStoredOfflineHit *storedHit in storedHits) {
                    ATHit* hit = [[ATHit alloc] init];
                    hit.url = storedHit.hit;
                    hit.creationDate = storedHit.date;
                    hit.retryCount = storedHit.retry;
                    hit.offline = YES;
                    
                    [hits addObject:hit];
                }
            }
        }];
        return hits;
        
    }
    
    return hits;
}

- (ATHit *)hit:(NSString *)hit {
    if(self.managedObjectContext) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
        NSPredicate* filter = [NSPredicate predicateWithFormat:@"hit == %@", hit];
        request.predicate = filter;
        __block ATHit* hit;
        
        [self.managedObjectContext performBlockAndWait:^{
            NSArray* storedHits = [self.managedObjectContext executeFetchRequest:request error:nil];
            
            if(storedHits) {
                if([storedHits count] > 0) {
                    ATStoredOfflineHit* storedHit = (ATStoredOfflineHit *) storedHits[0];
                    
                    hit = [[ATHit alloc] init];
                    hit.url = storedHit.hit;
                    hit.creationDate = storedHit.date;
                    hit.retryCount = storedHit.retry;
                    hit.offline = YES;
                }
            }
        }];
        
        return hit;
        
    }
    
    return nil;
}

- (NSArray *)storedHits {
    if(self.managedObjectContext) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
        
        __block NSArray* hits = [[NSArray alloc] init];
        [self.managedObjectContext performBlockAndWait:^{
            NSArray* storedHits = [self.managedObjectContext executeFetchRequest:request error:nil];
            
            if(storedHits) {
                hits = storedHits;
            }
        }];
        return hits;
        
    }
    
    return [[NSArray alloc] init];
}

- (NSManagedObjectID *)storedHit:(NSString *)hit {
    __block ATStoredOfflineHit *storedHit;
    __block NSArray* storedHits;
    if(self.managedObjectContext) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
        [self.managedObjectContext performBlockAndWait:^{
            NSPredicate* filter = [NSPredicate predicateWithFormat:@"hit == %@", hit];
            request.predicate = filter;
            storedHits = [self.managedObjectContext executeFetchRequest:request error:nil];
        }];
        if(storedHits) {
            if([storedHits count] > 0) {
                storedHit = (ATStoredOfflineHit *)storedHits[0];
                return storedHit.objectID;
            }
        }
    }
    
    return nil;
}


- (void)setRetryCount:(NSInteger)count forOfflineHit:(NSManagedObjectID *)oid; {
    if(self.managedObjectContext) {
        [self.managedObjectContext performBlockAndWait:^{
            ATStoredOfflineHit *hit = [self.managedObjectContext objectWithID:oid];
            hit.retry = [NSNumber numberWithInteger:count];
            [self.managedObjectContext save:nil];
        }];
    }
}

- (NSInteger)getRetryCountForHit:(NSString *)hit; {
    NSManagedObjectID *offlineHitID = [self storedHit:hit];
    return [self getRetryCount:offlineHitID];
}
- (void)setRetryCount:(NSInteger)retryCount ForHit:(NSString *)hit {
    NSManagedObjectID *offlineHitID = [self storedHit:hit];
    [self setRetryCount:retryCount forOfflineHit:offlineHitID];
}

- (NSInteger) getRetryCount:(NSManagedObjectID *)oid {
    __block NSInteger retry = -1;
    if(self.managedObjectContext) {
        [self.managedObjectContext performBlockAndWait:^{
            ATStoredOfflineHit *hit = [self.managedObjectContext objectWithID:oid];
            retry = hit.retry.integerValue;
        }];
    }
    return retry;
}

- (NSInteger)count {
    if(self.managedObjectContext) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
        request.includesSubentities = NO;
        request.includesPropertyValues = NO;
        
        __block NSInteger result = -1;
        [self.managedObjectContext performBlockAndWait:^{
            NSInteger count = [self.managedObjectContext countForFetchRequest:request error:nil];
            
            if(count == NSNotFound) {
                result = 0;
            } else {
                result = count;
            }
        }];
        
        return result;
    }
    
    return 0;
}

- (BOOL)exists:(NSString *)hit {
    if(self.managedObjectContext) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
        request.includesSubentities = NO;
        request.includesPropertyValues = NO;
        
        __block BOOL exists;
        [self.managedObjectContext performBlockAndWait:^{
            NSPredicate* filter = [NSPredicate predicateWithFormat:@"hit == %@", hit];
            request.predicate = filter;
            
            NSInteger count = [self.managedObjectContext countForFetchRequest:request error:nil];
            exists = (count > 0);
        }];
        return exists;
    }
    
    return NO;
}

- (NSInteger)deleteAll {
    if(self.managedObjectContext) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
        request.includesSubentities = NO;
        request.includesPropertyValues = NO;
        
        __block NSInteger result = -2;
        [self.managedObjectContext performBlockAndWait:^{
            NSArray* storedHits = [self.managedObjectContext executeFetchRequest:request error:nil];
            
            if(storedHits) {
                for(ATStoredOfflineHit* storedHit in storedHits) {
                    [self.managedObjectContext deleteObject:storedHit];
                }
                
                if([self.managedObjectContext save:nil]) {
                    result = [storedHits count];
                } else {
                    result = -1;
                }
            } else {
                result = 0;
            }
        }];
        return result;
        
    }
    
    return -1;
}

- (NSInteger)deleteFromDate:(NSDate *)olderThan {
    if(self.managedObjectContext) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
        request.includesSubentities = NO;
        request.includesPropertyValues = NO;
        
        NSPredicate* filter = [NSPredicate predicateWithFormat:@"date < %@", olderThan];
        request.predicate = filter;
        
        __block NSInteger result = -2;
        [self.managedObjectContext performBlockAndWait:^{
            NSArray* storedHits = [self.managedObjectContext executeFetchRequest:request error:nil];
            
            if(storedHits) {
                for(ATStoredOfflineHit* storedHit in storedHits) {
                    [self.managedObjectContext deleteObject:storedHit];
                }
                
                if([self.managedObjectContext save:nil]) {
                    result = [storedHits count];
                } else {
                    result = -1;
                }
            } else {
                result = 0;
            }
        }];
        return result;
        
    }
    
    return -1;
}

- (BOOL)delete:(NSString *)hit {
    if(self.managedObjectContext) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
        request.includesSubentities = NO;
        request.includesPropertyValues = NO;
        
        NSPredicate* filter = [NSPredicate predicateWithFormat:@"hit == %@", hit];
        request.predicate = filter;
        __block BOOL done;
        [self.managedObjectContext performBlockAndWait:^{
            NSArray* storedHits = [self.managedObjectContext executeFetchRequest:request error:nil];
            
            if(storedHits) {
                for(ATStoredOfflineHit* storedHit in storedHits) {
                    [self.managedObjectContext deleteObject:storedHit];
                    
                    done = [self.managedObjectContext save:nil];
                }
            } else {
                done = NO;
            }
        }];
        return done;
    }
    
    return NO;
}

- (ATHit *)first {
    if(self.managedObjectContext) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
        NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        
        request.sortDescriptors = @[sortDescriptor];
        request.fetchLimit = 1;
        
        __block ATHit* hit;
        [self.managedObjectContext performBlockAndWait:^{
            NSArray* storedHits = [self.managedObjectContext executeFetchRequest:request error:nil];
            
            if(storedHits) {
                if([storedHits count] > 0) {
                    ATStoredOfflineHit* storedHit = (ATStoredOfflineHit *) storedHits[0];
                    
                    ATHit* h = [[ATHit alloc] init];
                    h.url = storedHit.hit;
                    h.creationDate = storedHit.date;
                    h.retryCount = storedHit.retry;
                    h.offline = YES;
                    
                    hit = h;
                }
            }
        }];
        return hit;
    }
    
    return nil;
}

- (ATHit *)last {
    if(self.managedObjectContext) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
        NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        
        request.sortDescriptors = @[sortDescriptor];
        request.fetchLimit = 1;
        __block ATHit *hit;
        [self.managedObjectContext performBlockAndWait:^{
            NSArray* storedHits = [self.managedObjectContext executeFetchRequest:request error:nil];
            
            if(storedHits) {
                if([storedHits count] > 0) {
                    ATStoredOfflineHit* storedHit = (ATStoredOfflineHit *) storedHits[0];
                    
                    ATHit* h = [[ATHit alloc] init];
                    h.url = storedHit.hit;
                    h.creationDate = storedHit.date;
                    h.retryCount = storedHit.retry;
                    h.offline = YES;
                    
                    hit = h;
                }
            }
        }];
        return hit;
    }
    
    return nil;
    
}

- (NSString *)buildHitToStore:(NSString *)hit olt:(NSString *)olt {
    NSURL* url = [[NSURL alloc] initWithString:hit];
    
    if(url) {
        NSArray* urlComponents = [url.query componentsSeparatedByString:@"&"];
        
        NSURLComponents *components = [[NSURLComponents alloc] init];
        components.scheme = url.scheme;
        components.host = url.host;
        components.path = url.path;
        
        NSString* query = @"";
        
        BOOL oltAdded = NO;
        
        int i = 0;
        for(NSString* component in urlComponents) {
            NSArray* pairComponents = [component componentsSeparatedByString:@"="];
            
            if([pairComponents[0] isEqualToString:@"cn"]) {
                query = [query stringByAppendingString:@"&cn=offline"];
            } else {
                (i > 0) ? (query = [[query stringByAppendingString:@"&"] stringByAppendingString:component]) :(query = [query stringByAppendingString:component]);
            }
            
            if(!oltAdded) {
                if([pairComponents[0] isEqualToString:@"ts"] || [pairComponents[0] isEqualToString:@"mh"]) {
                    query = [[query stringByAppendingString:@"&olt="] stringByAppendingString:olt];
                    oltAdded = YES;
                }
            }
            
            i++;
        }
        
        components.percentEncodedQuery = query;
        
        if(components.URL) {
            return components.URL.absoluteString;
        } else {
            return hit;
        }
    }
    return hit;
}

@end

@implementation ATStoredOfflineHit

@dynamic date;
@dynamic hit;
@dynamic retry;

@end
