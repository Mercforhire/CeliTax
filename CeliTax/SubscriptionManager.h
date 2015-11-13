//
//  SubscriptionManager.h
//  CeliTax
//
//  Created by Leon Chen on 2015-09-25.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class UserManager, AuthenticationService;

#define k3MonthServiceProductID     @"com.cravensave.celitax.3monthservice"
#define k6MonthServiceProductID     @"com.cravensave.celitax.6monthservice"

@interface SubscriptionManager : NSObject

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

typedef void (^PurchaseSubscriptionSuccessHandler)();
typedef void (^PurchaseSubscriptionFailureHandler)(NSInteger errorCode);

@property (nonatomic, weak) AuthenticationService *authenticationService;
@property (nonatomic, weak) UserManager *userManager;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

- (void)buyProduct:(SKProduct *)product
           success:(PurchaseSubscriptionSuccessHandler)completionHandler
           failure:(PurchaseSubscriptionFailureHandler)failureHandler;

- (BOOL)productPurchased:(NSString *)productIdentifier;

- (NSInteger)daysRemainingOnSubscription;

/*
 Only call this function after the user actually successfully paid Apple for a subscription!!
 */
- (void)purchasedSubscriptionWithMonths:(NSInteger)months;

@end
