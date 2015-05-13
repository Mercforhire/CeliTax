//
//  RegisterResult.h
//  CeliTax
//
//  Created by Leon Chen on 2015-04-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegisterResult : NSObject

@property BOOL success;
@property (nonatomic, strong) NSString *message;

@end
