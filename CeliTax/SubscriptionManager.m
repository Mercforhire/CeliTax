//
//  SubscriptionManager.m
//  CeliTax
//
//  Created by Leon Chen on 2015-09-25.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "SubscriptionManager.h"
#import "UserManager.h"
#import "User.h"
#import "AuthenticationService.h"
#import "Utils.h"

NSString *const SubscriptionManagerProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

@interface SubscriptionManager () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end

@implementation SubscriptionManager {
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    if ((self = [super init]))
    {
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        
        for (NSString * productIdentifier in _productIdentifiers)
        {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey: productIdentifier];
            
            if (productPurchased)
            {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                DLog(@"Previously purchased: %@", productIdentifier);
            }
            else
            {
                DLog(@"Not purchased: %@", productIdentifier);
            }
        }
        
        // Add self as transaction observer
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    
    return self;
}

// retrieve the product information from iTunes Connect
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{
    // makes copy of the completion handler block inside the instance variable so it can notify the caller when the product request asynchronously completes
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

- (BOOL)productPurchased:(NSString *)productIdentifier
{
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product
{
    DLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)validateReceiptForTransaction:(SKPaymentTransaction *)transaction
{
//    VerificationController * verifier = [VerificationController sharedInstance];
//    
//    [verifier verifyPurchase:transaction completionHandler:^(BOOL success) {
//        if (success) {
//            NSLog(@"Successfully verified receipt!");
//            [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
//        } else {
//            NSLog(@"Failed to validate receipt.");
//            [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
//        }
//    }];
}

- (NSInteger)daysRemainingOnSubscription
{
    NSString *expirationDateString = self.userManager.user.subscriptionExpirationDate;
    
    if (!expirationDateString)
    {
        return 0;
    }
    
    NSDate *expirationDate = [Utils dateFromDateString:expirationDateString];
    
    NSTimeInterval timeInt = [expirationDate timeIntervalSinceDate:[NSDate date]];
    
    NSInteger days = timeInt / 60 / 60 / 24;
    
    if (days > 0)
    {
        return days;
    }
    else
    {
        return 0;
    }
}

- (void)purchasedSubscriptionWithMonths:(NSInteger)months
{
    //1. Tell server to generate a new expiration date
    [self.authenticationService addNumberOfMonthToUserSubscription:months success:^(NSString *expiryDateString) {
        
        //2. Get the new date as the response from server and save it locally
        [self.userManager setExpiryDate:expiryDateString];
        
    } failure:^(NSString *reason) {
        DLog(@"purchasedSubscriptionWithMonths failed! This should never happen");
    }];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    
    if (response.products.count)
    {
        DLog(@"Loaded list of products...");
    }
    else
    {
        DLog(@"No products found.");
    }
    
    for (SKProduct * skProduct in skProducts)
    {
        DLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    DLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}

#pragma mark SKPaymentTransactionOBserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    DLog(@"completeTransaction...");
    
    [self validateReceiptForTransaction:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    DLog(@"restoreTransaction...");
    
    [self validateReceiptForTransaction:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    DLog(@"failedTransaction...");
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier
{
    if ([productIdentifier isEqualToString:k3MonthServiceProductID])
    {
        [self purchasedSubscriptionWithMonths:3];
    }
    else if ( [productIdentifier isEqualToString:k6MonthServiceProductID] )
    {
        [self purchasedSubscriptionWithMonths:6];
    }
    else
    {
        DLog(@"Invalid product.");
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SubscriptionManagerProductPurchasedNotification object:productIdentifier userInfo:nil];
}

- (void)restoreCompletedTransactions
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end
