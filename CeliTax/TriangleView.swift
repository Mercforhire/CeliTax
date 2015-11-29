//
//  TriangleView.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-28.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class TriangleView : UIImageView
{
    func baseInit()
    {
        self.backgroundColor = UIColor.clearColor()
    
        self.setGreenArrowDown()
    }
    
    override init (frame : CGRect)
    {
        super.init(frame : frame)
        self.baseInit()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.baseInit()
    }
    
    func setGreenArrowUp()
    {
        self.image = UIImage.init(named: "greenTrianglePointUp")
    }
    
    func setGreenArrowDown()
    {
        self.image = UIImage.init(named: "greenTrianglePointDown")
    }

}