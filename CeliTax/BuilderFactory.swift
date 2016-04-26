//
//  BuilderFactory.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-01.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class BuilderFactory : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    var categoryBuilder : CategoryBuilder?
    var recordBuilder : RecordBuilder?
    var receiptBuilder : ReceiptBuilder?
    var taxYearBuilder : TaxYearBuilder?
    
    func createCatagoryBuilder() -> CategoryBuilder
    {
        if let categoryBuilder = self.categoryBuilder
        {
            return categoryBuilder
        }
        
        self.categoryBuilder = CategoryBuilder()
        
        return self.categoryBuilder!
    }
    
    func createRecordBuilder() -> RecordBuilder
    {
        if (self.recordBuilder != nil)
        {
            return self.recordBuilder!
        }
        
        self.recordBuilder = RecordBuilder()
        
        return self.recordBuilder!
    }
    
    func createReceiptBuilder() -> ReceiptBuilder
    {
        if (self.receiptBuilder != nil)
        {
            return self.receiptBuilder!
        }
        
        self.receiptBuilder = ReceiptBuilder()
        
        return self.receiptBuilder!
    }
    
    func createTaxYearBuilder() -> TaxYearBuilder
    {
        if (self.taxYearBuilder != nil)
        {
            return self.taxYearBuilder!
        }
        
        self.taxYearBuilder = TaxYearBuilder()
        
        return self.taxYearBuilder!
    }
}