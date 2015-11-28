//
//  AlertDialogsProvider.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-23.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class AlertDialogsProvider : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    static func handlerAlert(title : String?, message : String, action actions : [UIAlertAction]?)
    {
        let alertController : UIAlertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        if (actions == nil || actions?.count == 0)
        {
            let defaultAction : UIAlertAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            alertController.addAction(defaultAction)
        }
        else
        {
            for action in actions!
            {
                alertController.addAction(action)
            }
        }
        
        var topController : UIViewController! = UIApplication.sharedApplication().keyWindow!.rootViewController
        
        while (topController.presentedViewController != nil)
        {
            topController = topController.presentedViewController
        }
        
        topController.presentViewController(alertController, animated: true, completion: nil)
    }
    
//    static func showWorkInProgressDialog()
//    {
//        let message : UIAlertView = UIAlertView.init(title: "Sorry", message: "Feature work in progress", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "Ok")
//        
//        message.show()
//    }
    
}