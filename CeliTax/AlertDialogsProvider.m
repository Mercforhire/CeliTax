//
//  OLAlertDialogsProvider.m
//  Inspection
//
//  Created by Leon Chen on 2015-03-12.
//  Copyright (c) 2015 Openlane. All rights reserved.
//

#import "AlertDialogsProvider.h"

@implementation AlertDialogsProvider

+ (void)showWorkInProgressDialog;
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                      message:@"Feature work in progress"
                                                     delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"Ok",nil];
    
    [message show];
}

@end
