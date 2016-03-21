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
//  ATDefaultTrackerDelegate.m
//  Tracker
//
//  Created by Nicolas Sagnette on 15/03/2016.
//  Copyright © 2016 AT Internet. All rights reserved.
//

#import "ATDefaultTrackerDelegate.h"

@implementation ATDefaultTrackerDelegate

- (void)trackerNeedsFirstLaunchApproval:(NSString *)message {
    NSLog(@"%@",[NSString stringWithFormat:@"ATINTERNET Debugging message:\n\tEvent: First Launch\n\tMessage: %@", message]);
}

- (void)buildDidEnd:(ATHitStatus)status message:(NSString *)message {
    NSString* statusStr = status == 1 ? @"Success" : @"Failed";
     NSLog(@"%@",[NSString stringWithFormat:@"ATINTERNET Debugging message:\n\tEvent: Building Hit\n\tStatus: %@\n\tMessage: %@", statusStr, message]);
}

- (void)sendDidEnd:(ATHitStatus)status message:(NSString *)message {
    NSString* statusStr = status == 1 ? @"Success" : @"Failed";
     NSLog(@"%@",[NSString stringWithFormat:@"ATINTERNET Debugging message:\n\tEvent: Sending Hit\n\tStatus: %@\n\tMessage: %@", statusStr, message]);
}

- (void)saveDidEnd:(NSString *)message {
    NSLog(@"%@",[NSString stringWithFormat:@"ATINTERNET Debugging message:\n\tEvent: Saving Hit\n\tMessage: %@", message]);
}

- (void)didCallPartner:(NSString *)response {
     NSLog(@"%@",[NSString stringWithFormat:@"ATINTERNET Debugging message:\n\tEvent: Calling Partner\n\tMessage: %@", response]);
}

- (void)warningDidOccur:(NSString *)message {
     NSLog(@"%@",[NSString stringWithFormat:@"ATINTERNET Debugging message:\n\tEvent: Warning\n\tMessage: %@", message]);
}

- (void)errorDidOccur:(NSString *)message {
     NSLog(@"%@",[NSString stringWithFormat:@"ATINTERNET Debugging message:\n\tEvent: Error\n\tMessage: %@", message]);
}

@end
