//
//  SyncService.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-04.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation
import UIKit

@objc
class SyncService : NSObject
{
    static let USER_NO_DATA : String = "USER_NO_DATA"
    static let RECEIPT_IMAGE_FILE_NO_LONGER_EXIST : String = "RECEIPT_IMAGE_FILE_NO_LONGER_EXIST"
    
    typealias GenerateDemoDataCompleteBlock = () -> Void
    
    typealias SyncingSuccessBlock = (updateDate : NSDate) -> Void
    typealias SyncingFailureBlock = (reason : String) -> Void
    
    typealias DownloadDataSuccessBlock = () -> Void
    typealias DownloadDataFailureBlock = (reason : String) -> Void
    
    typealias GetLastestServerDataInfoSuccessBlock = (batchID : String) -> Void
    typealias GetLastestServerDataInfoFailureBlock = (reason : String) -> Void
    
    typealias GetListOfFilesNeedUploadSuccessBlock = (filesnamesToUpload : [String]) -> Void
    typealias GetListOfFilesNeedUploadFailureBlock = (reason : String) -> Void
    
    typealias FileUploadSuccessBlock = () -> Void
    typealias FileUploadFailureBlock = (reason : String) -> Void
    
    typealias FileDownloadSuccessBlock = () -> Void
    typealias FileDownloadFailureBlock = (reason : String) -> Void
    
    typealias RequestReceiptsInfoEmailSuccessBlock = () -> Void
    typealias RequestReceiptsInfoEmailFailureBlock = (reason : String) -> Void
    
    typealias SendYearlyReportSuccessBlock = () -> Void
    typealias SendYearlyReportFailureBlock = (reason : String) -> Void
    
    private weak var userDataDAO : UserDataDAO!
    private weak var taxYearsDAO : TaxYearsDAO!
    private weak var recordsDAO : RecordsDAO!
    private weak var receiptsDAO : ReceiptsDAO!
    private weak var categoriesDAO : CategoriesDAO!
    private weak var networkCommunicator : NetworkCommunicator!
    private weak var catagoryBuilder : CategoryBuilder!
    private weak var recordBuilder : RecordBuilder!
    private weak var receiptBuilder : ReceiptBuilder!
    private weak var taxYearBuilder : TaxYearBuilder!
    
    override init()
    {
        super.init()
    }
    
    init(userDataDAO : UserDataDAO!, taxYearsDAO : TaxYearsDAO!, recordsDAO : RecordsDAO!, receiptsDAO : ReceiptsDAO!, categoriesDAO : CategoriesDAO!, networkCommunicator : NetworkCommunicator!, catagoryBuilder : CategoryBuilder!, recordBuilder : RecordBuilder!, receiptBuilder : ReceiptBuilder!, taxYearBuilder : TaxYearBuilder!)
    {
        self.userDataDAO = userDataDAO
        self.taxYearsDAO = taxYearsDAO
        self.recordsDAO = recordsDAO
        self.receiptsDAO = receiptsDAO
        self.categoriesDAO = categoriesDAO
        self.networkCommunicator = networkCommunicator
        self.catagoryBuilder = catagoryBuilder
        self.recordBuilder = recordBuilder
        self.receiptBuilder = receiptBuilder
        self.taxYearBuilder = taxYearBuilder
    }
    
    /*
    Insert some default categories
    */
    func insertPreloadedCategories()
    {
        self.categoriesDAO.addCategoryForName(SWLocalizedString("Bread"), color: UIColor.init(red: 0, green: 1, blue: 0.625, alpha: 1), save: false)
        
        self.categoriesDAO.addCategoryForName(SWLocalizedString("Cereal"), color: UIColor.init(red: 1, green: 0, blue: 0.5, alpha: 1), save: false)
        
        self.categoriesDAO.addCategoryForName(SWLocalizedString("Crackers"), color: UIColor.init(red: 0.7974, green: 1, blue: 0, alpha: 1), save: false)
        
        self.categoriesDAO.addCategoryForName(SWLocalizedString("Bagels"), color: UIColor.init(red: 0, green: 0.4439, blue: 1, alpha: 1), save: false)
        
        self.categoriesDAO.addCategoryForName(SWLocalizedString("Buns"), color: UIColor.init(red: 1, green: 0, blue: 0.9568, alpha: 1), save: true)
    }
    
