//
//  DataServiceImpl.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "DataServiceImpl.h"
#import "ItemCatagory.h"
#import "CatagoryRecord.h"
#import "CatagoriesDAO.h"
#import "Receipt.h"

#define testKey         @"testKey"

@interface DataServiceImpl ()

@end

@implementation DataServiceImpl

-(void)setCatagoriesDAO:(CatagoriesDAO *)catagoriesDAO
{
    _catagoriesDAO = catagoriesDAO;
    
    if (![self.catagoriesDAO loadCatagoriesForUser:testKey])
    {
        //add some demo data
        ItemCatagory *itemCatagory1 = [ItemCatagory new];
        itemCatagory1.identifer = 0;
        itemCatagory1.name = @"Rice";
        itemCatagory1.color = [UIColor yellowColor];
        itemCatagory1.nationalAverageCost = 10.5f;
        
        ItemCatagory *itemCatagory2 = [ItemCatagory new];
        itemCatagory2.identifer = 1;
        itemCatagory2.name = @"Bread";
        itemCatagory2.color = [UIColor orangeColor];
        
        ItemCatagory *itemCatagory3 = [ItemCatagory new];
        itemCatagory3.identifer = 2;
        itemCatagory3.name = @"Meat";
        itemCatagory1.nationalAverageCost = 7.5f;
        itemCatagory3.color = [UIColor redColor];
        
        ItemCatagory *itemCatagory4 = [ItemCatagory new];
        itemCatagory4.identifer = 3;
        itemCatagory4.name = @"Flour";
        itemCatagory4.color = [UIColor lightGrayColor];
        itemCatagory4.nationalAverageCost = 5.0f;
        
        [self.catagoriesDAO addCatagoryForUser:testKey withCatagory:itemCatagory1];
        [self.catagoriesDAO addCatagoryForUser:testKey withCatagory:itemCatagory2];
        [self.catagoriesDAO addCatagoryForUser:testKey withCatagory:itemCatagory3];
        [self.catagoriesDAO addCatagoryForUser:testKey withCatagory:itemCatagory4];
    }
    
    if (![self.catagoriesDAO loadCatagoryRecordsForUser:testKey])
    {
        //add some demo data
        NSMutableArray *catagoryRecords = [NSMutableArray new];
        
        CatagoryRecord *catagoryRecord1 = [CatagoryRecord new];
        catagoryRecord1.identifer = catagoryRecords.count;
        catagoryRecord1.itemCatagoryID = 0;
        catagoryRecord1.itemCatagoryName = @"Rice";
        catagoryRecord1.receiptID = 0;
        catagoryRecord1.quantity = 2;
        catagoryRecord1.amount = 2.5f;
        [catagoryRecords addObject:catagoryRecord1];
        
        CatagoryRecord *catagoryRecord2 = [CatagoryRecord new];
        catagoryRecord2.identifer = catagoryRecords.count;
        catagoryRecord2.itemCatagoryID = 0;
        catagoryRecord2.itemCatagoryName = @"Rice";
        catagoryRecord2.receiptID = 1;
        catagoryRecord2.quantity = 1;
        catagoryRecord2.amount = 5.0f;
        [catagoryRecords addObject:catagoryRecord2];
        
        CatagoryRecord *catagoryRecord3 = [CatagoryRecord new];
        catagoryRecord3.identifer = catagoryRecords.count;
        catagoryRecord3.itemCatagoryID = 1;
        catagoryRecord3.itemCatagoryName = @"Bread";
        catagoryRecord3.receiptID = 1;
        catagoryRecord3.quantity = 3;
        catagoryRecord3.amount = 6.0f;
        [catagoryRecords addObject:catagoryRecord3];
        
        CatagoryRecord *catagoryRecord4 = [CatagoryRecord new];
        catagoryRecord4.identifer = catagoryRecords.count;
        catagoryRecord4.itemCatagoryID = 2;
        catagoryRecord4.itemCatagoryName = @"Meat";
        catagoryRecord4.receiptID = 1;
        catagoryRecord4.quantity = 5;
        catagoryRecord4.amount = 20.0f;
        [catagoryRecords addObject:catagoryRecord4];
        
        [self.catagoriesDAO addCatagoryRecordsForUser:testKey andRecords:catagoryRecords];
    }
    
    if (![self.catagoriesDAO loadReceiptsForUser:testKey] || ![self.catagoriesDAO loadReceiptsForUser:testKey].count)
    {
        //add some demo data
        [self.catagoriesDAO addReceiptForUser:testKey withFilenames:[NSArray arrayWithObjects:@"ReceiptPic-1.jpg", @"ReceiptPic-2.jpg", nil]];
        
        [self.catagoriesDAO addReceiptForUser:testKey withFilenames:[NSArray arrayWithObjects:@"ReceiptPic-1.jpg", @"ReceiptPic-2.jpg", nil]];
    }
}

