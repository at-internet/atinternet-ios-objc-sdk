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
//  ATProduct.m
//  Tracker
//

#import "ATProduct.h"
#import "ATTracker.h"
#import "ATParamOption.h"
#import "ATDispatcher.h"
#import "ATCart.h"

@implementation ATProduct

- (instancetype)initWithTracker:(ATTracker *)tracker {
    
    if (self = [super initWithTracker:tracker]) {
        self.productId = [[NSString alloc] init];
        self.quantity = -1;
        self.unitPriceTaxFree = -1;
        self.unitPriceTaxIncluded = -1;
        self.discountTaxFree = -1;
        self.discountTaxIncluded = 1;
        self.action = ATProductActionView;
    }
    
    return self;
    
}

- (void)setEvent {
    [self.tracker setStringParam:@"type" value:@"pdt"];
    
    ATParamOption *opt = [[ATParamOption alloc] init];
    opt.append = YES;
    opt.encode = YES;
    opt.separator = @"|";
    
    [self.tracker setStringParam:@"pdtl" value:[self buildProductName] options:opt];
}

- (void)sendView {
    self.action = ATProductActionView;
    [self.tracker.dispatcher dispatch:@[self]];
}

- (NSString *)buildProductName {
    NSString *productName = !self.category1 ? @"" : [self.category1 stringByAppendingString:@"::"];
    productName = !self.category2 ? productName : [[productName stringByAppendingString:self.category2] stringByAppendingString:@"::"];
    productName = !self.category3 ? productName : [[productName stringByAppendingString:self.category3] stringByAppendingString:@"::"];
    productName = !self.category4 ? productName : [[productName stringByAppendingString:self.category4] stringByAppendingString:@"::"];
    productName = !self.category5 ? productName : [[productName stringByAppendingString:self.category5] stringByAppendingString:@"::"];
    productName = !self.category6 ? productName : [[productName stringByAppendingString:self.category6] stringByAppendingString:@"::"];
    productName = [productName stringByAppendingString:self.productId];
    
    return productName;
}

@end


@interface ATProducts()

@property (nonatomic, strong) ATCart *cart;
@property (nonatomic, strong) ATTracker *tracker;

@end

@implementation ATProducts

- (instancetype)initWithCart:(ATCart *)cart {
    self = [super init];
    
    if (self) {
        self.cart = cart;
    }
    
    return self;
}

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
    }
    
    return self;
}

- (ATProduct *)addWithId:(NSString *)productId {
    
    ATProduct *product;
    
    if (self.cart) {
        
        product = [[ATProduct alloc] initWithTracker:self.cart.tracker];
        product.productId = productId;
        [self.cart.productList setObject:product forKey:productId];
        
    } else {
        
        product = [[ATProduct alloc] initWithTracker:self.tracker];
        product.productId = productId;
        [self.tracker.businessObjects setObject:product forKey:product._id];
        
    }
    
    return product;
    
}

- (ATProduct *)addWithProduct:(ATProduct *)product {
    
    if (self.cart) {
        [self.cart.productList setObject:product forKey:product.productId];
    } else {
        [self.tracker.businessObjects setObject:product forKey:product._id];
    }
    
    return product;
    
}

- (ATProduct *)addWithId:(NSString *)productId
               category1:(NSString *)category1 {
    
    ATProduct *pdt = [self addWithId:productId];
    pdt.category1 = category1;
    return pdt;
    
}

- (ATProduct *)addWithId:(NSString *)productId
               category1:(NSString *)category1
               category2:(NSString *)category2 {
    
    ATProduct *pdt = [self addWithId:productId];
    pdt.category1 = category1;
    pdt.category2 = category2;
    return pdt;
    
}

- (ATProduct *)addWithId:(NSString *)productId
               category1:(NSString *)category1
               category2:(NSString *)category2
               category3:(NSString *)category3 {
    
    ATProduct *pdt = [self addWithId:productId];
    pdt.category1 = category1;
    pdt.category2 = category2;
    pdt.category3 = category3;
    return pdt;
    
}

- (ATProduct *)addWithId:(NSString *)productId
               category1:(NSString *)category1
               category2:(NSString *)category2
               category3:(NSString *)category3
               category4:(NSString *)category4 {
    
    ATProduct *pdt = [self addWithId:productId];
    pdt.category1 = category1;
    pdt.category2 = category2;
    pdt.category3 = category3;
    pdt.category4 = category4;
    return pdt;
    
}

- (ATProduct *)addWithId:(NSString *)productId
               category1:(NSString *)category1
               category2:(NSString *)category2
               category3:(NSString *)category3
               category4:(NSString *)category4
               category5:(NSString *)category5 {
    
    ATProduct *pdt = [self addWithId:productId];
    pdt.category1 = category1;
    pdt.category2 = category2;
    pdt.category3 = category3;
    pdt.category4 = category4;
    pdt.category5 = category5;
    return pdt;
    
}

- (ATProduct *)addWithId:(NSString *)productId
               category1:(NSString *)category1
               category2:(NSString *)category2
               category3:(NSString *)category3
               category4:(NSString *)category4
               category5:(NSString *)category5
               category6:(NSString *)category6 {
    
    ATProduct *pdt = [self addWithId:productId];
    pdt.category1 = category1;
    pdt.category2 = category2;
    pdt.category3 = category3;
    pdt.category4 = category4;
    pdt.category5 = category5;
    pdt.category6 = category6;
    return pdt;
    
}

- (void)removeWithId:(NSString *)productId {
    
    if (self.cart) {
        
        [self.cart.productList removeObjectForKey:productId];
        
    } else {
        
        for (ATBusinessObject *businessObject in self.tracker.businessObjects.allValues) {
            if ([businessObject isKindOfClass:[ATProduct class]] && ((ATProduct *)businessObject).productId == productId) {
                [self.tracker.businessObjects removeObjectForKey:businessObject._id];
                break;
            }
        }
        
    }

}

- (void)removeAll {
    
    if (self.cart) {
        
        [self.cart.productList removeAllObjects];
        
    } else {
        
        for (ATBusinessObject *businessObject in self.tracker.businessObjects.allValues) {
            if ([businessObject isKindOfClass:[ATProduct class]]) {
                [self.tracker.businessObjects removeObjectForKey:businessObject._id];
            }
        }
        
    }
    
}

- (void)sendViews {
    
    NSMutableArray *impressions = [[NSMutableArray alloc] init];
    
    for (ATBusinessObject *businessObject in self.tracker.businessObjects.allValues) {
        if ([businessObject isKindOfClass:[ATProduct class]]) {
            [impressions addObject:businessObject];
        }
    }
    
    if ([impressions count] > 0) {
        [self.tracker.dispatcher dispatch:impressions];
    }
    
}

@end
