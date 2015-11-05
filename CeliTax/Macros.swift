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
    func dLog(message: String, filename: NSString = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        NSLog("[\(filename.lastPathComponent):\(line)] \(function) - \(message)")
    }
#else
    func dLog(message: String, filename: NSString = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
    }
#endif
func aLog(message: String, filename: NSString = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
    NSLog("[\(filename.lastPathComponent):\(line)] \(function) - \(message)")
}
