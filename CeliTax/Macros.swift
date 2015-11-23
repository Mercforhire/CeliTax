//
//  Macros.swift
//
//  Created by Xavier Muñiz on 6/12/14.

import Foundation


// dLog and aLog macros to abbreviate NSLog.
// Use like this:
//
//   dLog("Log this!")
//
#if DEBUG
    func dLog(message: String)
    {
        NSLog(message)
    }
    
    func SWLocalizedString(key : String) -> String
    {
        return LocalizationManager.sharedInstance().localizedStringForKey(key, value: nil, table: nil)
    }
#else
    func dLog(message: String)
    {
        
    }
#endif

