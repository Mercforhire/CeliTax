//
//  Utils.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-07.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation
import UIKit

@objc
class Utils : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    static func unarchiveFile(path : String!) -> AnyObject?
    {
        let archive : AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithFile(path)
        
        if (archive != nil)
        {
            dLog( String(format: "File read from path %@", path) )
            
            return archive
        }
        
        dLog( String(format: "Unable to unarchive file %@", path ) )
        
        if ( NSFileManager.defaultManager().fileExistsAtPath(path) )
        {
            do
            {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            }
            catch
            {
                
            }
        }
        
        return nil
    }
    
    static func archiveFile(objectToArchive : AnyObject!, path : String!) -> Bool
    {
        let pathOnly: String = path.stringByDeletingLastPathComponent
        
        if (!NSFileManager.defaultManager().fileExistsAtPath(pathOnly))
        {
            do
            {
                try NSFileManager.defaultManager().createDirectoryAtPath(pathOnly, withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                return false
            }
        }
        
        if (NSKeyedArchiver.archiveRootObject(objectToArchive, toFile: path))
        {
            dLog(String(format: "File saved to %@", path))
            
            return true
        }
        
        return false
    }
    
    static func getSavedProfilePath() -> String
    {
        let storagePath : String! = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last
        
        let profileFilePath : String = storagePath.stringByAppendingPathComponent("CURRENT_USER.acc")
        
        return profileFilePath
    }
    
    static func loadSavedUser() -> User?
    {
        let profilePath : String! = self.getSavedProfilePath()
        
        if ( NSFileManager.defaultManager().fileExistsAtPath(profilePath) )
        {
            let savedUser : User? = self.unarchiveFile(profilePath) as? User
            
            return savedUser
        }
        
        return nil
    }
    
    static func saveUser(user : User!) -> Bool
    {
        let profilePath : String! = self.getSavedProfilePath()
        
        if ( Utils.archiveFile(user, path: profilePath) )
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    static func deleteSavedUser() -> Bool
    {
        let fileManager : NSFileManager = NSFileManager.defaultManager()
        
        let profilePath : String! = self.getSavedProfilePath()
        
        if ( fileManager.fileExistsAtPath(profilePath) )
        {
            do
            {
                try NSFileManager.defaultManager().removeItemAtPath(profilePath)
            }
            catch
            {
                return false
            }
            
            return true
        }
        
        return false
    }
    
    static func getProfileImagePathForUser(userKey : String!) -> String!
    {
        let storagePath : String! = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last
        
        let imageFilePath : String = storagePath.stringByAppendingPathComponent( String(format: "PROFILE_IMAGE-%ld.jpg",userKey.hash) )
        
        return imageFilePath
    }
    
    static func readProfileImageForUser(userKey : String!) -> UIImage?
    {
        let fileManager : NSFileManager = NSFileManager.defaultManager()
        
        let imageFilePath : String = self.getProfileImagePathForUser(userKey)
        
        if (!fileManager.fileExistsAtPath(imageFilePath))
        {
            return nil
        }
        
        // get the NSData from UIImage
        let imageData : NSData! = NSData.init(contentsOfFile: imageFilePath)
        
        let image : UIImage! = UIImage.init(data: imageData)
        
        return image
    }
    
    static func setProfileImageForUser(userKey : String!, image : UIImage!)
    {
        let fileManager : NSFileManager = NSFileManager.defaultManager()
        
        let profileImageFilePath : String! = Utils.getProfileImagePathForUser(userKey)
        
        // delete the old file if it exists
        if ( fileManager.fileExistsAtPath(profileImageFilePath) )
        {
            do
            {
                try NSFileManager.defaultManager().removeItemAtPath(profileImageFilePath)
            }
            catch
            {
                
            }
        }
        
        // get the NSData from UIIMage
        let imageData : NSData! = UIImageJPEGRepresentation(image, 0.9)
        
        imageData.writeToFile(profileImageFilePath, atomically: true)
    }
    
    static func deleteProfileImageForUser(userKey : String!) -> Bool
    {
        let fileManager : NSFileManager = NSFileManager.defaultManager()
        
        let imageFilePath : String = self.getProfileImagePathForUser(userKey)
        
        if ( fileManager.fileExistsAtPath(imageFilePath) )
        {
            dLog("Deleting profile image...")
            
            do
            {
                try NSFileManager.defaultManager().removeItemAtPath(imageFilePath)
                
                return true
            }
            catch
            {
                
            }
        }
        
        return false
    }
    
    static func getImageStorageFolderPathForUser(userKey : String!) -> String!
    {
        let storagePath : String! = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last
        
        let imageFolderName : String = String(format: "/Images-%ld", userKey.hash)
        
        let imageFolderPath : String = storagePath.stringByAppendingString(imageFolderName)
        
        return imageFolderPath
    }
    
    static func getFilePathForImage(fileName : String!, userKey : String!) -> String!
    {
        let imageFolderPath : String = self.getImageStorageFolderPathForUser(userKey)
        
        let fileManager : NSFileManager = NSFileManager.defaultManager()
        
        if (!fileManager.fileExistsAtPath(imageFolderPath))
        {
            do
            {
                try NSFileManager.defaultManager().createDirectoryAtPath(imageFolderPath, withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                
            }
        }
        
        let imageFilePath : String = imageFolderPath.stringByAppendingPathComponent(String(format:"%@.jpg", fileName))
        
        return imageFilePath
    }
    
    static func saveImage(image : UIImage!, filename : String!, userKey : String!) -> String!
    {
        let fileManager : NSFileManager = NSFileManager.defaultManager()
        
        let imageFolderPath : String = self.getImageStorageFolderPathForUser(userKey)
        
        if (!fileManager.fileExistsAtPath(imageFolderPath))
        {
            do
            {
                try NSFileManager.defaultManager().createDirectoryAtPath(imageFolderPath, withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                assert(false, "NSFileManager ERROR")
            }
        }
        
        let imageFilePath : String = imageFolderPath.stringByAppendingPathComponent(String(format: "%@.jpg", filename))
        
        // delete the old file if it exists
        if (fileManager.fileExistsAtPath(imageFilePath))
        {
            do
            {
                try NSFileManager.defaultManager().removeItemAtPath(imageFilePath)
            }
            catch
            {
                assert(false, "NSFileManager ERROR")
            }
        }
        
        // get the NSData from UIIMage
        let imageData : NSData! = UIImageJPEGRepresentation(image, 0.9)
        imageData.writeToFile(imageFilePath, atomically: true)
        
        return imageFilePath
    }
    
    static func readImageDataWithFileName(filename : String!, userKey : String!) -> NSData?
    {
        let fileManager : NSFileManager = NSFileManager.defaultManager()
        
        let imageFolderPath : String! = self.getImageStorageFolderPathForUser(userKey)
        
        let imageFilePath : String! = imageFolderPath.stringByAppendingPathComponent( String(format: "%@.jpg", filename) )
        
        if (!fileManager.fileExistsAtPath(imageFilePath))
        {
            return nil
        }
        
        // get the NSData from UIImage
        let imageData : NSData! = NSData.init(contentsOfFile: imageFilePath)
        
        return imageData
    }
    
    static func readImageWithFileName(filename : String!, userKey : String!) -> UIImage?
    {
        // get the NSData first
        let imageData : NSData? = Utils.readImageDataWithFileName(filename, userKey:userKey)
        
        if (imageData != nil)
        {
            let image : UIImage! = UIImage.init(data: imageData!)
            
            return image
        }
        
        return nil
    }
    
    static func deleteAllPhotosforUser(userKey : String!) -> Bool
    {
        let fileManager : NSFileManager = NSFileManager.defaultManager()
        
        let imageFolderPath : String! = Utils.getImageStorageFolderPathForUser(userKey)
        
        let fileEnumerator : NSDirectoryEnumerator? = fileManager.enumeratorAtPath(imageFolderPath)
        
        if (fileEnumerator != nil)
        {
            for fileName in fileEnumerator!
            {
                let filePath : String! = imageFolderPath.stringByAppendingPathComponent(fileName as! String)
                
                dLog( String(format: "Deleting file: %@", filePath) )
                
                do
                {
                    try fileManager.removeItemAtPath(filePath)
                }
                catch
                {
                    dLog( String(format: "Failed to delete file: %@", filePath) )
                }
            }
        }
        
        return true
    }
    
    static func imageWithFileNameExist(filename : String!, userKey : String!) -> Bool
    {
        let fileManager : NSFileManager = NSFileManager.defaultManager()
        
        let imageFolderPath : String! = Utils.getImageStorageFolderPathForUser(userKey)
        
        let imageFilePath : String! = imageFolderPath.stringByAppendingPathComponent( String(format:"%@.jpg", filename) )
        
        return fileManager.fileExistsAtPath(imageFilePath)
    }
    
    static func deleteImageWithFileName(filename : String!, userKey : String!) -> Bool
    {
        let fileManager : NSFileManager = NSFileManager.defaultManager()
        
        let imageFolderPath : String = self.getImageStorageFolderPathForUser(userKey)
        
        let imageFilePath : String = imageFolderPath.stringByAppendingPathComponent( String(format:"%@.jpg", filename) )
        
        if (fileManager.fileExistsAtPath(imageFilePath))
        {
            dLog(String(format:"Deleting file: %@", imageFilePath))
            
            do
            {
                try fileManager.removeItemAtPath(imageFilePath)
                
                return true
            }
            catch
            {
                dLog( String(format: "Failed to delete file: %@", imageFilePath) )
                
                return false
            }
        }
        
        return false
    }
    
    static func getCroppedImageUsingRect(cropRect : CGRect, originalImage : UIImage!) -> UIImage!
    {
        var rectTransform : CGAffineTransform
        
        switch (originalImage.imageOrientation)
        {
            case UIImageOrientation.Left:
                rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(CGFloat(M_PI_2)), 0, -originalImage.size.height)
                break
                
            case UIImageOrientation.Right:
                rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(CGFloat(-M_PI_2)), -originalImage.size.width, 0)
                break
                
            case UIImageOrientation.Down:
                rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(CGFloat(-M_PI)), -originalImage.size.width, -originalImage.size.height)
                break
                
            default:
                rectTransform = CGAffineTransformIdentity
        }
        
        rectTransform = CGAffineTransformScale(rectTransform, originalImage.scale, originalImage.scale)
        
        let imageRef : CGImageRef! = CGImageCreateWithImageInRect(originalImage.CGImage, CGRectApplyAffineTransform(cropRect, rectTransform))
        
        let result : UIImage! = UIImage.init(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        
        // Now want to scale down cropped image!
        // want to multiply frames by 2 to get retina resolution
        let scaledImgRect : CGRect = CGRectMake(0, 0, (cropRect.size.width * 2), (cropRect.size.height * 2))
        
        UIGraphicsBeginImageContextWithOptions(scaledImgRect.size, false, UIScreen.mainScreen().scale)
        
        result.drawInRect(scaledImgRect)
        
        let scaledNewImage : UIImage! = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledNewImage
    }
    
    static func getImageFilenamesForUser(userKey : String!) -> [String]!
    {
        let imageFolderPath : String! = self.getImageStorageFolderPathForUser(userKey)
        
        let fileManager : NSFileManager = NSFileManager.defaultManager()
        
        var filenames : [String] = []
        
        do
        {
            var filePathsArray : [String]
            
            try filePathsArray = fileManager.subpathsOfDirectoryAtPath(imageFolderPath)
            
            for filePath in filePathsArray
            {
                let filePathComponents : [String] = filePath.componentsSeparatedByString("/")
                
                let wholeFilename : String! = filePathComponents.last
                
                let filenameComponents : [String] = wholeFilename.componentsSeparatedByString(".")
                
                let filename : String! = filenameComponents.first
                
                filenames.append(filename)
            }
            
            return filenames
        }
        catch
        {
            return filenames
        }
    }
    
    static func getLeftSideViewUsing(profileImage : UIImage!, userName : String!) -> SideMenuView!
    {
        let leftSideMenuView : SideMenuView = SideMenuView()
        
        leftSideMenuView.profileImage = profileImage
        leftSideMenuView.userName = userName
        
        return leftSideMenuView
    }
    
    static func generateUniqueID() -> String!
    {
        return NSUUID.init().UUIDString
    }
    
    static func randomNumberBetween(min : Int, max : Int) -> Int
    {
        let lower : UInt32 = UInt32(min)
        let upper : UInt32 = UInt32(max) + 1
        let randomNumber = arc4random_uniform(upper - lower) + lower
        
        return Int(randomNumber)
    }
    
    static func currentYear() -> Int
    {
        let calendar : NSCalendar = NSCalendar.currentCalendar()
        let calendarComponents : NSDateComponents = calendar.components(NSCalendarUnit.Year, fromDate: NSDate())
        
        return calendarComponents.year
    }
    
    static func dateForMondayOfThisWeek() -> NSDate!
    {
        let calendar : NSCalendar = NSCalendar.currentCalendar()
        let calendarComponents : NSDateComponents = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day,  NSCalendarUnit.Weekday], fromDate: NSDate())
        
        let weekDayOfToday : NSInteger = calendarComponents.weekday // 1 = Sunday, 2 = Monday, etc.
        
        var numberOfDaysSinceMonday : NSInteger = 0
        
        if (weekDayOfToday == 1)
        {
            numberOfDaysSinceMonday = 6
        }
        else
        {
            numberOfDaysSinceMonday = weekDayOfToday - 2
        }
        
        calendarComponents.day = (calendarComponents.day - numberOfDaysSinceMonday)
        
        calendarComponents.calendar = calendar  // Must do this before calling [NSDateComponents date]
        
        let mondayOfThisWeek : NSDate! = calendarComponents.date
        
        return mondayOfThisWeek
    }
    
    static func dateForMondayOfPreviousWeek() -> NSDate!
    {
        let calendar : NSCalendar = NSCalendar.currentCalendar()
        let calendarComponents : NSDateComponents = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day,  NSCalendarUnit.Weekday], fromDate: NSDate())
        
        let weekDayOfToday : NSInteger = calendarComponents.weekday // 1 = Sunday, 2 = Monday, etc.
        
        var numberOfDaysSinceMonday : NSInteger = 0
        
        if (weekDayOfToday == 1)
        {
            numberOfDaysSinceMonday = 6
        }
        else
        {
            numberOfDaysSinceMonday =  weekDayOfToday - 2
        }
        
        calendarComponents.day = (calendarComponents.day - numberOfDaysSinceMonday)
        
        calendarComponents.day = (calendarComponents.day - 7)
        
        calendarComponents.calendar = calendar  // Must do this before calling [NSDateComponents date]
        
        let mondayOfPreviousWeek : NSDate! = calendarComponents.date
        
        return mondayOfPreviousWeek
    }
    
    static func dateForFirstDayOfThisMonth() -> NSDate!
    {
        let calendar : NSCalendar = NSCalendar.currentCalendar()
        let calendarComponents : NSDateComponents = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day,  NSCalendarUnit.Weekday], fromDate: NSDate())
        
        calendarComponents.day = 1
        
        calendarComponents.calendar = calendar  // Must do this before calling [NSDateComponents date]
        
        let firstDayOfThisMonth : NSDate! = calendarComponents.date
        
        return firstDayOfThisMonth
    }
    
    static func dateForFirstDayOfPreviousMonth() -> NSDate!
    {
        let calendar : NSCalendar = NSCalendar.currentCalendar()
        let calendarComponents : NSDateComponents = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day,  NSCalendarUnit.Weekday], fromDate: NSDate())
        
        calendarComponents.day = 1
        
        let currentMonth : Int = calendarComponents.month
        
        // if current month is January, we want to set the month to December of last year
        if (currentMonth == 1)
        {
            calendarComponents.year = calendarComponents.year - 1
            
            calendarComponents.month = 12
        }
        else
        {
            calendarComponents.month = calendarComponents.month - 1
        }
        
        calendarComponents.calendar = calendar  // Must do this before calling [NSDateComponents date]
        
        let firstDayOfPreviousMonth : NSDate! = calendarComponents.date
        
        return firstDayOfPreviousMonth
    }
    
    static func createBiggerRectOf(originalRect : CGRect, width : CGFloat) -> CGRect
    {
        var slightBiggerRect : CGRect = originalRect
        
        slightBiggerRect.origin.x -= width
        slightBiggerRect.origin.y -= width
        slightBiggerRect.size.width += width * 2
        slightBiggerRect.size.height += width * 2
        
        return slightBiggerRect
    }
    
    static func dateFromDateString(dateString : String!) -> NSDate?
    {
        let df : NSDateFormatter = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd";
        return df.dateFromString(dateString)
    }
}