//
//  TransferSelectionsViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-06-29.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"

@protocol TransferSelectionsViewProtocol <NSObject>

@required

- (void) selectedTransferSelectionAtIndex: (NSInteger) index;

@end

@interface TransferSelectionsViewController : BaseViewController

@property (nonatomic, strong) NSArray *selections;

@property (nonatomic) NSInteger highlightedSelectionIndex;

@property (nonatomic, weak) id <TransferSelectionsViewProtocol> delegate;

@end
