//
//  NetworkCommunicator.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-17.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "NetworkCommunicator.h"

@interface NetworkCommunicator ()

@property (nonatomic, strong) MKNetworkOperation *networkOperation;

@end

@implementation NetworkCommunicator

-(MKNetworkOperation *)postDataToServer:(NSMutableDictionary *)params path:(NSString *)path
{
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"POST" ssl:YES];
    return op;
}

-(MKNetworkOperation *)getRequestToServer:(NSString *)path
{
    MKNetworkOperation *op = [self operationWithPath:path params:nil httpMethod:@"GET" ssl:YES];
    return op;
}

-(MKNetworkOperation*) downloadFileFrom:(NSString*) remoteURL toFile:(NSString*) filePath
{
    MKNetworkOperation *op = [self operationWithURLString:remoteURL];
    
    
    [op addDownloadStream:[NSOutputStream outputStreamToFileAtPath:filePath
                                                            append:NO]];
    
    [self enqueueOperation:op];
    
    return op;
}

- (void)cancelAndDiscardURLConnection
{
    [self.networkOperation cancel];
    self.networkOperation = nil;
}

-(void)dealloc
{
    [self.networkOperation cancel];
}

@end
