//
//  VdotokShare.swift
//  iOS-one2many
//
//  Created by Fajar Chishtee on 09/02/2023.
//  Copyright © 2023 VDOTOK. All rights reserved.
//

import Foundation
import iOSSDKStreaming

class VdotokShare{
    
    static let shared = VdotokShare()

    var session:VTokBaseSession?
    var sdk :iOSSDKStreaming.VideoTalkSDK?
   
    //Initializer access level change now
    private init(){}
    
    func setSdk(sdk:iOSSDKStreaming.VideoTalkSDK){
        self.sdk = sdk
    }
    
    func getSdk()->iOSSDKStreaming.VideoTalkSDK{
        return self.sdk!
    }
 
    func setSession(session:VTokBaseSession){
        self.session = session
    }
    
    func getSession()->VTokBaseSession?{
        return self.session != nil ? self.session : nil
    }
    
}
