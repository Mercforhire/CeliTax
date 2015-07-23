//
//  NetworkCommunicator.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-17.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "MKNetworkEngine.h"

#define WEBSERVICE_URL @"localhost/v1"
//#define WEBSERVICE_URL @"www.crave-n-save.ca/crave/Celitax-WebAPI/v1"
#define WEB_API_FILE @"/index.php"

@interface NetworkCommunicator : MKNetworkEngine

-(MKNetworkOperation *)postDataToServer:(NSMutableDictionary *)params path:(NSString *)path;

-(MKNetworkOperation *)getRequestToServer:(NSString *)path;

-(MKNetworkOperation*) downloadFileFrom:(NSString*) remoteURL toFile:(NSString*) filePath;

- (void)cancelAndDiscardURLConnection;

@end
