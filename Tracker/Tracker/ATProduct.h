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
//  ATProduct.h
//  Tracker
//

#import <Foundation/Foundation.h>
#import "ATBusinessObject.h"

@class ATTracker;
@class ATCart;

@interface ATProduct : ATBusinessObject

/**
 Product actions
 */
typedef NS_ENUM(int, ATProductAction) {
    ATProductActionView
};

/**
 Product identifier
 */
@property (nonatomic, strong) NSString *productId;

/**
 First product category
 */
@property (nonatomic, strong) NSString *category1;

/**
 Second product category
 */
@property (nonatomic, strong) NSString *category2;

/**
 Third product category
 */
@property (nonatomic, strong) NSString *category3;

/**
 Fourth product category
 */
@property (nonatomic, strong) NSString *category4;

/**
 Fifth product category
 */
@property (nonatomic, strong) NSString *category5;

/**
 Sixth product category
 */
@property (nonatomic, strong) NSString *category6;

/**
 Product quantity
 */
@property (nonatomic) int quantity;

/**
 Product unit price with tax
 */
@property (nonatomic) double unitPriceTaxIncluded;

/**
 Product unit price without tax
 */
@property (nonatomic) double unitPriceTaxFree;

/**
 Discount value with tax
 */
@property (nonatomic) double discountTaxIncluded;

/**
 Discount value without tax
 */
@property (nonatomic) double discountTaxFree;

/**
 Promotional code
 */
@property (nonatomic, strong) NSString *promotionalCode;

/**
 Product action
 */
@property (nonatomic) ATProductAction action;

/**
 Send product view hit
 */
- (void)sendView;

/**
 ATProduct initializer
 @param tracker the tracker instance
 @return ATProduct instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

/**
 Prepare parameters for the hit query string
 */
- (void)setEvent;

/**
 Format product name with categories
 */
- (NSString *)buildProductName;

@end


@interface ATProducts : NSObject

/**
 Add a product
 @param product product to add
 @return the product
 */
- (ATProduct *)addWithProduct:(ATProduct *)product;

/**
 Add a product
 @param productId the product identifier
 @return the product
 */
- (ATProduct *)addWithId:(NSString *)productId;

/**
 Add a product
 @param productId the product identifier
 @param category1 category1 label
 @return the product
 */
- (ATProduct *)addWithId:(NSString *)productId category1:(NSString *)category1;

/**
 Add a product
 @param productId the product identifier
 @param category1 category1 label
 @param category2 category2 label
 @return the product
 */
- (ATProduct *)addWithId:(NSString *)productId category1:(NSString *)category1 category2:(NSString *)category2;

/**
 Add a product
 @param productId the product identifier
 @param category1 category1 label
 @param category2 category2 label
 @param category3 category3 label
 @return the product
 */
- (ATProduct *)addWithId:(NSString *)productId
               category1:(NSString *)category1
               category2:(NSString *)category2
               category3:(NSString *)category3;

/**
 Add a product
 @param productId the product identifier
 @param category1 category1 label
 @param category2 category2 label
 @param category3 category3 label
 @param category4 category4 label
 @return the product
 */
- (ATProduct *)addWithId:(NSString *)productId
               category1:(NSString *)category1
               category2:(NSString *)category2
               category3:(NSString *)category3
               category4:(NSString *)category4;

/**
 Add a product
 @param productId the product identifier
 @param category1 category1 label
 @param category2 category2 label
 @param category3 category3 label
 @param category4 category4 label
 @param category5 category5 label
 @return the product
 */
- (ATProduct *)addWithId:(NSString *)productId
               category1:(NSString *)category1
               category2:(NSString *)category2
               category3:(NSString *)category3
               category4:(NSString *)category4
               category5:(NSString *)category5;

/**
 Add a product
 @param productId the product identifier
 @param category1 category1 label
 @param category2 category2 label
 @param category3 category3 label
 @param category4 category4 label
 @param category5 category5 label
 @param category6 category6 label
 @return the product
 */
- (ATProduct *)addWithId:(NSString *)productId
               category1:(NSString *)category1
               category2:(NSString *)category2
               category3:(NSString *)category3
               category4:(NSString *)category4
               category5:(NSString *)category5
               category6:(NSString *)category6;

/**
 Remove a product
 @param productId the product identifier
 */
- (void)removeWithId:(NSString *)productId;

/**
 Remove all the products
 */
- (void)removeAll;

/**
 Send product view hits
 */
- (void)sendViews;

/**
 ATProducts initializer
 @param cart the cart instance
 @return ATProducts instance
 */
- (instancetype)initWithCart:(ATCart *)cart;

/**
 ATProducts initializer
 @param tracker the tracker instance
 @return ATProducts instance
 */
- (instancetype)initWithTracker:(ATTracker *)tracker;

@end
