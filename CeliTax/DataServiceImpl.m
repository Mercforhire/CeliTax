//
//  DataServiceImpl.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "DataServiceImpl.h"
#import "Catagory.h"
#import "Record.h"
#import "CatagoriesDAO.h"
#import "ReceiptsDAO.h"
#import "RecordsDAO.h"
#import "Receipt.h"

@interface DataServiceImpl ()

@end

@implementation DataServiceImpl

-(void)loadDemoData
{
    if (![self.catagoriesDAO loadCatagories].count)
    {
        //add some demo data
        Catagory *itemCatagory1 = [Catagory new];
        itemCatagory1.identifer = 0;
        itemCatagory1.name = @"Rice";
        itemCatagory1.color = [UIColor yellowColor];
        itemCatagory1.nationalAverageCost = 10.5f;
        
        Catagory *itemCatagory2 = [Catagory new];
        itemCatagory2.identifer = 1;
        itemCatagory2.name = @"Bread";
        itemCatagory2.color = [UIColor orangeColor];
        
        Catagory *itemCatagory3 = [Catagory new];
        itemCatagory3.identifer = 2;
        itemCatagory3.name = @"Meat";
        itemCatagory1.nationalAverageCost = 7.5f;
        itemCatagory3.color = [UIColor redColor];
        
        Catagory *itemCatagory4 = [Catagory new];
        itemCatagory4.identifer = 3;
        itemCatagory4.name = @"Flour";
        itemCatagory4.color = [UIColor lightGrayColor];
        itemCatagory4.nationalAverageCost = 5.0f;
        
        [self.catagoriesDAO addCatagory:itemCatagory1];
        [self.catagoriesDAO addCatagory:itemCatagory2];
        [self.catagoriesDAO addCatagory:itemCatagory3];
        [self.catagoriesDAO addCatagory:itemCatagory4];
    }
    
    if (![self.recordsDAO loadRecords].count)
    {
        //add some demo data
        NSMutableArray *records = [NSMutableArray new];
        
        Record *record1 = [Record new];
        record1.identifer = records.count;
        record1.catagoryID = 0;
        record1.catagoryName = @"Rice";
        record1.receiptID = 0;
        record1.quantity = 2;
        record1.amount = 2.5f;
        [records addObject:record1];
        
        Record *record2 = [Record new];
        record2.identifer = records.count;
        record2.catagoryID = 0;
        record2.catagoryName = @"Rice";
        record2.receiptID = 1;
        record2.quantity = 1;
        record2.amount = 5.0f;
        [records addObject:record2];
        
        Record *record3 = [Record new];
        record3.identifer = records.count;
        record3.catagoryID = 1;
        record3.catagoryName = @"Bread";
        record3.receiptID = 1;
        record3.quantity = 3;
        record3.amount = 6.0f;
        [records addObject:record3];
        
        Record *record4 = [Record new];
        record4.identifer = records.count;
        record4.catagoryID = 2;
        record4.catagoryName = @"Meat";
        record4.receiptID = 1;
        record4.quantity = 5;
        record4.amount = 20.0f;
        [records addObject:record4];
        
        [self.recordsDAO addRecords:records];
    }
    
    if (![self.receiptsDAO loadReceipts].count)
    {
        //add some demo data
        [self.receiptsDAO addReceiptWithFilenames:[NSArray arrayWithObjects:@"ReceiptPic-1.jpg", @"ReceiptPic-2.jpg", nil]];
        
        [self.receiptsDAO addReceiptWithFilenames:[NSArray arrayWithObjects:@"ReceiptPic-1.jpg", @"ReceiptPic-2.jpg", nil]];
    }
}

- (NSOperation *) fetchCatagoriesSuccess:(FetchCatagoriesSuccessBlock)success failure:(FetchCatagoriesFailureBlock)failure
{
    NSArray *catagories = [self.catagoriesDAO loadCatagories];
    
    success ( catagories );
    
    return nil;
}

- (NSOperation *) fetchAllRecordsSuccess:(FetchRecordsSuccessBlock)success failure:(FetchRecordsFailureBlock)failure
{
    NSArray *records = [self.recordsDAO loadRecords];
    
    success ( records );
    
    return nil;
}

- (NSOperation *) fetchRecordsForCatagoryID:(NSInteger)catagoryID success:(FetchRecordsSuccessBlock)success failure:(FetchRecordsFailureBlock)failure
{
    NSArray *records = [self.recordsDAO loadRecordsforCatagory:catagoryID];
    
    success ( records );
    
    return nil;
}

- (NSOperation *) fetchRecordsForReceiptID:(NSInteger)receiptID success:(FetchRecordsSuccessBlock)success failure:(FetchRecordsFailureBlock)failure
{
    NSArray *records = [self.recordsDAO loadRecordsforReceipt:receiptID];
    
    success ( records );
    
    return nil;
}

- (NSOperation *) fetchReceiptsSuccess:(FetchReceiptsSuccessBlock)success failure:(FetchReceiptsFailureBlock)failure
{
    NSArray *receipts = [self.receiptsDAO loadReceipts];
    
    success ( receipts );
    
    return nil;
}

- (NSOperation *) fetchNewestTenReceiptInfoSuccess:(FetchReceiptInfoSuccessBlock)success failure:(FetchReceiptInfoFailureBlock)failure
{
    NSMutableArray *receiptInfos = [NSMutableArray new];
    
    NSArray *receipts = [self.receiptsDAO loadReceipts];
    
    for (Receipt *receipt in receipts)
    {
        NSMutableDictionary *receiptInfo = [NSMutableDictionary new];
        
        [receiptInfo setObject:[NSNumber numberWithInteger:receipt.identifer] forKeyedSubscript:kReceiptIDKey];
        [receiptInfo setObject:receipt.dateCreated forKeyedSubscript:kUploadTimeKey];
        
        NSMutableArray *receiptColors = [NSMutableArray new];
        
        float totalAmountForReceipt = 0.0f;
        
        //get all catagories for this receipt
        NSArray *records = [self.recordsDAO loadRecordsforReceipt:receipt.identifer];
        
        for (Record *record in records)
        {
            Catagory *catagory = [self.catagoriesDAO loadCatagory:record.catagoryID];
            
            [receiptColors addObject:catagory.color];
            
            totalAmountForReceipt = totalAmountForReceipt + record.quantity * record.amount;
        }
        
        [receiptInfo setObject:receiptColors forKey:kColorsKey];
        [receiptInfo setObject:[NSNumber numberWithFloat:totalAmountForReceipt] forKey:kTotalAmountKey];
        
        [receiptInfos insertObject:receiptInfo atIndex:0];
    }
    
    success ( receiptInfos );
    
    return nil;
}

- (NSOperation *) fetchReceiptForReceiptID:(NSInteger)receiptID success:(FetchReceiptSuccessBlock)success failure:(FetchReceiptFailureBlock)failure
{
    Receipt *receipt;
    
    success ( receipt );
    
    return nil;
}

@end
