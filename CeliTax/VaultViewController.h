//
//  VaultViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"

typedef void (^RevealBlock)();

@interface VaultViewController : BaseViewController

- (id)initWithRevealBlock:(RevealBlock)revealBlock;

@end
