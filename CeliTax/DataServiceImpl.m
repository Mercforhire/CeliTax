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
#import "Utils.h"

@interface DataServiceImpl ()

@end

@implementation DataServiceImpl

-(void)loadDemoData
{
    if (![self.catagoriesDAO loadCatagories].count)
    {
        //add some demo data
        [self.catagoriesDAO addCatagoryForName:@"Rice" andColor:[UIColor yellowColor] andNationalAverageCost:2.5f];
        
        [self.catagoriesDAO addCatagoryForName:@"Bread" andColor:[UIColor orangeColor] andNationalAverageCost:0];
        
        [self.catagoriesDAO addCatagoryForName:@"Meat" andColor:[UIColor redColor] andNationalAverageCost:7.5f];
        
        [self.catagoriesDAO addCatagoryForName:@"Flour" andColor:[UIColor lightGrayColor] andNationalAverageCost:5.0f];
    }
    
    if (![self.receiptsDAO loadReceipts].count)
    {
        //add some demo data
        [self.receiptsDAO addReceiptWithFilenames:[NSArray arrayWithObjects:@"ReceiptPic-1", @"ReceiptPic-2", nil]];
        
        [self.receiptsDAO addReceiptWithFilenames:[NSArray arrayWithObjects:@"ReceiptPic-1", @"ReceiptPic-2", nil]];
        
        UIImage *testImage1 = [UIImage imageNamed:@"ReceiptPic-1.jpg"];
        UIImage *testImage2 = [UIImage imageNamed:@"ReceiptPic-2.jpg"];
        
        [Utils saveImage:testImage1 withFilename:@"ReceiptPic-1" forUser:@"testKey"];
        [Utils saveImage:testImage2 withFilename:@"ReceiptPic-2" forUser:@"testKey"];
    }
    
    if (![self.recordsDAO loadRecords].count)
    {
        [self.recordsDAO addRecordForCatagory:[[self.catagoriesDAO loadCatagories] firstObject]
                                   andReceipt:[[self.receiptsDAO loadReceipts] firstObject]
                                  forQuantity:2
                                    forAmount:2.5f];
        
        [self.recordsDAO addRecordForCatagory:[[self.catagoriesDAO loadCatagories] objectAtIndex:1]
                                   andReceipt:[[self.receiptsDAO loadReceipts] firstObject]
                                  forQuantity:1
                                    forAmount:5.0f];
        
        [self.recordsDAO addRecordForCatagory:[[self.catagoriesDAO loadCatagories] objectAtIndex:2]
                                   andReceipt:[[self.receiptsDAO loadReceipts] firstObject]
                                  forQuantity:3
                                    forAmount:6.0f];
        
        [self.recordsDAO addRecordForCatagory:[[self.catagoriesDAO loadCatagories] lastObject]
                                   andReceipt:[[self.receiptsDAO loadReceipts] lastObject]
                                  forQuantity:5
                                    forAmount:20.0f];
    }
}

- (NSOperation *) fetchCatagoriesSuccess:(FetchCatagoriesSuccessBlock)success failure:(FetchCatagoriesFailureBlock)failure
{
    NSArray *catagories = [self.catagoriesDAO loadCatagories];
    
    if (catagories && catagories.count)
    {
        success ( catagories );
    }
    else
    {
        failure ( @"catagories not found");
    }
    
    return nil;
}

- (NSOperation *) fetchAllRecordsSuccess:(FetchRecordsSuccessBlock)success failure:(FetchRecordsFailureBlock)failure
{
    NSArray *records = [self.recordsDAO loadRecords];
    
    if (records && records.count)
    {
        success ( records );
    }
    else
    {
        failure ( @"records not found");
    }
    
    return nil;
}

- (NSOperation *) fetchRecordsForCatagoryID:(NSString *)catagoryID success:(FetchRecordsSuccessBlock)success failure:(FetchRecordsFailureBlock)failure
{
    NSArray *records = [self.recordsDAO loadRecordsforCatagory:catagoryID];
    
    if (records && records.count)
    {
        success ( records );
    }
    else
    {
        failure ( @"records not found");
    }
    
    return nil;
}

- (NSOperation *) fetchRecordsForReceiptID:(NSString *)receiptID success:(FetchRecordsSuccessBlock)success failure:(FetchRecordsFailureBlock)failure
{
    NSArray *records = [self.recordsDAO loadRecordsforReceipt:receiptID];
    
    if (records && records.count)
    {
        success ( records );
    }
    else
    {
        failure ( @"records not found");
    }
    
    return nil;
}

- (NSOperation *) fetchRecordForID: (NSString *) recordID
                           success: (FetchRecordSuccessBlock) success
                           failure: (FetchRecordFailureBlock) failure
{
    Record *record = [self.recordsDAO loadRecord:recordID];
    
    if (record)
    {
        success ( record );
    }
    else
    {
        failure ( @"record not found" );
    }
    
    return nil;
}

- (NSOperation *) fetchReceiptsSuccess:(FetchReceiptsSuccessBlock)success failure:(FetchReceiptsFailureBlock)failure
{
    NSArray *receipts = [self.receiptsDAO loadReceipts];
    
    if (receipts && receipts.count)
    {
        success ( receipts );
    }
    else
    {
        failure ( @"receipts not found");
    }
    
    return nil;
}

- (NSOperation *) fetchNewest5ReceiptInfoSuccess:(FetchReceiptInfoSuccessBlock)success failure:(FetchReceiptInfoFailureBlock)failure
{
    NSMutableArray *receiptInfos = [NSMutableArray new];
    
    NSArray *receipts = [self.receiptsDAO loadLast5Receipts];
    
    for (Receipt *receipt in receipts)
    {
        NSMutableDictionary *receiptInfo = [NSMutableDictionary new];
        
        [receiptInfo setObject:receipt.identifer forKeyedSubscript:kReceiptIDKey];
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

- (NSOperation *) fetchReceiptForReceiptID:(NSString *)receiptID success:(FetchReceiptSuccessBlock)success failure:(FetchReceiptFailureBlock)failure
{
    Receipt *receipt = [self.receiptsDAO loadReceipt:receiptID];
    
    if (receipt)
    {
        success ( receipt );
    }
    else
    {
        failure ( @"Receipt not found" );
    }
    
    return nil;
}

@end
