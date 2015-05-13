//
//  ManipulationServiceImpl.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-05.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ManipulationServiceImpl.h"
#import "CatagoriesDAO.h"
#import "ItemCatagory.h"
#import "CatagoryRecord.h"

@implementation ManipulationServiceImpl

- (NSOperation *) addCatagoryForUserKey: (NSString *) userKey
                                forName: (NSString *) catagoryName
                               forColor: (UIColor *) catagoryColor
                                success: (AddCatagorySuccessBlock) success
                                failure: (AddCatagoryFailureBlock) failure
{
    if (!userKey)
    {
        failure ( @"missing userKey");
        
        return nil;
    }
    
    if (!catagoryName || !catagoryColor)
    {
        failure ( @"missing parameters");
        
        return nil;
    }
    
    if (  [self.catagoriesDAO addCatagoryForUser:userKey forName:catagoryName andColor:catagoryColor] )
    {
        success( );
    }
    else
    {
        failure ( @"unable to add catagory");
    }
    
    return nil;
}

- (NSOperation *) modifyCatagoryForUserKey: (NSString *) userKey
                                catagoryID: (NSInteger) catagoryID
                                   newName: (NSString *) catagoryName
                                  newColor: (UIColor *) catagoryColor
                                   success: (ModifyCatagorySuccessBlock) success
                                   failure: (ModifyCatagoryFailureBlock) failure
{
    if (!userKey)
    {
        failure ( @"missing userKey");
        
        return nil;
    }
    
    if (  [self.catagoriesDAO modifyCatagoryForUser:userKey forCatagory:catagoryID forName:catagoryName andColor:catagoryColor] )
    {
        success( );
    }
    else
    {
        failure ( @"unable to modified catagory");
    }
    
    return nil;
}

- (NSOperation *) deleteCatagoryForUserKey: (NSString *) userKey
                                catagoryID: (NSInteger) catagoryID
                                   success: (DeleteCatagorySuccessBlock) success
                                   failure: (DeleteCatagoryFailureBlock) failure
{
    if (!userKey)
    {
        failure ( @"missing userKey");
        
        return nil;
    }
    
    if ( [self.catagoriesDAO deleteCatagoryForUser:userKey forCatagory:catagoryID] )
    {
        
        success( );
    }
    else
    {
        failure ( @"unable to delete catagory");
    }
    
    return nil;
}

- (NSOperation *) transferCatagoryForUserKey: (NSString *) userKey
                              fromCatagoryID: (NSInteger) fromCatagoryID
                                toCatagoryID: (NSInteger) toCatagoryID
                                     success: (ModifyCatagorySuccessBlock) success
                                     failure: (ModifyCatagoryFailureBlock) failure
{
    if (!userKey)
    {
        failure ( @"missing userKey");
        
        return nil;
    }
    
    NSArray *fromCatagoryRecords = [self.catagoriesDAO loadCatagoryRecordsForUser:userKey forCatagory:fromCatagoryID];
    
    if (!fromCatagoryRecords)
    {
        //nothing to transfer
        success ();
    }
    
    ItemCatagory *toItemCatagory = [self.catagoriesDAO loadCatagoryForUser:userKey withCatagoryID:toCatagoryID];
    
    if (!toItemCatagory)
    {
        failure ( @"invalid toCatagoryID");
    }
    
    NSMutableArray *modifiedCatagoryRecordsToAdd = [NSMutableArray new];
    
    for (CatagoryRecord *record in fromCatagoryRecords)
    {
        record.itemCatagoryID = toCatagoryID;
        
        [modifiedCatagoryRecordsToAdd addObject:record];
    }
    
    if ( [self.catagoriesDAO addCatagoryRecordsForUser:userKey andRecords:modifiedCatagoryRecordsToAdd] )
    {
        success ();
    }
    else
    {
        failure ( @"unable to add catagory records");
    }
    
    return nil;
}

- (NSOperation *) addRecordForUserKey: (NSString *) userKey
                        forCatagoryID: (NSInteger) catagoryID
                         forReceiptID: (NSInteger) receiptID
                          forQuantity: (NSInteger) quantity
                            forAmount: (NSInteger) amount
                              success: (AddRecordSuccessBlock) success
                              failure: (AddRecordFailureBlock) failure
{
    if (!userKey)
    {
        failure ( @"missing userKey");
        
        return nil;
    }
    
    ItemCatagory *toItemCatagory = [self.catagoriesDAO loadCatagoryForUser:userKey withCatagoryID:catagoryID];
    
    if (!toItemCatagory)
    {
        failure ( @"invalid catagoryID");
    }
    
    if ( [self.catagoriesDAO addCatagoryRecordForUser:userKey
                                        forCatagoryID:catagoryID
                                         forReceiptID:receiptID
                                          forQuantity:quantity
                                            forAmount:amount] )
    {
        success ( );
    }
    else
    {
        failure ( @"unable to add catagory record");
    }
    
    return nil;
}

- (NSOperation *) addReceiptForUserKey: (NSString *) userKey
                          forFilenames: (NSArray *) filenames
                               success: (AddReceiptSuccessBlock) success
                               failure: (AddReceiptFailureBlock) failure
{
    if (!userKey)
    {
        failure ( @"missing userKey");
        
        return nil;
    }
    
    if (!filenames)
    {
        failure ( @"missing filenames");
        
        return nil;
    }
    
    if ( [self.catagoriesDAO addReceiptForUser:userKey withFilenames:filenames] )
    {
        success ( );
    }
    else
    {
        failure ( @"unable to add receipt");
    }
    
    return nil;
}

@end
