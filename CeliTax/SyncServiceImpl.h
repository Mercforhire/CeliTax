//
//  SyncServiceImpl.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-13.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncService.h"

@interface SyncServiceImpl : NSObject <SyncService>

@property (nonatomic, strong) UserDataDAO *userDataDAO;

@end
