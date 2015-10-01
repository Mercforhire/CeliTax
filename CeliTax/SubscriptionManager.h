//
//  SubscriptionManager.h
//  CeliTax
//
//  Created by Leon Chen on 2015-09-25.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class UserManager;
@protocol AuthenticationService;

#define k3MonthServiceProductID     @"com.cravensave.celitax.3monthservice"
#define k6MonthServiceProductID     @"com.cravensave.celitax.6monthservice"

UIKIT_EXTERN NSString *const SubscriptionManagerProductPurchasedNotification;

@interface SubscriptionManager : NSObject

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@property (nonatomic, weak) id <AuthenticationService> authenticationService;
@property (nonatomic, weak) UserManager *userManager;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

- (void)buyProduct:(SKProduct *)product;

- (BOOL)productPurchased:(NSString *)productIdentifier;

- (void)restoreCompletedTransactions;

- (NSInteger)daysRemainingOnSubscription;

/*
 Only call this function after the user actually successfully paid Apple for a subscription!!
 This is to 
 */
- (void)purchasedSubscriptionWithMonths:(NSInteger)months;

@end
