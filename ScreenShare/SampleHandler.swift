//
//  SampleHandler.swift
//  ScreenShare
//
//  Created by usama farooq on 08/07/2021.
//

import ReplayKit
import iOSSDKStreaming
import MMWormhole

class SampleHandler: RPBroadcastSampleHandler {
    
    var vtokSdk : VideoTalkSDK?
    var request: RegisterRequest?
    var audioState: ScreenShareAudioState!
    var screenState: ScreenShareScreenState!

    let wormhole = MMWormhole(applicationGroupIdentifier: AppsGroup.group, optionalDirectory: Constants.Wormhole)
    
    var baseSession : VTokBaseSession?
    var screenShareData: ScreenShareAppData?
    
    
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
                sdk.disableScreen(for: session.baseSession, state: self.screenState.screenShareScreen)
            }
        })
        
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
                                      referenceID: screenShareData.baseSession.from,
                                      authorizationToken: screenShareData.authenticationToken,
                                      socketType: .screenShare,
                                      requestID: getRequestId(),
                                      tenantID: AuthenticationConstants.PROJECTID)
        
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
        guard let vtokSdk = vtokSdk, let session = screenShareData?.baseSession else {return}
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
    func didGenerate(output: SDKOutPut) {
        switch output {
        case .registered:
            print("==== screeen share registerd ====")
            guard let sdk = vtokSdk, let session = screenShareData else {return}
            self.screenShareData = session
            sdk.initiate(session: session.baseSession, sessionDelegate: self)
        case .disconnected(_):
            print("==== screeen failed to registerd ====")
            break
        case .sessionRequest(_):
            break
        }
    }
    
}



extension SampleHandler: SessionDelegate {
    
    func configureLocalViewFor(session: VTokBaseSession, renderer: UIView) {
        
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
            print("test")
            break
        case .tryingToConnect:
            break
        }
    }
    
    func didGetPublicUrl(for session: VTokBaseSession, with url: String) {
        let message : NSString =  url as NSString
        wormhole.passMessageObject(message, identifier: "didGetPublicURL")
    }
    
}



extension SampleHandler {
    func getRequestId() -> String {
        
        let generatable = IdGenerator()
        let timestamp = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timestamp)
        let time = Date(timeIntervalSince1970: TimeInterval(myTimeInterval)).stringValue()
        let tenantId = "12345"
        let requestId = self.request?.referenceID ?? ""
        let token = generatable.getUUID(string: time + tenantId + requestId)
        return token
        
    }
}
