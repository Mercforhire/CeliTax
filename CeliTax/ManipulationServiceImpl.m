//
//  ManipulationServiceImpl.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-05.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ManipulationServiceImpl.h"
#import "CatagoriesDAO.h"
#import "ReceiptsDAO.h"
#import "RecordsDAO.h"
#import "Catagory.h"
#import "Record.h"

@implementation ManipulationServiceImpl

- (NSOperation *) addCatagoryForName:(NSString *)catagoryName forColor:(UIColor *)catagoryColor success:(AddCatagorySuccessBlock)success failure:(AddCatagoryFailureBlock)failure
{
    if (!catagoryName || !catagoryColor)
    {
        failure ( @"missing parameters");
        
        return nil;
    }
    
    if (  [self.catagoriesDAO addCatagoryForName:catagoryName andColor:catagoryColor] )
    {
        success( );
    }
    else
    {
        failure ( @"unable to add catagory");
    }
    
    return nil;
}

- (NSOperation *) modifyCatagoryForCatagoryID:(NSInteger)catagoryID newName:(NSString *)catagoryName newColor:(UIColor *)catagoryColor success:(ModifyCatagorySuccessBlock)success failure:(ModifyCatagoryFailureBlock)failure
{
    if (  [self.catagoriesDAO modifyCatagory:catagoryID forName:catagoryName andColor:catagoryColor] )
    {
        success( );
    }
    else
    {
        failure ( @"unable to modified catagory");
    }
    
    return nil;
}

- (NSOperation *) deleteCatagoryForCatagoryID:(NSInteger)catagoryID success:(DeleteCatagorySuccessBlock)success failure:(DeleteCatagoryFailureBlock)failure
{
    
    if ( [self.catagoriesDAO deleteCatagory:catagoryID] )
    {
        
        success( );
    }
    else
    {
        failure ( @"unable to delete catagory");
    }
    
    return nil;
}

- (NSOperation *) transferCatagoryFromCatagoryID:(NSInteger)fromCatagoryID toCatagoryID:(NSInteger)toCatagoryID success:(ModifyCatagorySuccessBlock)success failure:(ModifyCatagoryFailureBlock)failure
{
    
    NSArray *fromRecords = [self.recordsDAO loadRecordsforCatagory:fromCatagoryID];
    
    if (!fromRecords)
    {
        //nothing to transfer
        success ();
    }
    
    Catagory *toItemCatagory = [self.catagoriesDAO loadCatagory:toCatagoryID];
    
    if (!toItemCatagory)
    {
        failure ( @"invalid toCatagoryID");
    }
    
    NSMutableArray *modifiedRecordsToAdd = [NSMutableArray new];
    
    for (Record *record in fromRecords)
    {
        record.catagoryID = toCatagoryID;
        
        [modifiedRecordsToAdd addObject:record];
    }
    
    if ( [self.recordsDAO addRecords:modifiedRecordsToAdd] )
    {
        success ();
    }
    else
    {
        failure ( @"unable to add catagory records");
    }
    
    return nil;
}

- (NSOperation *) addRecordForCatagoryID:(NSInteger)catagoryID forReceiptID:(NSInteger)receiptID forQuantity:(NSInteger)quantity forAmount:(NSInteger)amount success:(AddRecordSuccessBlock)success failure:(AddRecordFailureBlock)failure
{
    
    Catagory *toItemCatagory = [self.catagoriesDAO loadCatagory:catagoryID];
    
    if (!toItemCatagory)
    {
        failure ( @"invalid catagoryID");
    }
    
    if ( [self.recordsDAO addRecordForCatagoryID:catagoryID
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

- (NSOperation *) getNextReceiptIDWithSuccess:(GetNextReceiptIDSuccessBlock)success andFailure:(GetNextReceiptIDFailureBlock)failure
{

    NSInteger nextReceiptID = [self.receiptsDAO getNextReceiptID];
    
    if ( nextReceiptID > -1 )
    {
        success ( nextReceiptID );
    }
    else
    {
        failure ( @"unable to get next receipt ID");
    }
    
    return nil;
}

- (NSOperation *) addReceiptForFilenames:(NSArray *)filenames success:(AddReceiptSuccessBlock)success failure:(AddReceiptFailureBlock)failure
{
    
    if (!filenames)
    {
        failure ( @"missing filenames");
        
        return nil;
    }
    
    if ( [self.receiptsDAO addReceiptWithFilenames:filenames] )
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
