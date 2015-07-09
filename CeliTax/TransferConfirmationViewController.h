//
//  TransferConfirmationViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-06-28.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"

@protocol TransferConfirmationViewProtocol <NSObject>

- (void) confirmTransferPressed;

@end

@interface TransferConfirmationViewController : BaseViewController

@property CGSize viewSize;

@property (nonatomic, weak) id <TransferConfirmationViewProtocol> delegate;

@end
