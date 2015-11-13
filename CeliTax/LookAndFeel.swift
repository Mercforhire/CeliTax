//
//  LookAndFeel.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-12.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation
import UIKit

@objc
class LookAndFeel : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    var navBarColor: UIColor {
        
        get {
            
            return UIColor.init(red: 116.0/255.0, green: 191.0/255.0, blue: 81.0/255.0, alpha: 1)
        }
    }
    
    var appGreenColor: UIColor {
        
        get {
            
            return UIColor.init(red: 158.0/255.0, green: 216.0/255.0, blue: 113.0/255.0, alpha: 1)
        }
    }
    
    func addLeftInsetToTextField(textField : UITextField!)
    {
        let paddingView : UIView = UIView.init(frame: CGRectMake(0, 0, 12, 12))
        paddingView.backgroundColor = UIColor.clearColor()
        
        textField.leftViewMode = UITextFieldViewMode.Always
        textField.leftView = paddingView
    }
    
    func removeBorderFor(view : UIView?)
    {
        view?.layer.borderWidth = 0
        view?.clipsToBounds = true
    }
    
    func applyWhiteBorderTo(view : UIView?)
    {
        view?.layer.cornerRadius = 2.0
        view?.layer.borderColor = UIColor.whiteColor().CGColor
        view?.layer.borderWidth = 1.0
        view?.clipsToBounds = true
    }
    
    func applyGrayBorderTo(view : UIView?)
    {
        view?.layer.cornerRadius = 2.0
        view?.layer.borderColor = UIColor.init(white: 187.0/255.0, alpha: 1).CGColor
        view?.layer.borderWidth = 1.0
        view?.clipsToBounds = true
    }
    
    func applyGreenBorderTo(view : UIView?)
    {
        view?.layer.cornerRadius = 2.0
        view?.layer.borderColor = self.appGreenColor.CGColor
        view?.layer.borderWidth = 1.0
        view?.clipsToBounds = true
    }
    
    
    func darkerColorFrom(originalColor : UIColor!) -> UIColor!
    {
        var h : CGFloat = 0.0
        var s : CGFloat = 0.0
        var b : CGFloat = 0.0
        var a : CGFloat = 0.0
        
        originalColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        return UIColor.init(hue: h, saturation: s, brightness: b * 0.75, alpha: a)
    }
    
    func applySlightlyDarkerBorderTo(view : UIView?)
    {
        let viewColor : UIColor? = view?.backgroundColor
        
        if (viewColor != nil)
        {
            view?.layer.cornerRadius = 2.0
            view?.layer.borderColor = self.darkerColorFrom(viewColor!).CGColor;
            view?.layer.borderWidth = 1.0
            view?.clipsToBounds = true
        }
    }
    
    func applyNormalButtonStyleTo(button : UIButton?)
    {
        button?.backgroundColor = UIColor.whiteColor()
        button?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.applyGreenBorderTo(button)
    }
    
    func applyHollowGreenButtonStyleTo(button : UIButton?)
    {
        button?.backgroundColor = UIColor.whiteColor()
        button?.layer.cornerRadius = 3.0
        button?.layer.borderColor = self.appGreenColor.CGColor
        button?.layer.borderWidth = 1.0
        
        button?.layer.shadowColor = self.appGreenColor.CGColor
        button?.layer.shadowOffset = CGSizeMake(0, 1.5)
        button?.layer.shadowOpacity = 1
        button?.layer.shadowRadius = 0
        button?.clipsToBounds = false
        
        button?.setTitleColor(self.appGreenColor, forState: UIControlState.Normal)
    }
    
    func applyHollowWhiteButtonStyleTo(button : UIButton?)
    {
        button?.backgroundColor = self.appGreenColor
        button?.layer.cornerRadius = 3.0
        button?.layer.borderColor = UIColor.whiteColor().CGColor
        button?.layer.borderWidth = 1.0
        
        button?.layer.shadowColor = UIColor.whiteColor().CGColor
        button?.layer.shadowOffset = CGSizeMake(0, 1.5)
        button?.layer.shadowOpacity = 1
        button?.layer.shadowRadius = 0
        button?.clipsToBounds = false
        
        button?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    func applySolidGreenButtonStyleTo(button : UIButton?)
    {
        button?.backgroundColor = self.appGreenColor
        button?.layer.cornerRadius = 3.0
        button?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button?.clipsToBounds = true
        button?.layer.borderWidth = 0
    }
    
    func applyTransperantWhiteTextButtonStyleTo(button : UIButton?)
    {
        button?.backgroundColor = UIColor.clearColor()
        button?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button?.clipsToBounds = true
    }
    
    
    func applyDisabledButtonStyleTo(button : UIButton?)
    {
        button?.backgroundColor = UIColor.lightGrayColor()
        button?.layer.cornerRadius = 3.0
        button?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button?.clipsToBounds = true
        
        self.applySlightlyDarkerBorderTo(button)
    }
}