- (NSOperation *) fetchCatagoriesForUserKey: (NSString *) userKey
                                    success: (FetchCatagoriesSuccessBlock) success
                                    failure: (FetchCatagoriesFailureBlock) failure
{
    NSArray *catagories = [self.catagoriesDAO loadCatagoriesForUser:userKey];
    
    if ( userKey )
    {
        success ( catagories );
    }
    else
    {
        failure ( @"user key not found");
    }
    
    return nil;
}

- (NSOperation *) fetchAllCatagoryRecordsForUserKey: (NSString *) userKey
                                            success: (FetchCatagoryRecordsSuccessBlock) success
                                            failure: (FetchCatagoryRecordsFailureBlock) failure
{
    if (userKey)
    {
        NSArray *catagoryRecords = [self.catagoriesDAO loadCatagoryRecordsForUser:userKey];
        
        success ( catagoryRecords );
    }
    else
    {
        failure ( @"userKey can't be nil" );
    }
    
    return nil;
}

- (NSOperation *) fetchCatagoryRecordsForUserKey: (NSString *) userKey
                                   forCatagoryID: (NSInteger) catagoryID
                                         success: (FetchCatagoryRecordsSuccessBlock) success
                                         failure: (FetchCatagoryRecordsFailureBlock) failure
{
    if (userKey)
    {
        NSArray *catagoryRecords = [self.catagoriesDAO loadCatagoryRecordsForUser:userKey forCatagory:catagoryID];
        
        success ( catagoryRecords );
    }
    else
    {
        failure ( @"userKey can't be nil" );
    }
    
    return nil;
}

- (NSOperation *) fetchCatagoryRecordsForUserKey: (NSString *) userKey
                                    forReceiptID: (NSInteger) receiptID
                                         success: (FetchCatagoryRecordsSuccessBlock) success
                                         failure: (FetchCatagoryRecordsFailureBlock) failure
{
    if (userKey)
    {
        NSArray *catagoryRecords = [self.catagoriesDAO loadCatagoryRecordsForUser:userKey forReceipt:receiptID];
        
        success ( catagoryRecords );
    }
    else
    {
        failure ( @"userKey can't be nil" );
    }
    
    return nil;
}

- (NSOperation *) fetchReceiptsForUserKey: (NSString *) userKey
                                  success: (FetchReceiptsSuccessBlock) success
                                  failure: (FetchReceiptsFailureBlock) failure
{
    if (userKey)
    {
        NSArray *receipts = [self.catagoriesDAO loadReceiptsForUser:userKey];
        
        success ( receipts );
    }
    else
    {
        failure ( @"userKey can't be nil" );
    }
    
    return nil;
}

- (NSOperation *) fetchNewestTenReceiptInfoForUserKey: (NSString *) userKey
                                              success: (FetchReceiptInfoSuccessBlock) success
                                              failure: (FetchReceiptInfoFailureBlock) failure
{
    if (userKey)
    {
        NSMutableArray *receiptInfos = [NSMutableArray new];
        
        NSArray *receipts = [self.catagoriesDAO loadReceiptsForUser:userKey];
        
        for (Receipt *receipt in receipts)
        {
            NSMutableDictionary *receiptInfo = [NSMutableDictionary new];
            
            [receiptInfo setObject:[NSNumber numberWithInteger:receipt.identifer] forKeyedSubscript:kReceiptIDKey];
            [receiptInfo setObject:receipt.dateCreated forKeyedSubscript:kUploadTimeKey];
            
            NSMutableArray *receiptColors = [NSMutableArray new];
            
            float totalAmountForReceipt = 0.0f;
            
            //get all catagories for this receipt
            NSArray *records = [self.catagoriesDAO loadCatagoryRecordsForUser:userKey forReceipt:receipt.identifer];
            
            for (CatagoryRecord *record in records)
            {
                ItemCatagory *catagory = [self.catagoriesDAO loadCatagoryForUser:userKey withCatagoryID:record.itemCatagoryID];
                
                [receiptColors addObject:catagory.color];
                
                totalAmountForReceipt = totalAmountForReceipt + record.quantity * record.amount;
            }
            
            [receiptInfo setObject:receiptColors forKey:kColorsKey];
            [receiptInfo setObject:[NSNumber numberWithFloat:totalAmountForReceipt] forKey:kTotalAmountKey];
            
            [receiptInfos insertObject:receiptInfo atIndex:0];
        }
        
        success ( receiptInfos );
    }
    else
    {
        failure ( @"userKey can't be nil" );
    }
    
    return nil;
}

@end
