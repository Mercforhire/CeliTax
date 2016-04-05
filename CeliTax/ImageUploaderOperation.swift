//
//  ImageUploader.swift
//  CeliTax
//
//  Created by Leon Chen on 2016-04-04.
//  Copyright © 2016 CraveNSave. All rights reserved.
//

import UIKit

class ImageUploaderOperation : NSOperation
{
    private let syncService : SyncService
    private let filenameToUpload : String
    private let fileData : NSData
    
    // keep track of executing and finished states
    private var _executing = false
    private var _finished = false
    
    init (syncService : SyncService, filenameToUpload : String, fileData : NSData)
    {
        self.syncService = syncService
        self.filenameToUpload = filenameToUpload
        self.fileData = fileData
    }
    
    override func start()
    {
        self.syncService.uploadFile(filenameToUpload, data: fileData, success: {
            
            dLog( String.init(format: "%@ successfully uploaded.", self.filenameToUpload) )
            self.finish()
            
            }, failure: { (reason) in
                
                dLog( String.init(format: "%@ failed to upload!", self.filenameToUpload) )
                self.finish()
        })
    }
    
    override func main()
    {
        if cancelled == true && _finished != false
        {
            finish()
            return
        }
    }
    
    // Uou are responible to call `finish()` method when operation is about to finish.
    func finish()
    {
        // Change isExecuting to `false` and isFinished to `true`.
        // Taks will be considered finished.
        willChangeValueForKey("isExecuting")
        willChangeValueForKey("isFinished")
        _executing = false
        _finished = true
        didChangeValueForKey("isExecuting")
        didChangeValueForKey("isFinished")
    }
    
    override var executing: Bool
    {
        return _executing
    }
    
    override var finished: Bool
    {
        return _finished
    }
    
    override func cancel()
    {
        super.cancel()
        finish()
    }
}
