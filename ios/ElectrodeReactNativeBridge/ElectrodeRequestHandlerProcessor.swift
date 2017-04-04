//
//  ElectrodeRequestHandlerProcessor.swift
//  ElectrodeReactNativeBridge
//
//  Created by Claire Weijie Li on 4/3/17.
//  Copyright © 2017 Walmart. All rights reserved.
//

import UIKit

class ElectrodeRequestHandlerProcessor<TReq, TResp>: NSObject, Processor {
    let tag: String
    let requestName: String
    let reqClass: TReq.Type
    let respClass: TResp.Type
    let requestHandler: ElectrodeBridgeRequestHandler
    
    init(requestName: String,
         reqClass: TReq.Type,
         respClass: TResp.Type,
         requestHandler: ElectrodeBridgeRequestHandler)
    {
        self.tag = String(describing: type(of:self))
        self.requestName = requestName
        self.reqClass = reqClass
        self.respClass = respClass
        self.requestHandler = requestHandler
        super.init()
    }
    
    func execute() {
        let intermediateRequestHandler = ElectrodeBridgeRequestHandlerImpt(requestClass:reqClass , requestHandler: requestHandler)
        ElectrodeBridgeHolderNew.sharedInstance().registerRequestHanlder(withName: requestName, requestHandler: intermediateRequestHandler)
    }
    
    
}

class ElectrodeBridgeRequestHandlerImpt<TReq>: NSObject, ElectrodeBridgeRequestHandler {
    let requestClass: TReq.Type
    let requestHandler: ElectrodeBridgeRequestHandler
    
    init(requestClass: TReq.Type, requestHandler: ElectrodeBridgeRequestHandler) {
        self.requestClass = requestClass
        self.requestHandler = requestHandler
    }
    func onRequest(_ data: [AnyHashable : Any], responseListener: ElectrodeBridgeResponseListener) {
        // Why this is needed?
        // let requestObj = try? ElectrodeUtilities.generateObject(data: data, classType: requestClass)
        let innerResponseListner = InnerElectrodeBridgeResponseListener(sucessClosure:{ (any) in
            responseListener.onSuccess(any)
        }, failureClosure: { (failureMessage) in
            responseListener.onFailure(failureMessage)
        })
        
//TODO: should request always be Dictionary here instead of converting it to Object?
        requestHandler.onRequest(data, responseListener: innerResponseListner)
    }
}

class InnerElectrodeBridgeResponseListener: NSObject, ElectrodeBridgeResponseListener {
    let success: (Any?) ->()
    let failure: (ElectrodeFailureMessage) -> ()
    init(sucessClosure: @escaping (Any?)->(), failureClosure:@escaping (ElectrodeFailureMessage) -> ()) {
        success = sucessClosure
        failure = failureClosure
        super.init()
    }
    
    func onSuccess(_ responseData: Any?) {
        success(responseData)
    }
    
    func onFailure(_ failureMessage: ElectrodeFailureMessage) {
        failure(failureMessage)
    }
}
