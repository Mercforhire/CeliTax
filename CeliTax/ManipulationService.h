//
//  ManipulationService.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-05.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CatagoriesDAO;

@protocol ManipulationService <NSObject>

typedef void (^AddCatagorySuccessBlock) ();
typedef void (^AddCatagoryFailureBlock) (NSString *reason);

typedef void (^ModifyCatagorySuccessBlock) ();
typedef void (^ModifyCatagoryFailureBlock) (NSString *reason);

typedef void (^DeleteCatagorySuccessBlock) ();
typedef void (^DeleteCatagoryFailureBlock) (NSString *reason);

typedef void (^AddRecordSuccessBlock) ();
typedef void (^AddRecordFailureBlock) (NSString *reason);

typedef void (^AddReceiptSuccessBlock) ();
typedef void (^AddReceiptFailureBlock) (NSString *reason);

@property (nonatomic, strong) CatagoriesDAO     *catagoriesDAO;

- (NSOperation *) addCatagoryForUserKey: (NSString *) userKey
                                forName: (NSString *) catagoryName
                               forColor: (UIColor *) catagoryColor
                                success: (AddCatagorySuccessBlock) success
                                failure: (AddCatagoryFailureBlock) failure;

//change an existing catagory by catagoryID, to new name and/or new color.
//if nil is provided for catagoryName or catagoryColor, no change will be made
- (NSOperation *) modifyCatagoryForUserKey: (NSString *) userKey
                                catagoryID: (NSInteger) catagoryID
                                   newName: (NSString *) catagoryName
                                  newColor: (UIColor *) catagoryColor
                                   success: (ModifyCatagorySuccessBlock) success
                                   failure: (ModifyCatagoryFailureBlock) failure;

- (NSOperation *) deleteCatagoryForUserKey: (NSString *) userKey
                                catagoryID: (NSInteger) catagoryID
                                   success: (DeleteCatagorySuccessBlock) success
                                   failure: (DeleteCatagoryFailureBlock) failure;

- (NSOperation *) transferCatagoryForUserKey: (NSString *) userKey
                              fromCatagoryID: (NSInteger) fromCatagoryID
                                toCatagoryID: (NSInteger) toCatagoryID
                                     success: (ModifyCatagorySuccessBlock) success
                                     failure: (ModifyCatagoryFailureBlock) failure;




- (NSOperation *) addRecordForUserKey: (NSString *) userKey
                        forCatagoryID: (NSInteger) catagoryID
                         forReceiptID: (NSInteger) receiptID
                          forQuantity: (NSInteger) quantity
                            forAmount: (NSInteger) amount
                              success: (AddRecordSuccessBlock) success
                              failure: (AddRecordFailureBlock) failure;




- (NSOperation *) addReceiptForUserKey: (NSString *) userKey
                          forFilenames: (NSArray *) filenames
                               success: (AddReceiptSuccessBlock) success
                               failure: (AddReceiptFailureBlock) failure;

@end
