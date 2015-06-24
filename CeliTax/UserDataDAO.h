//
//  UserDataDAO.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-22.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDataDAO : NSObject

@property (nonatomic, strong) NSString *userKey;

-(BOOL)loadUserData;

-(BOOL)saveUserData;

-(NSMutableArray *)getCatagories;

-(NSMutableArray *)getRecords;

-(NSMutableArray *)getReceipts;

-(NSMutableArray *)getTaxYears;

@end
