//
//  ImageDownloaderOperation.swift
//  CeliTax
//
//  Created by Leon Chen on 2016-04-04.
//  Copyright © 2016 CraveNSave. All rights reserved.
//

import UIKit

class ImageDownloaderOperation : NSOperation
{
    private let syncService : SyncService
    private let filenameToDownload : String
    
    // keep track of executing and finished states
    private var _executing = false
    private var _finished = false
    
    init (syncService : SyncService, filenameToDownload : String)
    {
        self.syncService = syncService
        self.filenameToDownload = filenameToDownload
    }
    
    override func start()
    {
        self.syncService.downloadFile(filenameToDownload, success: {
            
            dLog( String.init(format: "%@ successfully downloaded.", self.filenameToDownload) )
            self.finish()
            
            }, failure: { (reason) in
                
                dLog( String.init(format: "%@ failed to download!", self.filenameToDownload) )
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
