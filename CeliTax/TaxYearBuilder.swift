//
//  TaxYearBuilder.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-01.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class TaxYearBuilder : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    func buildTaxYearFrom(taxYearNumber : Int) -> TaxYear
    {
        let taxYear : TaxYear = TaxYear()
        
        taxYear.taxYear = taxYearNumber
        
        return taxYear
    }
}