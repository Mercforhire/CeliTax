//
//  AuthorizeResult.h
//  CeliTax
//
//  Created by Leon Chen on 2015-04-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthorizeResult : NSObject

@property BOOL success;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userAPIKey;

@property (nonatomic, copy) NSString *firstname;
@property (nonatomic, copy) NSString *lastname;

@property (nonatomic, copy) NSString *postalCode;
@property (nonatomic, copy) NSString *country;

@end
