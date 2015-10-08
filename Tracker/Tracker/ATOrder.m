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
//  ATOrder.m
//  Tracker
//

#import "ATOrder.h"
#import "ATTracker.h"
#import "ATParamOption.h"


@implementation ATOrder

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super initWithTracker:tracker];
    
    if (self) {
        self.discount = [[ATOrderDiscount alloc] initWithOrder:self];
        self.amount = [[ATOrderAmount alloc] initWithOrder:self];
        self.delivery = [[ATOrderDelivery alloc] initWithOrder:self];
        self.customVariables = [[ATOrderCustomVars alloc] initWithOrder:self];
        self.orderId = [[NSString alloc] init];
        self.status = -1;
        self.paymentMethod = -1;
    }
    
    return self;
}

- (void)setEvent {
    
    ATParamOption *encodeOption = [[ATParamOption alloc] init];
    encodeOption.encode = YES;
    
    [self.tracker setStringParam:@"cmd" value:self.orderId];
    [self.tracker setDoubleParam:@"roimt" value:self.turnover];
        
    if (self.status > -1) {
        [self.tracker setIntParam:@"st" value:self.status];
    }
    
    if (self.isNewCustomer) {
        [self.tracker setIntParam:@"newcus" value:1];
    } else {
        [self.tracker setIntParam:@"newcus" value:0];
    }
    
    if (self.discount.discountTaxFree > -1) {
        [self.tracker setDoubleParam:@"dscht" value:self.discount.discountTaxFree];
    }
    
    if (self.discount.discountTaxIncluded > -1) {
        [self.tracker setDoubleParam:@"dsc" value:self.discount.discountTaxIncluded];
    }
    
    if (self.discount.promotionalCode) {
        [self.tracker setStringParam:@"pcd" value:self.discount.promotionalCode options:encodeOption];
    }
    
    if (self.amount.amountTaxFree > -1) {
        [self.tracker setDoubleParam:@"mtht" value:self.amount.amountTaxFree];
    }
    
    if (self.amount.amountTaxIncluded > -1) {
        [self.tracker setDoubleParam:@"mtttc" value:self.amount.amountTaxIncluded];
    }
    
    if (self.amount.taxAmount > -1) {
        [self.tracker setDoubleParam:@"tax" value:self.amount.taxAmount];
    }
    
    if (self.delivery.shippingFeesTaxFree > -1) {
        [self.tracker setDoubleParam:@"fpht" value:self.delivery.shippingFeesTaxFree];
    }
    
    if (self.delivery.shippingFeesTaxIncluded > -1) {
        [self.tracker setDoubleParam:@"fp" value:self.delivery.shippingFeesTaxIncluded];
    }
    
    if (self.delivery.deliveryMethod) {
        [self.tracker setStringParam:@"dl" value:self.delivery.deliveryMethod options:encodeOption];
    }
    
    for (ATOrderCustomVar *customVar in self.customVariables.list) {
        [self.tracker setStringParam:[NSString stringWithFormat:@"O%d", customVar.varId] value:customVar.value];
    }
    
    if (self.paymentMethod > -1) {
        [self.tracker setIntParam:@"mp" value:self.paymentMethod];
    }
    
    if (self.isConfirmationRequired) {
        [self.tracker setStringParam:@"tp" value:@"pre1"];
    }
    
}

@end


@implementation ATOrders

- (instancetype)initWithTracker:(ATTracker *)tracker {
    self = [super init];
    
    if (self) {
        self.tracker = tracker;
    }
    
    return self;
}

- (ATOrder *)addWithId:(NSString *)orderId turnover:(double)turnover {
    ATOrder *order = [[ATOrder alloc] initWithTracker:self.tracker];
    order.orderId = orderId;
    order.turnover = turnover;
    
    [self.tracker.businessObjects setObject:order forKey:order._id];
    
    return order;
}

- (ATOrder *)addWithId:(NSString *)orderId turnover:(double)turnover status:(int)status {
    ATOrder *order = [self addWithId:orderId turnover:turnover];
    order.status = status;
    
    return order;
}

@end


@interface ATOrderDiscount()

@property (nonatomic, strong) ATOrder *order;

@end

@implementation ATOrderDiscount

- (instancetype)initWithOrder:(ATOrder *)order {
    if (self = [super init]) {
        self.order = order;
        self.discountTaxIncluded = -1;
        self.discountTaxFree = -1;
    }
    
    return self;
}

- (ATOrder *)setWithDiscountTaxFree:(double)discountTaxFree discountTaxIncluded:(double)discountTaxIncluded promotionalCode:(NSString *)promotionalCode {
    self.discountTaxIncluded = discountTaxIncluded;
    self.discountTaxFree = discountTaxFree;
    self.promotionalCode = promotionalCode;
    
    return self.order;
}

@end


@interface ATOrderAmount()

@property (nonatomic, strong) ATOrder *order;

@end

@implementation ATOrderAmount

- (instancetype)initWithOrder:(ATOrder *)order {
    if (self = [super init]) {
        self.order = order;
        self.amountTaxFree = -1;
        self.amountTaxIncluded = -1;
        self.taxAmount = -1;
    }
    
    return self;
}

- (ATOrder *)setWithAmountTaxFree:(double)amountTaxFree amountTaxIncluded:(double)amountTaxIncluded taxAmount:(double)taxAmount {
    self.amountTaxFree = amountTaxFree;
    self.amountTaxIncluded = amountTaxIncluded;
    self.taxAmount = taxAmount;
    
    return self.order;
}

@end


@interface ATOrderDelivery()

@property (nonatomic, strong) ATOrder *order;

@end

@implementation ATOrderDelivery

- (instancetype)initWithOrder:(ATOrder *)order {
    if (self = [super init]) {
        self.order = order;
        self.shippingFeesTaxFree = -1;
        self.shippingFeesTaxIncluded = -1;
        self.deliveryMethod = [[NSString alloc] init];
    }
    
    return self;
}

- (ATOrder *)setWithShippingFeesTaxFree:(double)shippingFeesTaxFree shippingFeesTaxIncluded:(double)shippingFeesTaxIncluded deliveryMethod:(NSString *)deliveryMethod {
    self.shippingFeesTaxFree = shippingFeesTaxFree;
    self.shippingFeesTaxIncluded = shippingFeesTaxIncluded;
    self.deliveryMethod = deliveryMethod;
    
    return self.order;
}

@end


@implementation ATOrderCustomVar

- (instancetype)initWithVarId:(int)varId value:(NSString *)value {
    if (self = [super init]) {
        self.varId = varId;
        self.value = value;
    }
    
    return self;
}

@end


@implementation ATOrderCustomVars

- (instancetype)initWithOrder:(ATOrder *)order {
    if (self = [super init]) {
        self.order = order;
        self.list = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (ATOrderCustomVar *)addWithId:(int)varId value:(NSString *)value {
    ATOrderCustomVar *customVar = [[ATOrderCustomVar alloc] initWithVarId:varId value:value];
    [self.list addObject:customVar];
    
    return customVar;
}

@end
