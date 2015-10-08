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
//  ATHit.m
//  Tracker
//


#import "ATHit.h"
#import "ATParam.h"


@implementation ATProcessedHitType

+ (NSDictionary *)list {
    static NSDictionary* list = nil;
    
    if (list == nil)
    {
        list = @{@"audio" : [NSNumber numberWithInt: ATHitTypeAudio],
                 @"video" : [NSNumber numberWithInt: ATHitTypeVideo],
                 @"vpre" : [NSNumber numberWithInt: ATHitTypeVideo],
                 @"vmid" : [NSNumber numberWithInt: ATHitTypeVideo],
                 @"vpost" : [NSNumber numberWithInt: ATHitTypeVideo],
                 @"animation" : [NSNumber numberWithInt: ATHitTypeAnimation],
                 @"anim" : [NSNumber numberWithInt: ATHitTypeAnimation],
                 @"podcast" : [NSNumber numberWithInt: ATHitTypePodCast],
                 @"rss" : [NSNumber numberWithInt: ATHitTypeRSS],
                 @"email" : [NSNumber numberWithInt: ATHitTypeEmail],
                 @"pub" : [NSNumber numberWithInt: ATHitTypeAdvertising],
                 @"ad" : [NSNumber numberWithInt: ATHitTypeAdvertising],
                 @"click" : [NSNumber numberWithInt: ATHitTypeTouch],
                 @"AT" : [NSNumber numberWithInt: ATHitTypeAdTracking],
                 @"pdt" : [NSNumber numberWithInt: ATHitTypeProductDisplay],
                 @"wbo" : [NSNumber numberWithInt: ATHitTypeWeborama],
                 @"mvt" : [NSNumber numberWithInt: ATHitTypeMVTesting],
                 @"screen" : [NSNumber numberWithInt: ATHitTypeScreen]};
        
        return list;
    }
    
    return list;
}
@end


@implementation ATHit
- (instancetype)init {
    return [self init:@""];
}

- (instancetype)init:(NSString *)url {
    if (self = [super init]) {
        self.url = url;
        self.creationDate = [NSDate date];
        self.retryCount = 0;
        self.offline = NO;
    }
    return self;
}

- (ATHitType)hitType {
    ATHitType hitType = ATHitTypeScreen;
    
    if(self.url) {
        NSURL* hitURL = [NSURL URLWithString:self.url];
        
        if(hitURL) {
            NSArray* urlComponents = [hitURL.query componentsSeparatedByString:@"&"];
            
            for(NSString* component in urlComponents) {
                NSArray* pairComponents = [component componentsSeparatedByString:@"="];
                
                if([pairComponents[0] isEqualToString:@"type"]) {
                    NSDictionary* hitTypeList = [ATProcessedHitType list];
                    NSNumber* hitTypeNumber = [hitTypeList objectForKey:(NSString *)pairComponents[1]];
                    
                    hitType = (ATHitType)[hitTypeNumber intValue];
                    break;
                }
                
                if([pairComponents[0] isEqualToString:@"clic"] || [pairComponents[0] isEqualToString:@"click"]) {
                    hitType = ATHitTypeTouch;
                }
            }
            
            return hitType;
        } else {
            return ATHitTypeUnknown;
        }
    }
    
    return ATHitTypeUnknown;
}

+ (ATHitType)hitType:(NSArray *)parameters, ... {

    ATHitType hitType = ATHitTypeScreen;
    
    for(ATParam *param in parameters) {
        if([param.key isEqualToString: @"clic"] || [param.key isEqualToString: @"click"] || ([param.key isEqualToString:@"type"] && [[ATProcessedHitType list] objectForKey:param.value()])) {
            if([param.key isEqualToString:@"type"]) {
                NSDictionary* hitTypeList = [ATProcessedHitType list];
                NSNumber* hitTypeNumber = [hitTypeList objectForKey:param.value()];
                
                hitType = (ATHitType)[hitTypeNumber intValue];
                break;
            }
            
            if([param.key isEqualToString:@"clic"] || [param.key isEqualToString:@"click"]) {
                hitType = ATHitTypeTouch;
            }
        }
    }
    
    return hitType;
}

@end
