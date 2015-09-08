//
//  NetworkCommunicator.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-17.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "MKNetworkEngine.h"

//#define WEBSERVICE_URL @"localhost/Celitax-WebAPI/v1"
#define WEBSERVICE_URL @"www.crave-n-save.ca/crave/Celitax-WebAPI/v1"
#define WEB_API_FILE @"/index.php"

//Common error message enums:
#define NETWORK_ERROR_NO_CONNECTIVITY       @"NETWORK_ERROR_NO_CONNECTIVITY"
#define NETWORK_UNKNOWN_ERROR               @"NETWORK_UNKNOWN_ERROR"

@interface NetworkCommunicator : MKNetworkEngine

-(MKNetworkOperation *)postDataToServer:(NSMutableDictionary *)params path:(NSString *)path;

-(MKNetworkOperation *)getRequestToServer:(NSString *)path;

-(MKNetworkOperation*) downloadFileFrom:(NSString*) remoteURL toFile:(NSString*) filePath;

- (void)cancelAndDiscardURLConnection;

@end
