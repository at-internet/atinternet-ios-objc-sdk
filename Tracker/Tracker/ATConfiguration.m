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
//  ATConfiguration.m
//  Tracker
//


#import "ATConfiguration.h"
#import "ATTool.h"


@implementation ATReadOnlyConfiguration

+ (NSSet *)list {
    static NSSet* list = nil;
    
    if (list == nil)
    {
        list = [NSSet setWithArray:@[@"atreadonlytest"]];
        
        return list;
    }
    
    return list;
}

@end


@implementation ATConfiguration

- (instancetype)init {
    if (self = [super init]) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ATAssets" ofType:@"bundle"];
        self.parameters = [[NSMutableDictionary alloc] init];
        
        if(!bundlePath){
            bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ATAssets" ofType:@"bundle"];
        }
        
        NSBundle* bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *path = [bundle pathForResource:@"ATDefaultConfiguration" ofType:@"plist"];
        
        if (path) {
            NSMutableDictionary *defaultConf = [NSMutableDictionary dictionaryWithContentsOfFile:path];
            if (defaultConf) {
                self.parameters = defaultConf;
            }
        }
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSMutableDictionary *)configuration {
    self = [self init];
    if (configuration) {
        for (NSString* key in configuration.allKeys) {
            [self.parameters setObject:[configuration objectForKey:key] forKey:key];
        }
    }
    return self;
}

@end
