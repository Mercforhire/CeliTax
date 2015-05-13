//
//  Receipt.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-06.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "Receipt.h"

#define kKeyIdentiferKey        @"Identifer"
#define kKeyFileNamesKey        @"FileNames"
#define kKeyDateCreatedKey      @"DateCreated"

@implementation Receipt

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:self.identifer     forKey:kKeyIdentiferKey];
    [coder encodeObject:self.fileNames    forKey:kKeyFileNamesKey];
    [coder encodeObject:self.dateCreated    forKey:kKeyDateCreatedKey];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    
    self.identifer = [coder decodeIntegerForKey:kKeyIdentiferKey];
    
    NSArray *fileNames = [coder decodeObjectForKey:kKeyFileNamesKey];
    self.fileNames = [[NSMutableArray alloc] initWithArray:fileNames copyItems:NO];
    
    self.dateCreated = [coder decodeObjectForKey:kKeyDateCreatedKey];
    
    return self;
}

@end