    /*
    Insert some random receipt data locally for testing purposes
    */
    func insertDemoData(complete : GenerateDemoDataCompleteBlock?)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { 
            
            self.taxYearsDAO.addTaxYear(2013, save:false)
            self.taxYearsDAO.addTaxYear(2014, save:false)
            self.taxYearsDAO.addTaxYear(2015, save:false)
            
            if (self.categoriesDAO.fetchCategories().count == 0)
            {
                self.categoriesDAO.addCategoryForName("Bread", color: UIColor.yellowColor(), save: false)
                
                self.categoriesDAO.addCategoryForName("Cereal", color: UIColor.orangeColor(), save: false)
                
                self.categoriesDAO.addCategoryForName("Crackers", color: UIColor.redColor(), save: false)
                
                self.categoriesDAO.addCategoryForName("Bagels", color: UIColor.greenColor(), save: false)
                
                self.categoriesDAO.addCategoryForName("Buns", color: UIColor.purpleColor(), save: false)
                
                //Give all Categories a random Unit Item national average amount
                let allCategories : [ItemCategory]! = self.categoriesDAO.fetchCategories()
                
                //Pick 3 random catagories and give them a random national average amount for at least one other Unit
                var indexesOf3ChoosenCategories : [Int] = []
                
                var i : Int = 0
                
                while (indexesOf3ChoosenCategories.count <= 3)
                {
                    let randomIndex : Int = Utils.randomNumberBetween(0, max: allCategories.count - 1)
                    
                    if (!indexesOf3ChoosenCategories.contains(randomIndex))
                    {
                        indexesOf3ChoosenCategories.append(randomIndex)
                        
                        i++
                    }
                }
                
                for category in allCategories
                {
                    let indexOfCatagory : Int? = allCategories.indexOf(category)
                    
                    if (indexOfCatagory != nil && indexesOf3ChoosenCategories.contains(indexOfCatagory!))
                    {
                        for var j = UnitTypes.UnitItem.rawValue; j < UnitTypes.UnitCount.rawValue; j++
                        {
                            //50% Chance of adding a National Average Cost for the current Unit Type
                            if (Utils.randomNumberBetween(1, max: 10) <= 5)
                            {
                                category.addOrUpdateNationalAverageCostForUnitType(UnitTypes(rawValue: j)!, amount: Float(Utils.randomNumberBetween(10, max: 100)) / 10)
                            }
                        }
                    }
                }
            }
            
            let testImage1 : UIImage! = UIImage.init(named: "ReceiptPic-1.jpg")
            
            let calendar : NSCalendar = NSCalendar.currentCalendar()
            let components : NSDateComponents = NSDateComponents()
            
            let numberOfCatagories : Int = self.categoriesDAO.fetchCategories().count
            
            // add random receipts
            for var receiptNumber = 0; receiptNumber < 10; receiptNumber++
            {
                let fileName1 : String = String.init(format: "Receipt-%@-%d", Utils.generateUniqueID(), 1)
                let fileName2 : String = String.init(format: "Receipt-%@-%d", Utils.generateUniqueID(), 2)
                
                Utils.saveImage(testImage1, filename: fileName1, userKey: self.userDataDAO.userKey)
                
                components.day = Utils.randomNumberBetween(1, max: 28)
                components.month = Utils.randomNumberBetween(1, max: 12)
                components.year = Utils.randomNumberBetween(2013, max: 2015)
                components.hour = Utils.randomNumberBetween(0, max: 23)
                components.minute = Utils.randomNumberBetween(0, max: 59)
                
                let randomDate : NSDate! = calendar.dateFromComponents(components)
                
                if (randomDate.laterDate(NSDate()) == randomDate)
                {
                    continue;
                }
                
                let newReceipt : Receipt = Receipt()
                
                newReceipt.localID = Utils.generateUniqueID()
                newReceipt.fileNames = [fileName1, fileName2]
                newReceipt.dateCreated = randomDate
                newReceipt.taxYear = Utils.randomNumberBetween(2013, max: 2015)
                newReceipt.dataAction = DataActionStatus.DataActionInsert;
                
                self.receiptsDAO.addReceipt(newReceipt, save: false)
                
                // add random items for each receipt
                let numberOfItems : Int = Utils.randomNumberBetween(1, max: 10)
                
                for (var itemNumber = 0; itemNumber < numberOfItems; itemNumber++)
                {
                    let categories : [ItemCategory]! = self.categoriesDAO.fetchCategories()
                    
                    let randomCategoryIndex : Int = Utils.randomNumberBetween(0, max:numberOfCatagories - 1)
                    
                    let recordCatagory : ItemCategory = categories[randomCategoryIndex]
                    
                    let recordQuantity : Int = Utils.randomNumberBetween(1, max: 20)
                    
                    let recordUnitType : UnitTypes! = UnitTypes.init(rawValue: Utils.randomNumberBetween(UnitTypes.UnitItem.rawValue, max: UnitTypes.UnitLb.rawValue))
                    
                    let recordAmount : Float = Float(Utils.randomNumberBetween(10, max: 100)) / 10
                    
                    self.recordsDAO.addRecordForCategory(recordCatagory, receipt: newReceipt, quantity: recordQuantity, unitType: recordUnitType, amount: recordAmount, save: false)
                }
            }
            
            self.userDataDAO.saveUserData()
            
            dispatch_async(dispatch_get_main_queue(), { 
                
                if (complete != nil)
                {
                    complete!()
                }
            })
            
        })
    }
    
    /*
    Check to see if local data has a non-0 dataAction
    */
    func needToBackUp() -> Bool
    {
        let data : NSDictionary = self.userDataDAO.generateJSONToUploadToServer()
        
        dLog(data.description)
        
        for data in data.allValues
        {
            if let array = data as? NSArray
            {
                if (array.count > 0)
                {
                    return true
                }
            }
        }
        
        return false
    }
    
    /*
    Get the date of last successful sync with server
    */
    func getLastBackUpDate() -> NSDate?
    {
        return self.userDataDAO.getLastBackUpDate()
    }
    
    /*
    Get the batchID of local Data
    */
    func getLocalDataBatchID() -> String?
    {
        return self.userDataDAO.getLastestDataHash()
    }
    
    /*
    Upload the UserData from app to server, and expect back a hash string of data just uploaded
    */
    func startSyncingUserData(success : SyncingSuccessBlock?, failure : SyncingFailureBlock?)
    {
        let dictionary : NSDictionary = self.userDataDAO.generateJSONToUploadToServer()
        
        let dictionaryData : NSData?
        
        do
        {
            try dictionaryData = NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.PrettyPrinted)
        }
        catch
        {
            return
        }
        
        let jsonString : String! = NSString.init(data: dictionaryData!, encoding: NSUTF8StringEncoding) as! String
        
        let postParams: [String:String] = [
            "data" : jsonString
        ]
        
        let networkOperation : MKNetworkOperation = self.networkCommunicator.postDataToServer(postParams, path: NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/upload"))
        
        networkOperation.addHeader("Authorization", withValue:self.userDataDAO.userKey)
        
        networkOperation.postDataEncoding = MKNKPostDataEncodingTypeURL
        
        var bgTask : UIBackgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler( { 
            
        })
        
        let successBlock : MKNKResponseBlock = { (completedOperation) in
            
            let response : NSDictionary = completedOperation.responseJSON() as! NSDictionary
            
            self.userDataDAO.setLastBackUpDate(NSDate())
            
            self.userDataDAO.setLastestDataHash(response["batchID"]! as! String)
            
            self.userDataDAO.resetAllDataActionsAndClearOutDeletedOnes()
            
            self.userDataDAO.saveUserData()
            
            dispatch_async(dispatch_get_main_queue(), { 
                
                if (success != nil)
                {
                    success!(updateDate: NSDate())
                }
                
            })
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
            
            bgTask = UIBackgroundTaskInvalid
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            dispatch_async(dispatch_get_main_queue(), { 
                
                if (failure != nil)
                {
                    failure!( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
                
            })
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
            
            bgTask = UIBackgroundTaskInvalid
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    /*
    Download the UserData JSON from to server, merge the server's contents with the local UserData
    */
    func downloadUserData(success : DownloadDataSuccessBlock?, failure : DownloadDataFailureBlock?)
    {
        let networkOperation : MKNetworkOperation = self.networkCommunicator.getRequestToServer(NetworkCommunicator.WEB_API_FILE .stringByAppendingString("/download"))
        
        networkOperation.addHeader("Authorization", withValue:self.userDataDAO.userKey)
        
        var bgTask : UIBackgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler ({ })
        
        let successBlock : MKNKResponseBlock =  { (completedOperation) in
            
            let response : NSDictionary = completedOperation.responseJSON() as! NSDictionary
            
            if ( response["error"] != nil && response["error"]!.boolValue == false )
            {
                let dataDictionary : NSDictionary = response["data"] as! NSDictionary
                
                //First merge the Tax Years
                
                let taxYearNumbers : [Int] = dataDictionary["TaxYears"] as! [Int]
                
                var taxYears : [TaxYear] = []
                
                for taxYearNumber in taxYearNumbers
                {
                    let taxYear : TaxYear! = self.taxYearBuilder.buildTaxYearFrom(taxYearNumber)
                    
                    taxYears.append(taxYear)
                }
                
                self.taxYearsDAO.mergeWith(taxYears, save: false)
                
                //Second merge the Catagories
                
                let categoryDictionaries : [NSDictionary] = dataDictionary["Catagories"] as! [NSDictionary]
                
                var categories : [ItemCategory] = []
                
                for categoryDictionary in categoryDictionaries
                {
                    let category : ItemCategory? = self.catagoryBuilder.buildCategoryFrom(categoryDictionary)
                    
                    if (category != nil)
                    {
                        categories.append(category!)
                    }
                }
                
                self.categoriesDAO.mergeWith(categories, save: false)
                
                //Third the receipts
                
                let receiptDictionaries : [NSDictionary] = dataDictionary["Receipts"] as! [NSDictionary]
                
                var receipts : [Receipt] = []
                
                for receiptDictionary in receiptDictionaries
                {
                    let receipt : Receipt? = self.receiptBuilder.buildReceiptFrom(receiptDictionary)
                    
                    if (receipt != nil)
                    {
                        receipts.append(receipt!)
                    }
                }
                
                self.receiptsDAO.mergeWith(receipts, save: false)
                
                //Lastly, the records
                
                let recordDictionaries : [NSDictionary] = dataDictionary["Records"] as! [NSDictionary]
                
                var records : [Record] = []
                
                for recordDictionary in recordDictionaries
                {
                    let record : Record? = self.recordBuilder.buildRecordFrom(recordDictionary)
                    
                    if (record != nil)
                    {
                        //check if catagoryID is valid
                        
                        if ((self.categoriesDAO.fetchCategory(record!.categoryID) == nil))
                        {
                            dLog("ERROR: Record has an invalid catagoryID")
                            record!.dataAction = DataActionStatus.DataActionDelete
                        }
                        
                        //check if receiptID is valid
                        if (self.receiptsDAO.fetchReceipt(record!.receiptID) == nil)
                        {
                            dLog("ERROR: Record has an invalid receiptID");
                            record!.dataAction = DataActionStatus.DataActionDelete
                        }
                        
                        records.append(record!)
                    }
                }
                
                self.recordsDAO.mergeWith(records, save: false)
                
                self.userDataDAO.setLastestDataHash(response["batchID"] as! String)
                
                self.userDataDAO.saveUserData()
                
                dispatch_async(dispatch_get_main_queue(), { 
                    
                    if (success != nil)
                    {
                        success!()
                    }
                    
                })
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { 
                    
                    if (failure != nil)
                    {
                        failure!( reason: SyncService.USER_NO_DATA )
                    }
                    
                })
            }
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
            
            bgTask = UIBackgroundTaskInvalid
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            dispatch_async(dispatch_get_main_queue(), { 
                if (failure != nil)
                {
                    failure!( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
            })
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
            
            bgTask = UIBackgroundTaskInvalid
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    /*
    Ask the server for its most recent hash string of the data
    */
    func getLastestServerDataBatchID(success : GetLastestServerDataInfoSuccessBlock?, failure : GetLastestServerDataInfoFailureBlock?)
    {
        let networkOperation : MKNetworkOperation = self.networkCommunicator.getRequestToServer(NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/data_batchid"))
        
        networkOperation.addHeader("Authorization", withValue:self.userDataDAO.userKey)
        
        var bgTask : UIBackgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ 
            
        })
        
        let successBlock : MKNKResponseBlock = { (completedOperation) in
            
            let response : NSDictionary = completedOperation.responseJSON() as! NSDictionary
            
            let batchID : String? = response["batchID"] as? String
            
            if ( response["error"] != nil && response["error"]!.boolValue == false && batchID != nil)
            {
                dispatch_async(dispatch_get_main_queue(), { 
                    
                    if (success != nil)
                    {
                        success! ( batchID: batchID! )
                    }
                    
                })
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { 
                    
                    if (failure != nil)
                    {
                        failure! ( reason: SyncService.USER_NO_DATA )
                    }
                    
                })
            }
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
            
            bgTask = UIBackgroundTaskInvalid
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            dispatch_async(dispatch_get_main_queue(), { 
                
                if (failure != nil)
                {
                    failure! ( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
                
                })
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
            
            bgTask = UIBackgroundTaskInvalid
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    /*
    Assuming the server has the same data as the device
    Ask the server for a list of filenames that it doesn't have, but exists on the device.
    Using the data from UserData.receipts.fileNames
    */
    func getFilesNeedToUpload(success : GetListOfFilesNeedUploadSuccessBlock?, failure : GetListOfFilesNeedUploadFailureBlock?)
    {
        let networkOperation : MKNetworkOperation = self.networkCommunicator.getRequestToServer(NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/get_files_need_upload"))
        
        networkOperation.addHeader("Authorization", withValue:self.userDataDAO.userKey)
        
        var bgTask : UIBackgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ })
        
        let successBlock : MKNKResponseBlock = { (completedOperation) in
            
            let response : NSDictionary = completedOperation.responseJSON() as! NSDictionary
            
            let filesnamesToUpload : [String] = response["files_need_upload"] as! [String]
            
            dispatch_async(dispatch_get_main_queue(), { 
                
                if (success != nil)
                {
                    success! ( filesnamesToUpload: filesnamesToUpload )
                }
                
            })
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
            
            bgTask = UIBackgroundTaskInvalid
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            dispatch_async(dispatch_get_main_queue(), { 
                
                if (failure != nil)
                {
                    failure! ( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
            })
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
            
            bgTask = UIBackgroundTaskInvalid
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    /*
    Upload the given file with the given filename for the currently logged in user
    */
    func uploadFile(filename : String, data : NSData, success : FileUploadSuccessBlock?, failure : FileUploadFailureBlock?)
    {
        let postParams: [String:String] = [
            "filename" : filename
        ]
        
        let networkOperation : MKNetworkOperation = self.networkCommunicator.postDataToServer(postParams, path: NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/upload_photo"))
        
        networkOperation.addHeader("Authorization", withValue:self.userDataDAO.userKey)
        
        //used for server temp storage file name. Not important
        let fileNameWithExtension : String = String(format: "%@.jpg", filename)
        
        networkOperation.addData(data, forKey:"photos", mimeType:"image/jpeg", fileName:fileNameWithExtension)
        
        var bgTask : UIBackgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler( { 
            
        })
        
        let successBlock : MKNKResponseBlock = { (completedOperation) in
            
            dispatch_async(dispatch_get_main_queue(), { 
                
                if (success != nil)
                {
                    success! ( )
                }
                
                })
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
            
            bgTask = UIBackgroundTaskInvalid
            
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            dispatch_async(dispatch_get_main_queue(), { 
                
                if (failure != nil)
                {
                    failure! ( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY );
                }
                
            })
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
            
            bgTask = UIBackgroundTaskInvalid
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    private func downloadFileFromURL(url : String, filePath : String, success : FileDownloadSuccessBlock?, failure : FileDownloadFailureBlock?)
    {
        let networkOperation : MKNetworkOperation = self.networkCommunicator.downloadFileFrom(url, filePath:filePath)
        
        let successBlock : MKNKResponseBlock =  { (completedOperation) in
            
            dispatch_async(dispatch_get_main_queue(), { 
                
                if (success != nil)
                {
                    dLog( String.init(format: "Downloaded image from %@", url) )
                    success! ( )
                }
                
            })
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            dispatch_async(dispatch_get_main_queue(), { 
                
                if (failure != nil)
                {
                    dLog( String.init(format: "Failed to download image from %@", url) )
                    failure! ( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
            })
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
    }
    
    /*
    Download the file of the given filename for the currently logged in user
    */
    func downloadFile(filename : String, success : FileDownloadSuccessBlock?, failure : FileDownloadFailureBlock?)
    {
        // 1.get the URL of the image first
        let filePath : String = Utils.getFilePathForImage(filename, userKey: self.userDataDAO.userKey)
        
        let postParams: [String:String] = [
            "filename" : filename
        ]
 
        let networkOperation : MKNetworkOperation = self.networkCommunicator.postDataToServer(postParams, path: NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/request_file_url"))
        
        networkOperation.addHeader("Authorization", withValue:self.userDataDAO.userKey)
        
        let successBlock : MKNKResponseBlock = { (completedOperation) in
            
            let response : NSDictionary = completedOperation.responseJSON() as! NSDictionary
            
            if ( response["error"] != nil && response["error"]!.boolValue == false)
            {
                let url : String = response["url"] as! String
                
                // 2.start downloading the image from the url
                dLog( String.init(format: "Received URL of image: %@", url) )
                
                self.downloadFileFromURL(url, filePath:filePath, success:success, failure:failure)
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { 
                    
                    if (failure != nil)
                    {
                        dLog( String.init(format: "Failed to get URL of image: %@", filename) )
                        failure! ( reason: SyncService.RECEIPT_IMAGE_FILE_NO_LONGER_EXIST )
                    }
                    
                })
            }
        };
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            dispatch_async(dispatch_get_main_queue(), { 
                
                if (failure != nil)
                {
                    failure! ( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
                
            })
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    /*
    Get the list of receipt images that need to be downloaded from server
    */
    func getListOfFilesToDownload() -> [String]
    {
        var allFilenames : [String] = []
        
        let allReceipts : [Receipt] = self.receiptsDAO.fetchAllReceipts()
        
        for receipt in allReceipts
        {
            allFilenames.appendContentsOf(receipt.fileNames as NSArray as! [String])
        }
        
        var filesNeedToDownload : [String] = []
        
        //check which file in allFilenames doesn't exist
        for filename in allFilenames
        {
            if ( !Utils.imageWithFileNameExist(filename, userKey:self.userDataDAO.userKey) )
            {
                filesNeedToDownload.append(filename)
            }
        }
        
        return filesNeedToDownload
    }
    
    /*
    Find any Photo files that are not in an exsting Receipt's filenames and delete these files
    */
    func cleanUpReceiptImages()
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { 
            
            //1. Get all names of files we should keep
            var allFilenames : [String] = []
            
            let allReceipts : [Receipt] = self.receiptsDAO.fetchAllReceipts()
            
            for receipt in allReceipts
            {
                allFilenames.appendContentsOf(receipt.fileNames as NSArray as! [String])
            }
            
            //2. Get names of all files that exist
            let existingFilenames : [String] = Utils.getImageFilenamesForUser(self.userDataDAO.userKey)
            
            //3. Check if each existing file also exist in the list of files those we should keep
            for existingFilename in existingFilenames
            {
                if (!allFilenames.contains(existingFilename))
                {
                    //delete this file
                    Utils.deleteImageWithFileName(existingFilename, userKey:self.userDataDAO.userKey)
                }
            }
            
        })
    }
    
    /*
    Request the server to send a email containing the selected receipts info to the user
    */
    func sendReceiptsInfoEmail(email : String!, year : Int, allReceipts : Bool, receiptIDs : [String]?, success : RequestReceiptsInfoEmailSuccessBlock?, failure : RequestReceiptsInfoEmailFailureBlock?)
    {
        let postParams: [String:AnyObject];
        
        if (allReceipts)
        {
            postParams = [
                "email" : email,
                "year" : year,
                "allReceipts" : Int(allReceipts)
            ]
        }
        else
        {
            var receiptIDsString : String = ""
            
            for receiptID in receiptIDs!
            {
                if (receiptIDs?.indexOf(receiptID) == 0)
                {
                    receiptIDsString = receiptID
                }
                else
                {
                    receiptIDsString = receiptIDsString + "," + receiptID
                }
            }
            
            postParams = [
                "email" : email,
                "year" : year,
                "allReceipts" : Int(allReceipts),
                "receiptIDs" : receiptIDsString
            ]
        }
        
        let networkOperation : MKNetworkOperation = self.networkCommunicator.postDataToServer(postParams, path: NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/request_receipts_info"))
        
        networkOperation.addHeader("Authorization", withValue:self.userDataDAO.userKey)
        
        var bgTask : UIBackgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler ({ })
        
        let successBlock : MKNKResponseBlock = { (completedOperation) in
            
            let response : NSDictionary = completedOperation.responseJSON() as! NSDictionary
            
            if ( response["error"] != nil && response["error"]!.boolValue == false)
            {
                dispatch_async(dispatch_get_main_queue(), { 
                    
                    if (success != nil)
                    {
                        success! ( )
                    }
                    
                })
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { 
                    
                    if (failure != nil)
                    {
                        failure! ( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                    }
                    
                })
            }
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
            
            bgTask = UIBackgroundTaskInvalid
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            dispatch_async(dispatch_get_main_queue(), { 
                
                if (failure != nil)
                {
                    failure! ( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
                
            })
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
            
            bgTask = UIBackgroundTaskInvalid
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    /*
    Upload a yearly summary report for this user to the server and have the server send a email to the choicen email to view this report on the web browser at a later time
    */
    func sendYearlyReportTo(email : String!, dateReport : Dictionary<String , AnyObject>!, success : RequestReceiptsInfoEmailSuccessBlock?, failure : RequestReceiptsInfoEmailFailureBlock?)
    {
        let dictionaryData : NSData?
        
        do
        {
            try dictionaryData = NSJSONSerialization.dataWithJSONObject(dateReport, options: NSJSONWritingOptions.PrettyPrinted)
        }
        catch
        {
            return
        }
        
        let jsonString : String! = NSString.init(data: dictionaryData!, encoding: NSUTF8StringEncoding) as! String
        
        let postParams = [
            "email" : email,
            "report" : jsonString
        ]
        
        let networkOperation : MKNetworkOperation = self.networkCommunicator.postDataToServer(postParams, path: NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/upload_report_info"))
        
        networkOperation.addHeader("Authorization", withValue:self.userDataDAO.userKey)
        
        var bgTask : UIBackgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
            
        })
        
        let successBlock : MKNKResponseBlock = { (completedOperation) in
            
            let response : NSDictionary = completedOperation.responseJSON() as! NSDictionary
            
            if ( response["error"] != nil && response["error"]!.boolValue == false)
            {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if (success != nil)
                    {
                        success! ( )
                    }
                    
                })
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if (failure != nil)
                    {
                        failure! ( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                    }
                    
                })
            }
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
            
            bgTask = UIBackgroundTaskInvalid
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if (failure != nil)
                {
                    failure! ( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
                
            })
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
            
            bgTask = UIBackgroundTaskInvalid
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
}