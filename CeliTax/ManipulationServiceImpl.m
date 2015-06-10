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

- (void) addCatagoryForName:(NSString *)catagoryName forColor:(UIColor *)catagoryColor success:(AddCatagorySuccessBlock)success failure:(AddCatagoryFailureBlock)failure
{
    if (!catagoryName || !catagoryColor)
    {
        failure ( @"missing parameters");
        
        return;
    }
    
    if (  [self.catagoriesDAO addCatagoryForName:catagoryName andColor:catagoryColor andNationalAverageCost:0] )
    {
        success( );
    }
    else
    {
        failure ( @"unable to add catagory");
    }
    
    return;
}

- (void) modifyCatagoryForCatagoryID:(NSString *)catagoryID newName:(NSString *)catagoryName newColor:(UIColor *)catagoryColor success:(ModifyCatagorySuccessBlock)success failure:(ModifyCatagoryFailureBlock)failure
{
    if (  [self.catagoriesDAO modifyCatagory:catagoryID forName:catagoryName andColor:catagoryColor] )
    {
        success( );
    }
    else
    {
        failure ( @"unable to modified catagory");
    }
    
    return;
}

- (void) deleteCatagoryForCatagoryID:(NSString *)catagoryID success:(DeleteCatagorySuccessBlock)success failure:(DeleteCatagoryFailureBlock)failure
{
    
    if ( [self.catagoriesDAO deleteCatagory:catagoryID] )
    {
        
        success( );
    }
    else
    {
        failure ( @"unable to delete catagory");
    }
    
    return;
}

- (void) transferCatagoryFromCatagoryID:(NSString *)fromCatagoryID toCatagoryID:(NSString *)toCatagoryID success:(ModifyCatagorySuccessBlock)success failure:(ModifyCatagoryFailureBlock)failure
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
        record.catagoryID = [toCatagoryID copy];
        
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
    
    return;
}

- (void) addRecordForCatagoryID:(NSString *)catagoryID forReceiptID:(NSString *)receiptID forQuantity:(NSInteger)quantity forAmount:(float)amount success:(AddRecordSuccessBlock)success failure:(AddRecordFailureBlock)failure
{
    
    Catagory *toItemCatagory = [self.catagoriesDAO loadCatagory:catagoryID];
    
    if (!toItemCatagory)
    {
        failure ( @"invalid catagoryID");
    }
    
    NSString *newestRecordID = [self.recordsDAO addRecordForCatagoryID:catagoryID andReceiptID:receiptID forQuantity:quantity forAmount:amount];
    
    if ( newestRecordID )
    {
        success ( newestRecordID );
    }
    else
    {
        failure ( @"unable to add catagory record");
    }
    
    return;
}

- (void) deleteRecord:(NSString *)recordID WithSuccess:(DeleteRecordSuccessBlock)success andFailure:(DeleteRecordFailureBlock)failure
{
    NSArray *arrayWithSingleNumber = [NSArray arrayWithObject:recordID];
    
    if ([self.recordsDAO deleteRecordsForRecordIDs:arrayWithSingleNumber])
    {
        success ();
    }
    else
    {
        failure ( @"failed to deleteRecordsForRecordIDs" );
    }
    
    return;
}

- (void) modifyRecord: (Record *) record
                   WithSuccess: (ModifyRecordSuccessBlock) success
                    andFailure: (ModifyRecordFailureBlock) failure
{
    if ( [self.recordsDAO modifyRecord:record] )
    {
        success ();
    }
    else
    {
        failure ( [NSString stringWithFormat:@"failed to modify Record: %ld", (long)record.identifer] );
    }
    
    return;
}

- (void) addReceiptForFilenames:(NSArray *)filenames success:(AddReceiptSuccessBlock)success failure:(AddReceiptFailureBlock)failure
{
    
    if (!filenames)
    {
        failure ( @"missing filenames");
        
        return;
    }
    
    if ( [self.receiptsDAO addReceiptWithFilenames:filenames] )
    {
        success ( );
    }
    else
    {
        failure ( @"unable to add receipt");
    }
    
    return;
}

@end
