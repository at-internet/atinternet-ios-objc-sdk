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
//  ATCart.m
//  Tracker
//

#import "ATCart.h"
#import "ATTracker.h"
#import "ATProduct.h"
#import "ATParamOption.h"

@implementation ATCart

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super initWithTracker:tracker];
    
    if (self) {
        self.products = [[ATProducts alloc] initWithCart:self];
        self.productList = [[NSMutableDictionary alloc] init];
        self.cartId = @"";
    }
    
    return self;
}

- (ATCart *)setWithId:(NSString *)cartId {
    if (![cartId isEqualToString:self.cartId]) {
        [self.products removeAll];
    }
    
    self.cartId = cartId;
    [self.tracker.businessObjects setObject:self forKey:self._id];
    
    return self;
}

- (void)unset {
    self.cartId = @"";
    [self.products removeAll];
    [self.tracker.businessObjects removeObjectForKey:self._id];
}

- (void)setEvent {
    
    [self.tracker setStringParam:@"idcart" value:self.cartId];
    
    int i = 1;
    
    ATParamOption *encodeOption = [[ATParamOption alloc] init];
    encodeOption.encode = YES;
    
    for (ATProduct *pdt in self.productList.allValues) {
        
        [self.tracker setStringParam:[NSString stringWithFormat:@"pdt%d", i] value:[pdt buildProductName] options:encodeOption];
        
        if (pdt.quantity > -1) {
            [self.tracker setIntParam:[NSString stringWithFormat:@"qte%d", i] value:pdt.quantity];
        }
        
        if (pdt.unitPriceTaxFree > -1) {
            [self.tracker setDoubleParam:[NSString stringWithFormat:@"mtht%d", i] value:pdt.unitPriceTaxFree];
        }
        
        if (pdt.unitPriceTaxIncluded > -1) {
            [self.tracker setDoubleParam:[NSString stringWithFormat:@"mt%d", i] value:pdt.unitPriceTaxIncluded];
        }
        
        if (pdt.discountTaxFree > -1) {
            [self.tracker setDoubleParam:[NSString stringWithFormat:@"dscht%d", i] value:pdt.discountTaxFree];
        }
        
        if (pdt.discountTaxIncluded > -1) {
            [self.tracker setDoubleParam:[NSString stringWithFormat:@"dsc%d", i] value:pdt.discountTaxIncluded];
        }
        
        if (pdt.promotionalCode) {
            [self.tracker setStringParam:[NSString stringWithFormat:@"pcode%d", i] value:pdt.promotionalCode options:encodeOption];
        }
        
        i++;
        
    }
    
}

@end

