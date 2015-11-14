//
//  SubscriptionManager.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-13.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation
import StoreKit

@objc
class SubscriptionManager : NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    static let k3MonthServiceProductID : String = "com.cravensave.celitax.3monthservice"
    static let k6MonthServiceProductID : String = "com.cravensave.celitax.6monthservice"
    
    typealias RequestProductsCompletionHandler = (success : Bool, products : [SKProduct]?) -> Void
    typealias PurchaseSubscriptionSuccessHandler = () -> Void
    typealias PurchaseSubscriptionFailureHandler = (errorCode : Int) -> Void
    
    private weak var authenticationService : AuthenticationService!
    private weak var userManager : UserManager!
    
    private var productsRequest : SKProductsRequest?
    private var completionHandler : RequestProductsCompletionHandler?
    
    private var productIdentifiers : Set<String>!
    private var purchasedProductIdentifiers : Set<String>!
    
    private var purchaseCompletionHandler : PurchaseSubscriptionSuccessHandler?
    private var purchaseFailureHandler : PurchaseSubscriptionFailureHandler?
    
    override init()
    {
        super.init()
    }
    
    init(productIdentifiers : Set<String>!, authenticationService : AuthenticationService, userManager : UserManager)
    {
        super.init()
        
        self.authenticationService = authenticationService
        
        self.userManager = userManager
        
        // Store product identifiers
        self.productIdentifiers = productIdentifiers
        
        // Check for previously purchased products
        self.purchasedProductIdentifiers = Set<String>()
        
        // Add self as transaction observer
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    // retrieve the product information from iTunes Connect
    func requestProductsWithCompletionHandler(completionHandler : RequestProductsCompletionHandler?)
    {
        // makes copy of the completion handler block inside the instance variable so it can notify the caller when the product request asynchronously completes
        self.completionHandler = completionHandler
        
        self.productsRequest = SKProductsRequest.init(productIdentifiers: self.productIdentifiers)
        
        self.productsRequest!.delegate = self
        self.productsRequest!.start()
    }
    
    func productPurchased(productIdentifier : String) -> Bool
    {
        return self.purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    func buyProduct(product : SKProduct!, completionHandler : PurchaseSubscriptionSuccessHandler?, failureHandler : PurchaseSubscriptionFailureHandler?)
    {
        // makes copy of the completion handler block inside the instance variable so it can notify the caller when the purchase asynchronously completes
        self.purchaseCompletionHandler = completionHandler
        self.purchaseFailureHandler = failureHandler
        
        let payment : SKPayment = SKPayment.init(product: product)
        
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    private func validateReceiptForTransaction(transaction : SKPaymentTransaction!)
    {
        if (transaction.error == nil)
        {
            dLog("Successfully verified receipt!")
            self.provideContentForProductIdentifier(transaction.payment.productIdentifier)
        }
        else
        {
            switch (transaction.error!.code)
            {
            case SKErrorUnknown:
                //Unknown error
                break;
            case SKErrorClientInvalid:
                // client is not allowed to issue the request, etc.
                break;
            case SKErrorPaymentCancelled:
                // user cancelled the request, etc.
                break;
            case SKErrorPaymentInvalid:
                // purchase identifier was invalid, etc.
                break;
            case SKErrorPaymentNotAllowed:
                // this device is not allowed to make the payment
                break;
            default:
                break;
            }
            
            SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            
            if (self.purchaseFailureHandler != nil)
            {
                self.purchaseFailureHandler!(errorCode: transaction.error!.code)
                self.purchaseFailureHandler = nil
            }
        }
    }
    
    func daysRemainingOnSubscription() -> Int
    {
        let expirationDateString : String = self.userManager.user!.subscriptionExpirationDate
        
        if (expirationDateString.characters.count == 0)
        {
            return 0
        }
        
        let expirationDate : NSDate! = Utils.dateFromDateString(expirationDateString)
        
        let timeInt : NSTimeInterval = expirationDate.timeIntervalSinceDate(NSDate.init())
        
        let days : Int = Int(timeInt / 60 / 60 / 24)
        
        if (days > 0)
        {
            return days
        }
        else
        {
            return 0
        }
    }
    
    /*
    Only call this function after the user actually successfully paid Apple for a subscription!!
    */
    func purchasedSubscriptionWithMonths(months : Int)
    {
        //1. Tell server to generate a new expiration date
        self.authenticationService.addNumberOfMonthToUserSubscription(months, success:{ (expiryDateString) in
            
            //2. Get the new date as the response from server and save it locally
            self.userManager.setExpiryDate(expiryDateString)
            
            if (self.purchaseCompletionHandler != nil)
            {
                self.purchaseCompletionHandler!()
                self.purchaseCompletionHandler = nil
            }
            
            }, failure: { (reason) in
                
                dLog("purchasedSubscriptionWithMonths failed! This should never happen")
                
                if (self.purchaseFailureHandler != nil)
                {
                    self.purchaseFailureHandler! (errorCode: -1)
                    self.purchaseFailureHandler = nil
                }
        })
    }
    
    private func provideContentForProductIdentifier(productIdentifier : String)
    {
        if (productIdentifier == SubscriptionManager.k3MonthServiceProductID)
        {
            self.purchasedSubscriptionWithMonths(3)
        }
        else if (productIdentifier == SubscriptionManager.k6MonthServiceProductID)
        {
            self.purchasedSubscriptionWithMonths(6)
        }
        else
        {
            dLog("Invalid product")
            return
        }
    }
    
    //#pragma mark - SKProductsRequestDelegate
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse)
    {
        self.productsRequest = nil
        
        let skProducts : [SKProduct] = response.products 
        
        self.completionHandler!(success: true, products: skProducts)
        self.completionHandler = nil
    }
    
    
    func request(request: SKRequest, didFailWithError error: NSError)
    {
        dLog("Failed to load list of products.")
        self.productsRequest = nil
        
        self.completionHandler!(success: false, products: nil)
        self.completionHandler = nil
    }
    
    //#pragma mark SKPaymentTransactionOBserver
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        for transaction in transactions
        {
            switch (transaction.transactionState)
            {
            case SKPaymentTransactionState.Purchased:
                self.completeTransaction(transaction)
                break;
                
            case SKPaymentTransactionState.Failed:
                self.failedTransaction(transaction)
                break;
                
            default:
                break;
            }
        };
    }
    
    func completeTransaction(transaction : SKPaymentTransaction)
    {
        dLog("Complete Transaction...")
        
        self.validateReceiptForTransaction(transaction)
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    func restoreTransaction(transaction : SKPaymentTransaction)
    {
        dLog("Restore Transaction...")
        
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    func failedTransaction(transaction : SKPaymentTransaction)
    {
        dLog("Failed Transaction...")
        
        if (transaction.error!.code != SKErrorPaymentCancelled)
        {
            dLog( String.init(format: "Transaction error: %@", transaction.error!.localizedDescription) )
        }
        
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        
        if (self.purchaseFailureHandler != nil)
        {
            self.purchaseFailureHandler!(errorCode: transaction.error!.code)
            self.purchaseFailureHandler = nil
        }
    }
}