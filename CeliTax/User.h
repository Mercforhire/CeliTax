//
//  User.h
//  CeliTax
//
//  Created by Leon Chen on 2015-04-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject <NSCoding>

@property (nonatomic, copy) NSString *loginName;
@property (nonatomic, copy) NSString *userKey;

@property (nonatomic, copy) NSString *firstname;
@property (nonatomic, copy) NSString *lastname;

@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *postalCode;
@property (nonatomic, copy) NSString *country;

@end
