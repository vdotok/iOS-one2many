//
//  SampleHandler.swift
//  ScreenShare
//
//  Created by usama farooq on 08/07/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import ReplayKit
import iOSSDKStreaming
import MMWormhole

class SampleHandler: RPBroadcastSampleHandler {
    
    var vtokSdk : VideoTalkSDK?
    var request: RegisterRequest?
    var audioState: ScreenShareAudioState!
    var screenState: ScreenShareScreenState!
    var projectID : String!

    let wormhole = MMWormhole(applicationGroupIdentifier: AuthenticationConstants.APP_GROUP, optionalDirectory: Constants.Wormhole)
    
    var baseSession : VTokBaseSession?
    var screenShareData: ScreenShareAppData?
    
    var counter = 0
    

    
    override init() {
        super.init()
        audioState = ScreenShareAudioState(screenShareAudio: .passAll)
        screenState = ScreenShareScreenState(screenShareScreen: .passAll)
        wormhole.listenForMessage(withIdentifier: "InitScreenSharingSdk", listener: { [weak self] (messageObject) -> Void in
            guard let self = self else {return }
            if let message = messageObject as? String {
               print(message)
                self.getScreenShareAppData(with: message)
            }
        })

        wormhole.listenForMessage(withIdentifier: "updateAudioState", listener: { [weak self] (messageObject) -> Void in
            guard let self = self else {return }
            if let message = messageObject as? String {
               print(message)
                self.setScreenShareAppAudio(with: message)
            }
        })
        
        wormhole.listenForMessage(withIdentifier: "updateScreenState", listener: { [weak self] (messageObject) -> Void in
            guard let self = self else {return }
            if let message = messageObject as? String {
               print(message)
                guard let sdk = self.vtokSdk,
                      let session = self.screenShareData
                else { return }
                self.setScreenShareScreen(with: message)
                //sdk.disableScreen(for: session.baseSession, state: self.screenState.screenShareScreen)
            }
        })
        
        
        wormhole.listenForMessage(withIdentifier: "sessionKill", listener: { [weak self] (messageObject) -> Void in
            if let message = messageObject as? String, message == "hangup"  {
                let userInfo = [NSLocalizedFailureReasonErrorKey : "App is killed"]
                let error = NSError(domain: "RPBroadcastErrorDomain", code: 401, userInfo: userInfo)
                self!.finishBroadcastWithError(error)
            }
        })
        
        
        
        wormhole.listenForMessage(withIdentifier: "InitReInviteFromSampleHandler", listener: { [weak self] (messageObject) -> Void in
            self?.initReInvite()
        })
        wormhole.listenForMessage(withIdentifier: "Project_id") { [weak self] message -> Void  in
            if let projectId = message as? String {
                self!.projectID  = projectId
                
            }
        }        
    }
    
    func setScreenShareAppAudio(with message: String) {
        guard let data = message.data(using: .utf8) else {return }
        audioState = try! JSONDecoder().decode(ScreenShareAudioState.self, from: data)
        
    }
    
    func setScreenShareScreen(with message: String) {
        guard let data = message.data(using: .utf8) else {return }
        screenState = try! JSONDecoder().decode(ScreenShareScreenState.self, from: data)
        
    }
    
    
    func getScreenShareAppData(with message: String) {
        
        guard let data = message.data(using: .utf8) else {return }
        screenShareData = try? JSONDecoder().decode(ScreenShareAppData.self, from: data)
        guard screenShareData != nil else { return }
        initSdk()
    }
    
    
    func initSdk(){
        guard let screenShareData = screenShareData else {return }
        request = RegisterRequest(type: "request",
                                      requestType: "register",
                                  referenceId: screenShareData.baseSession.from,
                                  authorizationToken: screenShareData.authenticationToken,
                                  socketType: .screenShare,
                                  requestId: getRequestId(),
                                  projectId: self.projectID)
        
        vtokSdk = VTokSDK(url: screenShareData.url, registerRequest: request!, connectionDelegate: self, connectionType: .screenShare)
    }

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        let message : NSString =  "StartScreenSharing"
        wormhole.passMessageObject(message, identifier: "Command")
        
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {

        // User has requested to finish the broadcast.
        let message: String = "sessionTerminated"
        guard let vtokSdk = self.vtokSdk, let session = screenShareData?.baseSession else {return}
        let jsonData = try! JSONEncoder().encode(session)
        let jsonString = String(data: jsonData, encoding: .utf8)! as NSString
        wormhole.passMessageObject(jsonString, identifier: message)
      
        vtokSdk.hangup(session: session)
        
    }
  
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case .video:
            switch screenState.screenShareScreen {
            case .none:
                break
            case .passAll:
                vtokSdk?.processSampleBuffer(sampleBuffer, with: sampleBufferType)
            }
        case .audioApp,.audioMic:
            switch audioState.screenShareAudio {
            case .passAll:
                vtokSdk?.processSampleBuffer(sampleBuffer, with: sampleBufferType)
            case .none:
                break
            }
        @unknown default:
            break
        }
        
    }
}

