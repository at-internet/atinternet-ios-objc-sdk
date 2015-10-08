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
//  ATOrder.h
//  Tracker
//

#import <Foundation/Foundation.h>
#import "ATBusinessObject.h"

@class ATTracker;
@class ATOrderDiscount;
@class ATOrderAmount;
@class ATOrderDelivery;
@class ATOrderCustomVars;


@interface ATOrder : ATBusinessObject

/**
 Order identifier
 */
@property (nonatomic, strong) NSString *orderId;

/**
 Turnover
 */
@property (nonatomic) double turnover;

/**
 Status
 */
@property (nonatomic) int status;

/**
 Discount
 */
@property (nonatomic, strong) ATOrderDiscount *discount;

/**
 Amount
 */
@property (nonatomic, strong) ATOrderAmount *amount;

/**
 Delivery
 */
@property (nonatomic, strong) ATOrderDelivery *delivery;

/**
 Custom variables
 */
@property (nonatomic, strong) ATOrderCustomVars *customVariables;

/**
 New customer
 */
@property (nonatomic) BOOL isNewCustomer;

/**
 Payment method
 */
@property (nonatomic) int paymentMethod;

/**
 Confirmation required
 */
@property (nonatomic) BOOL isConfirmationRequired;

/**
 Prepare parameters for the hit query string
 */
- (void)setEvent;

/**
 ATOrder initializer
 @param tracker the tracker instance
 @return ATOrder instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end


@interface ATOrders : NSObject

/**
 Tracker instance
 */
@property (nonatomic, strong) ATTracker *tracker;

/**
 Add tagging data for a new order
 @param orderId order identifier
 @param turnover order turnover
 @return the ATOrder instance
 */
- (ATOrder *)addWithId:(NSString *)orderId turnover:(double)turnover;

/**
 Add tagging data for a new order
 @param orderId order identifier
 @param turnover order turnover
 @param status order status
 @return the ATOrder instance
 */
- (ATOrder *)addWithId:(NSString *)orderId turnover:(double)turnover status:(int)status;

/**
 ATOrders initializer
 @param tracker the tracker instance
 @return ATOrders instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end


@interface ATOrderDiscount : NSObject

/**
 Discount with tax
 */
@property (nonatomic) double discountTaxIncluded;

/**
 Discount without tax
 */
@property (nonatomic) double discountTaxFree;

/**
 Promotional code
 */
@property (nonatomic, strong) NSString *promotionalCode;

/**
 Set tagging data for a discount
 @param discountTaxFree discount value tax free
 @param discountTaxIncluded discount value tax included
 @param promotionalCode promotional code
 @return the ATOrder instance
 */
- (ATOrder *)setWithDiscountTaxFree:(double)discountTaxFree discountTaxIncluded:(double)discountTaxIncluded promotionalCode:(NSString *)promotionalCode;

/**
 ATOrderDiscount initializer
 @param order the ATOrder instance
 @return ATOrderDiscount instance
 */
- (instancetype)initWithOrder:(ATOrder *)order;

@end


@interface ATOrderAmount : NSObject

/**
 Amount with tax
 */
@property (nonatomic) double amountTaxIncluded;

/**
 Amount without tax
 */
@property (nonatomic) double amountTaxFree;

/**
 Tax amount
 */
@property (nonatomic) double taxAmount;

/**
 Set tagging data for an amount
 @param amountTaxFree amount value tax free
 @param amountTaxIncluded amount value tax included
 @param taxAmount tax amount
 @return the ATOrder instance
 */
- (ATOrder *)setWithAmountTaxFree:(double)amountTaxFree amountTaxIncluded:(double)amountTaxIncluded taxAmount:(double)taxAmount;

/**
 ATOrderAmount initializer
 @param order the ATOrder instance
 @return ATOrderAmount instance
 */
- (instancetype)initWithOrder:(ATOrder *)order;

@end


@interface ATOrderDelivery : NSObject

/**
 Shipping fees with tax
 */
@property (nonatomic) double shippingFeesTaxIncluded;

/**
 Shipping fees without tax
 */
@property (nonatomic) double shippingFeesTaxFree;

/**
 Delivery method
 */
@property (nonatomic) NSString *deliveryMethod;

/**
 Set tagging data for a delivery
 @param shippingFeesTaxFree shipping fees tax free
 @param shippingFeesTaxIncluded shipping fees tax included
 @param deliveryMethod delivery method
 @return the ATOrder instance
 */
- (ATOrder *)setWithShippingFeesTaxFree:(double)shippingFeesTaxFree shippingFeesTaxIncluded:(double)shippingFeesTaxIncluded deliveryMethod:(NSString *)deliveryMethod;

/**
 ATOrderDelivery initializer
 @param order the ATOrder instance
 @return ATOrderDelivery instance
 */
- (instancetype)initWithOrder:(ATOrder *)order;

@end


@interface ATOrderCustomVar : NSObject

/**
 Custom var value
 */
@property (nonatomic, strong) NSString *value;

/**
 Custom var identifier
 */
@property (nonatomic) int varId;

/**
 ATOrderCustomVar initializer
 @param varId the custom var identifier
 @param value the custom var value
 @return ATOrderCustomVar instance
 */
- (instancetype)initWithVarId:(int)varId value:(NSString *)value;

@end


@interface ATOrderCustomVars : NSObject

/**
 Order instance
 */
@property (nonatomic, strong) ATOrder *order;

/**
 Custom var list
 */
@property (nonatomic, strong) NSMutableArray *list;

/**
 Add tagging data for custom var
 @param varId custom var identifier
 @param value custom var value
 @return the ATOrderCustomVar instance
 */
- (ATOrderCustomVar *)addWithId:(int)varId value:(NSString *)value;

/**
 ATOrderCustomVars initializer
 @param order the ATOrder instance
 @return ATOrderCustomVars instance
 */
- (instancetype)initWithOrder:(ATOrder *)order;

@end
