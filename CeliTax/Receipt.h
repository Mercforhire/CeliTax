//
//  Receipt.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-06.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Receipt : NSObject <NSCoding>

@property (nonatomic, copy) NSString    *identifer;

@property NSMutableArray                *fileNames;

@property (nonatomic, strong) NSDate    *dateCreated;

@end
