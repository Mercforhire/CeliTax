//
//  MainViewTableDataModel.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainViewTableDataModel : NSObject

@property NSMutableArray *availableTaxYears; //of Array of NSNumbers(IE: 2014,2015,2016...)

@property NSNumber *selectedTaxYear;

@property NSArray *recentReceiptsFromCurrentlySelectedYear; //of Array of Receipts

@end
