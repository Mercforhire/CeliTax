//
//  NetworkCommunicator.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-01.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class NetworkCommunicator : MKNetworkEngine
{
    static let WEBSERVICE_URL : String = "www.crave-n-save.ca/crave/Celitax-WebAPI/v1"
    static let WEB_API_FILE : String = "/index.php"
    
    //Common error message enums:
    static let NETWORK_ERROR_NO_CONNECTIVITY : String = "NETWORK_ERROR_NO_CONNECTIVITY"
    static let NETWORK_UNKNOWN_ERROR : String = "NETWORK_UNKNOWN_ERROR"
    
    var networkOperation : MKNetworkOperation?
    
    func postDataToServer(params : [NSObject : AnyObject]?, path : String!) -> MKNetworkOperation
    {
        let op : MKNetworkOperation = self.operationWithPath(path, params: params, httpMethod: "POST", ssl: true)
        
        return op
    }
    
    func getRequestToServer(path : String!) -> MKNetworkOperation
    {
        let op : MKNetworkOperation = self.operationWithPath(path, params: nil, httpMethod: "GET", ssl: true)
        
        return op
    }
    
    func downloadFileFrom(remoteURL : String!, filePath : String!) -> MKNetworkOperation
    {
        let op : MKNetworkOperation = self.operationWithURLString(remoteURL)
        
        op.addDownloadStream(NSOutputStream.init(toFileAtPath: filePath, append: false))
        
        self.enqueueOperation(op)
        
        return op
    }
    
    func cancelAndDiscardURLConnection()
    {
        self.networkOperation?.cancel()
        
        self.networkOperation = nil
    }
    
    deinit
    {
        self.networkOperation?.cancel()
    }
}