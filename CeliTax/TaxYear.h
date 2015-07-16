//
//  TaxYear.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-15.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaxYear : NSObject <NSCoding, NSCopying>

@property (nonatomic) NSInteger taxYear;

@property (nonatomic, assign) NSInteger dataAction;

@end
