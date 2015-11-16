//
//  YearSummaryData.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-15.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class SimpleCategory : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    private let kCategoryID : String = "CategoryID"
    private let kColor : String = "Color"
    private let kName : String = "Name"
    
    var categoryID : String = ""
    var colorString : String = ""
    var name : String = ""
    
    init(category : ItemCategory)
    {
        self.categoryID = category.localID
        self.colorString = String.hexStringFromColor(category.color)
        self.name = category.name
    }
    
    func toJson() -> Dictionary<String, AnyObject>
    {
        var json = Dictionary<String, AnyObject>()
        
        json[kCategoryID] = self.categoryID
        json[kColor] = self.colorString
        json[kName] = self.name
        
        return json
    }
}

@objc
class SummaryRowData : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    private let kCategoryID : String = "CategoryID"
    private let kTotalSpent : String = "TotalSpent"
    private let kTotaAvg : String = "TotaAvg"
    private let kGFSavings : String = "GFSavings"
    
    var categoryID : String = ""
    var totalSpent : Double = 0
    var totaAvg : Double = 0
    var gfSavings : Double = 0
    
    func toJson() -> Dictionary<String, AnyObject>
    {
        var json = Dictionary<String, AnyObject>()
        
        json[kCategoryID] = self.categoryID
        json[kTotalSpent] = self.totalSpent
        json[kTotaAvg] = self.totaAvg
        json[kGFSavings] = self.gfSavings
        
        return json
    }
}

@objc
class YearSummaryData : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    private let kTaxYear : String = "TaxYear"
    private let kTotalSaving : String = "TotalSaving"
    private let kCategories : String = "Categories"
    private let kSummaryRows : String = "SummaryRows"
    
    var taxYear : Int = 0
    
    var totalSaving : Double = 0
    
    var categories : [SimpleCategory] = []
    
    var summaryRows : [SummaryRowData] = []
    
    func addSimpleCategory(simpleCategory : SimpleCategory!)
    {
        self.categories.append(simpleCategory)
    }
    
    func addSummaryRow(summaryRowData : SummaryRowData!)
    {
        self.summaryRows.append(summaryRowData)
    }
    
    func toJson() -> Dictionary<String, AnyObject>
    {
        var json = Dictionary<String, AnyObject>()
        
        json[kTaxYear] = self.taxYear
        
        json[kTotalSaving] = self.totalSaving
        
        var categoriesDictionaries : [Dictionary<String, AnyObject>] = []
        
        for category in categories
        {
            categoriesDictionaries.append(category.toJson())
        }
        
        json[kCategories] = categoriesDictionaries
        
        var rowsDictionaries : [Dictionary<String, AnyObject>] = []
        
        for summaryRow in summaryRows
        {
            rowsDictionaries.append(summaryRow.toJson())
        }
        
        json[kSummaryRows] = rowsDictionaries
        
        return json
    }
}