extension SampleHandler: SDKConnectionDelegate {
    func initReInvite() {
        guard let sdk = vtokSdk, let session = screenShareData else {return}
        
        
                    var myString = String(sdk.sessionCount())
                    let message : NSString =  NSString(string: myString)
                    wormhole.passMessageObject(message, identifier: "fireNotification")
        
        
        sdk.startReInvite(session: session.baseSession, sessionDelegate: self)
    }
    
    func didGenerate(output: SDKOutPut) {
        switch output {
        case .registered:
            print("==== screeen share registerd ====")
            guard let sdk = vtokSdk, let session = screenShareData else {return}
            self.screenShareData = session
            if(counter == 0){
                counter = 1
                sdk.initiate(session: session.baseSession, sessionDelegate: self)
            }
        case .disconnected(_):
            print("==== screeen failed to registerd ====")
            break
        case .sessionRequest(_):
            break
        }
    }
    
    
}



extension SampleHandler: SessionDelegate {
    
    func configureLocalViewFor(session: VTokBaseSession, with stream: [UserStream]) {
        
    }
    
    func sessionTimeDidUpdate(with value: String) {

    }
    
    func configureRemoteViews(for session: VTokBaseSession, with streams: [UserStream]) {
        
    }

    
    func stateDidUpdate(for session: VTokBaseSession) {
        switch session.state {
        case .calling:
            break
        case .ringing:
            break
        case .connected:
              break
        case .failed:
            break
        case .rejected:
            print("test")
            break
        case .onhold:
            break
        case .busy:
            break
        case .missedCall:
            break
        case .receivedSessionInitiation:
            break
        case .invalidTarget:
            break
        case .hangup:
            let userInfo = [NSLocalizedFailureReasonErrorKey : "User ended the Call"]
            let error = NSError(domain: "RPBroadcastErrorDomain", code: 401, userInfo: userInfo)
            finishBroadcastWithError(error)
            print("test")
            break
        case .tryingToConnect:
            break
        case .updateParticipent:
            break
        case .suspendedByProvider:
            break
        case .insufficientBalance:
            let userInfo = [NSLocalizedFailureReasonErrorKey : "Insufficient fund"]
            let error = NSError(domain: "RPBroadcastErrorDomain", code: 401, userInfo: userInfo)
            finishBroadcastWithError(error)
            break
        case .temporaryUnAvailable:
           break
        default:
            break
        }
        
        let message = String(countParticpant(session: session)) as NSString
        wormhole.passMessageObject(message, identifier: "participantAdded")
    }
    
    func didGetPublicUrl(for session: VTokBaseSession, with url: String) {
        let message : NSString =  url as NSString
        wormhole.passMessageObject(message, identifier: "didGetPublicURL")
    }
    
    
}



extension SampleHandler {
    
    func countParticpant(session:VTokBaseSession)->Int {
        let participants = Array(Set(session.connectedUsers))
        return participants.count
    }
    
    func getRequestId() -> String {
        
        let generatable = IdGenerator()
        let timestamp = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timestamp)
        let time = Date(timeIntervalSince1970: TimeInterval(myTimeInterval)).stringValue()
        let tenantId = "12345"
        let requestId = self.request?.referenceId ?? ""
        let token = generatable.getUUID(string: time + tenantId + requestId)
        return token
        
    }
}
