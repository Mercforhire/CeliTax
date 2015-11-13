//
//  UIViewExtension.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-12.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

extension UIView
{
    func scrollToY(y : CGFloat)
    {
        UIView.beginAnimations("registerScroll", context: nil)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        UIView.setAnimationDuration(0.4)
        self.transform = CGAffineTransformMakeTranslation(0, y)
        UIView.commitAnimations()
    }
    
    func scrollToView(view : UIView)
    {
        let theFrame : CGRect = view.frame
        var y : CGFloat = theFrame.origin.y - 15
        y -= (y/1.7)
        self.scrollToY(-y)
    }
}