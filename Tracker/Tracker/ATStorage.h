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
//  ATStorage.h
//  Tracker
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ATHit;


@interface ATStoredOfflineHit : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * hit;
@property (nonatomic, retain) NSNumber * retry;

@end

@protocol ATStorageProtocol

- (BOOL)insertHit:(NSString **)hit mhOlt:(NSString *)mhOlt;
- (NSArray *)hits;
- (ATHit *)hit:(NSString *)hit;
- (NSArray *)storedHits;
- (NSInteger)count;
- (BOOL)exists:(NSString *)hit;
- (NSInteger)deleteAll;
- (NSInteger)deleteFromDate:(NSDate *)olderThan;
- (BOOL)delete:(NSString *)hit;
- (ATHit *)first;
- (ATHit *)last;
- (NSInteger)getRetryCountForHit:(NSString *)hit;
- (void)setRetryCount:(NSInteger)retryCount ForHit:(NSString *)hit;

@end

@interface ATStorage : NSObject <ATStorageProtocol>

@property (nonatomic, strong, readonly) NSURL* databaseDirectory;
@property (nonatomic, strong, readonly) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectContext* managedObjectContext;

- (id)init __unavailable;
- (BOOL)saveContext;
- (BOOL)insertHit:(NSString **)hit mhOlt:(NSString *)mhOlt;
- (NSArray *)hits;
- (ATHit *)hit:(NSString *)hit;
- (NSArray *)storedHits;
//- (NSManagedObjectID *)storedHit:(NSString *)hit;
- (NSInteger)count;
- (BOOL)exists:(NSString *)hit;
- (NSInteger)deleteAll;
- (NSInteger)deleteFromDate:(NSDate *)olderThan;
- (BOOL)delete:(NSString *)hit;
- (ATHit *)first;
- (ATHit *)last;

- (NSInteger)getRetryCountForHit:(NSString *)hit;
- (void)setRetryCount:(NSInteger)retryCount ForHit:(NSString *)hit;

+ (id)sharedInstanceOf:(NSString *)type;

@end

@interface ATNilStorage : NSObject <ATStorageProtocol>
@end
