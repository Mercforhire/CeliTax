//
//  SendReceiptsToViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-06-08.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol SendReceiptsViewPopUpDelegate <NSObject>

@required

-(void)sendReceiptsToEmailRequested:(NSString *)emailAddress;

@end

@interface SendReceiptsToViewController : BaseViewController

@property CGSize viewSize;

@property (nonatomic, weak) id <SendReceiptsViewPopUpDelegate> delegate;

@end
