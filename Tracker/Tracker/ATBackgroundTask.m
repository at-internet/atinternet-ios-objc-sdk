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
//  ATBackgroundTask.m
//  Tracker
//


#import <UIKit/UIKit.h>

#import "ATBackgroundTask.h"
#import "ATTrackerQueue.h"
#import "ATSender.h"
#import "ATHit.h"


@interface ATBackgroundTask()

typedef void (^CompletionBlock)();

@property (nonatomic, copy) CompletionBlock completionBlock;
@property (nonatomic) int taskCounter;
@property (nonatomic, strong) NSMutableDictionary *tasks;
@property (nonatomic, strong) NSMutableDictionary *tasksCompletionBlocks;

@end

@implementation ATBackgroundTask

+ (id)sharedInstance {
    static ATBackgroundTask *sharedBackgroundTask = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBackgroundTask = [[self alloc] init];
    });
    return sharedBackgroundTask;
}

- (id)init {
    if (self = [super init]) {
        self.taskCounter = 0;
        self.tasks = [[NSMutableDictionary alloc] init];
        self.tasksCompletionBlocks = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSInteger) begin {
    return [self beginTaskWithCompletionHandler:nil];
}

- (NSUInteger)beginTaskWithCompletionHandler:(CompletionBlock)_completion;
{
    //read the counter and increment it
    NSUInteger taskKey;
    @synchronized(self) {
        
        taskKey = self.taskCounter;
        self.taskCounter++;
        
    }
    
    //tell the OS to start a task that should continue in the background if needed
    NSUInteger taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endTaskWithKey:taskKey];
    }];
    
    //add this task identifier to the active task dictionary
    [self.tasks setObject:[NSNumber numberWithUnsignedLong:taskId] forKey:[NSNumber numberWithUnsignedLong:taskKey]];
    
    //store the completion block (if any)
    if (_completion) [self.tasksCompletionBlocks setObject:_completion forKey:[NSNumber numberWithUnsignedLong:taskKey]];
    
    //return the dictionary key
    return taskKey;
}

- (void)endTaskWithKey:(NSUInteger)_key
{
    @synchronized(self.tasksCompletionBlocks) {
        
        //see if this task has a completion block
        CompletionBlock completion = [self.tasksCompletionBlocks objectForKey:[NSNumber numberWithUnsignedLong:_key]];
        if (completion) {
            
            //run the completion block and remove it from the completion block dictionary
            completion();
            [self.tasksCompletionBlocks removeObjectForKey:[NSNumber numberWithUnsignedLong:_key]];
            
        }
        
    }
    
    @synchronized(self.tasks) {
        
        //see if this task has been ended yet
        NSNumber *taskId = [self.tasks objectForKey:[NSNumber numberWithUnsignedLong:_key]];
        if (taskId) {
            
            for (NSOperation *operation in [ATTrackerQueue sharedInstance].queue.operations) {
                if([operation isKindOfClass:[ATSender class]]){
                    ATSender *sender = (ATSender *) operation;
                    if(sender.executing && sender.hit.isOffline){
                        [sender cancel];
                    }
                }
            }
            
            //end the task and remove it from the active task dictionary
            [[UIApplication sharedApplication] endBackgroundTask:[taskId unsignedLongValue]];
            [self.tasks removeObjectForKey:[NSNumber numberWithUnsignedLong:_key]];
            
        }
        
    }
}

@end
