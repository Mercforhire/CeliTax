//
//  OLAlertDialogsProvider.m
//  Inspection
//
//  Created by Leon Chen on 2015-03-12.
//  Copyright (c) 2015 Openlane. All rights reserved.
//

#import "AlertDialogsProvider.h"

@implementation AlertDialogsProvider

+ (void)handlerAlert:(NSString *)title message:(NSString *)message action:(NSArray<UIAlertAction*>*)actions
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (!actions || [actions count] == 0)
    {
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alertController addAction:defaultAction];
    }
    else
    {
        for (UIAlertAction *action in actions)
        {
            [alertController addAction:action];
        }
    }
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController)
    {
        topController = topController.presentedViewController;
    }
    
    [topController presentViewController:alertController animated:YES completion:nil];
}

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
