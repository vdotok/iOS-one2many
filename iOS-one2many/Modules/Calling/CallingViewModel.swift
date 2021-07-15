//  
//  CallingViewModel.swift
//  one-to-many-call
//
//  Created by usama farooq on 15/06/2021.
//

import Foundation
import iOSSDKStreaming
import UIKit
import AVFoundation
import MMWormhole

typealias CallingViewModelOutput = (CallingViewModelImpl.Output) -> Void

protocol CallingViewModelInput {
    
}

protocol CallingViewModel: CallingViewModelInput {
    var output: CallingViewModelOutput? { get set}
    var users: [User]? {get set}
    
    func viewModelDidLoad()
    func viewModelWillAppear()
    func acceptCall(session: VTokBaseSession)
    func rejectCall(session: VTokBaseSession)
    func hangupCall(session: VTokBaseSession)
    func flipCamera(session: VTokBaseSession, state: CameraType)
    func mute(session: VTokBaseSession, state: AudioState)
    func speaker(session: VTokBaseSession, state: SpeakerState)
    func disableVideo(session: VTokBaseSession, state: VideoState)
}

class CallingViewModelImpl: NSObject, CallingViewModel, CallingViewModelInput {

    private let router: CallingRouter
    var output: CallingViewModelOutput?
    var vtokSdk: VideoTalkSDK?
    var participants: [Participant]?
    var screenType: ScreenType
    var session: VTokBaseSession?
    var users: [User]?
    var player: AVAudioPlayer?
    var counter = 0
    var timer = Timer()
    var broadcastData: BroadcastData?
    let wormhole = MMWormhole(applicationGroupIdentifier: AppsGroup.group,
                              optionalDirectory: "wormhole")
    
    init(router: CallingRouter,
         vtokSdk: VideoTalkSDK,
         participants: [Participant]? = nil,
         screenType: ScreenType,
         session: VTokBaseSession? = nil,
         users: [User]? = nil,
         broadcastData: BroadcastData?) {
        self.router = router
        self.vtokSdk = vtokSdk
        self.participants = participants
        self.screenType = screenType
        self.session = session
        self.users = users
        self.broadcastData = broadcastData
    }
    
    func viewModelDidLoad() {
        addNotificationObserver()
        if let baseSession = session, baseSession.state == .receivedSessionInitiation {
            vtokSdk?.set(sessionDelegate: self, for: baseSession)
        }
        
        loadViews()
        listenForPublicURL()
        

    }
    
    func addNotificationObserver(){
          // Add Key-Value observer on isCaptured property of uiscreen.main
        UIScreen.main.addObserver(self, forKeyPath: "captured", options: .new, context: nil)

      }
    
    // MARK:- Key-Value Observer callback

      override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
          if keyPath == "captured" {

            if !UIScreen.main.isCaptured {
              //    UIApplication.shared.isIdleTimerDisabled = false
                guard let options = broadcastData?.broadcastOptions,
                      let sdk = vtokSdk,
                    let session = session
                else {return}
                switch options {
                case .screenShareWithAppAudioAndVideoCall:
                    sdk.hangup(session: session)
                case .screenShareWithVideoCall:
                    sdk.hangup(session: session)
              
                case .screenShareWithAppAudio:
                    output?(.dismissCallView)
                case .screenShareWithMicAudio:
                    output?(.dismissCallView)
                case .videoCall:
                    output?(.dismissCallView)
                }
                
              }

          }

      }
    
    private func listenForScreenShareSession() {
        wormhole.listenForMessage(withIdentifier: "screenShareSessionDidInitiated", listener: { [weak self] (messageObject) -> Void in
            if let message = messageObject as? String {
                self?.setScreenShareSession(with: message)
            }
         
        })
    }
    
    private func listenForPublicURL() {
        wormhole.listenForMessage(withIdentifier: "didGetPublicURL", listener: { [weak self] (messageObject) -> Void in
            if let message = messageObject as? String {
                self?.output?(.updateURL(url: message))
            }
         
        })
    }
    
    private func setScreenShareSession(with message: String) {
        guard let data = message.data(using: .utf8) else {return }
        session = try! JSONDecoder().decode(VTokBaseSessionInit.self, from: data)
        guard let from = session?.from, let to = session?.to, let sessionUUID = session?.sessionUUID else{return}
        let baseSession = VTokBaseSessionInit(from: from, to: to, sessionUUID: sessionUUID, sessionMediaType: .videoCall, callType: .onetomany)
        output?(.loadBroadcastView(session: baseSession))
        
    }
    
    func viewModelWillAppear() {
        
    }
    
    private func loadViews() {
        switch screenType {
        case .audioView:
            let sessionUUID = getRequestId()
            makeSession(with: .audioCall, sessionUUID: sessionUUID, associatedSessionUUID: nil)
        case .videoView:
            let sessionUUID = getRequestId()
            makeSession(with: .videoCall, sessionUUID: sessionUUID, associatedSessionUUID: nil)
        case .incomingCall:
            guard let session = session else {return}
            guard let selectedUser =  users?.filter({$0.refID == session.to.first}).first else {return}
            playSound()
            output?(.loadIncomingCallView(session: session, user: selectedUser))
            self.session = session
            callHangupHandling()
        case .videoAndScreenShare:
            handleBroadcast()
    
        }
    }
    
    private func handleBroadcast() {
        guard let data = broadcastData else { return }
        switch data.broadcastOptions {
        case .screenShareWithAppAudio, .screenShareWithMicAudio:
            let sessionUUID = getRequestId()
            guard let message = getScreenShareDataString(for: sessionUUID, with: nil) else {return}
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.wormhole.passMessageObject(message, identifier: "InitScreenSharingSdk")
            })
        case .videoCall:
            let sessionUUID = getRequestId()
            makeSession(with: .videoCall, sessionUUID: sessionUUID, associatedSessionUUID: nil)
        case .screenShareWithAppAudioAndVideoCall, .screenShareWithVideoCall:
            let callSessionUUID: String = getRequestId()
            let screenShareUUID: String = getRequestId()
            makeSession(with: .videoCall, sessionUUID: callSessionUUID, associatedSessionUUID: screenShareUUID)
            guard let message = getScreenShareDataString(for: screenShareUUID, with: callSessionUUID) else {return}
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.wormhole.passMessageObject(message, identifier: "InitScreenSharingSdk")
            })
        
        }
    }
    
    //For all of your viewBindings
    enum Output {
        case loadView(mediaType: SessionMediaType)
        case loadIncomingCallView(session: VTokBaseSession, user: User)
        case configureLocal(view: UIView, session: VTokBaseSession)
        case configureRemote(streams: [UserStream], session: VTokBaseSession)
        case updateVideoView(session: VTokBaseSession)
        case loadAudioView
        case dismissCallView
        case updateView(session: VTokBaseSession)
        case updateHangupButton(status: Bool)
        case loadBroadcastView(session: VTokBaseSession)
        case updateURL(url: String)
    }
    
    @discardableResult
    private func makeSession(with sessionMediaType: SessionMediaType,sessionUUID: String, associatedSessionUUID: String? ) -> String? {
        guard let user = VDOTOKObject<UserResponse>().getData(),
              let refID = user.refID
        else {return nil}
        guard let participents = participants, let broadcast = broadcastData else {return nil}
        let participantsRefIds = participents.map({$0.refID}).filter({$0 != user.refID })
        
        let requestId = sessionUUID
        let baseSession = VTokBaseSessionInit(from: refID,
                                              to: broadcast.broadcastType == .group ? participantsRefIds : [],
                                              requestID: requestId,
                                              sessionUUID: requestId,
                                              sessionMediaType: sessionMediaType,
                                              callType: .onetomany,
                                              sessionType: .call,
                                              associatedSessionUUID: associatedSessionUUID,broadcastType: broadcast.broadcastType, broadcastOption: broadcast.broadcastOptions)
        if associatedSessionUUID == nil {
            output?(.loadBroadcastView(session: baseSession))
//            output?(.loadView(mediaType: sessionMediaType))
        }else {
            output?(.loadBroadcastView(session: baseSession))
        }
        
        vtokSdk?.initiate(session: baseSession, sessionDelegate: self)
        callHangupHandling()
        return requestId
    }
    
    private func getRequestId() -> String {
        let generatable = IdGenerator()
        guard let response = VDOTOKObject<UserResponse>().getData() else {return ""}
        let timestamp = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timestamp)
        let time = Date(timeIntervalSince1970: TimeInterval(myTimeInterval)).stringValue()
        let tenantId = "12345"
        let token = generatable.getUUID(string: time + tenantId + response.refID!)
        return token
        
    }
    
    deinit {
        removeObservers()
    }
    
    func removeObservers() {
        UIScreen.main.removeObserver(self, forKeyPath: "captured")
    }
}

extension CallingViewModelImpl {
    func getScreenShareDataString(for sessionUUID: String, with associatedSessionUUID: String?) -> NSString? {
        
        guard let authResponse = VDOTOKObject<AuthenticateResponse>().getData() else { return nil }
        guard let user = VDOTOKObject<UserResponse>().getData(),
              let token = user.authorizationToken,
              let refID = user.refID,
              let broadcastData = broadcastData
        else {return nil}
        guard let participents = participants else {return nil}
        let participantsRefIds = participents.map({$0.refID}).filter({$0 != user.refID })
        let session = VTokBaseSessionInit(from: refID,
                                          to: participantsRefIds,
                                          sessionUUID: sessionUUID,
                                          sessionMediaType: .videoCall,
                                          callType: .onetomany,
                                          sessionType: .screenshare,
                                          associatedSessionUUID: associatedSessionUUID,
                                          broadcastType: broadcastData.broadcastType,
                                          broadcastOption: broadcastData.broadcastOptions)

        let data = ScreenShareAppData(url: authResponse.mediaServerMap.completeAddress,
                                      authenticationToken: token,
                                      baseSession: session)
        self.session = session
        output?(.loadBroadcastView(session: session))
        let jsonData = try! JSONEncoder().encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)! as NSString
        
        return jsonString
    }
}

extension CallingViewModelImpl {
    func acceptCall(session: VTokBaseSession) {
        stopSound()
        
        switch session.callType {
        case .manytomany, .onetoone:
            switch session.sessionMediaType {
            case .audioCall:
                output?(.loadView(mediaType: .audioCall))
                output?(.updateVideoView(session: session))
            case .videoCall:
                output?(.loadView(mediaType: .videoCall))
                output?(.updateVideoView(session: session))
            
            }
        case .onetomany:
            output?(.loadBroadcastView(session: session))
            output?(.updateVideoView(session: session))
        }
        output?(.updateHangupButton(status: false))
        vtokSdk?.accept(session: session)
        
    }
    
    func rejectCall(session: VTokBaseSession) {
        vtokSdk?.reject(session: session)
        timer.invalidate()
        counter = 0
        output?(.dismissCallView)
        stopSound()
    }
    
    func hangupCall(session: VTokBaseSession) {
        stopSound()
        timer.invalidate()
        counter = 0
        vtokSdk?.hangup(session: session)
    }
    
    func mute(session: VTokBaseSession, state: AudioState) {
        vtokSdk?.mute(session: session, state: state)
    }
    
    func speaker(session: VTokBaseSession, state: SpeakerState) {
        vtokSdk?.speaker(session: session, state: state)
    }
    
    func flipCamera(session: VTokBaseSession, state: CameraType) {
        vtokSdk?.switchCamera(session: session, to: state)
    }
    
    func disableVideo(session: VTokBaseSession, state: VideoState) {
        vtokSdk?.disableVideo(session: session, State: state)
    }
    
}

extension CallingViewModelImpl: SessionDelegate {
  
    func configureLocalViewFor(session: VTokBaseSession, renderer: UIView) {
        output?(.configureLocal(view: renderer, session: session))
    }
    
    func configureRemoteViews(for session: VTokBaseSession, with streams: [UserStream]) {
        output?(.configureRemote(streams: streams, session: session))
    }
    
    func stateDidUpdate(for session: VTokBaseSession) {
        self.session = session
        switch session.state {
        case .ringing:
            output?(.updateView(session: session))
        case .connected:
          didConnect()
        case .rejected:
          sessionReject()
        case .missedCall:
            sessionMissed()
        case .hangup:
            sessionHangup()
        case .tryingToConnect:
            output?(.updateView(session: session))
        default:
            break
        }
    }
    
    func didGetPublicUrl(for session: VTokBaseSession, with url: String) {
        output?(.updateURL(url: url))
    }
}

extension CallingViewModelImpl {
    private func didConnect() {
        stopSound()
        timer.invalidate()
        counter = 0
        guard let session = session else {return}
        output?(.updateView(session: session))
        output?(.updateHangupButton(status: true))
    }
    
    private func sessionReject() {
        DispatchQueue.main.async {[weak self] in
            self?.output?(.dismissCallView)
            self?.stopSound()
        }
    }
    
    private func sessionMissed() {
        DispatchQueue.main.async {[weak self] in
            self?.output?(.dismissCallView)
            self?.stopSound()
        }
    }
    
    private func sessionHangup() {
        DispatchQueue.main.async {[weak self] in
            
            self?.output?(.dismissCallView)
        }
    }
}

extension CallingViewModelImpl {
    func stopSound() {
        player?.stop()
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "iphone_11_pro", withExtension: "mp3") else {
            print("url not found")
            return
        }

        do {
            /// this codes for making this app ready to takeover the device audio
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)

            /// change fileTypeHint according to the type of your audio file (you can omit this)

            /// for iOS 11 onward, use :
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /// else :
            /// player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)

            // no need for prepareToPlay because prepareToPlay is happen automatically when calling play()
            player!.numberOfLoops = 3
            player!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
}

extension CallingViewModelImpl {
    func callHangupHandling() {
        timer.invalidate()
        counter = 0
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(timerAction),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc func timerAction() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.counter += 1
            if self.counter > 10000 {
                guard let session = self.session else {return}
                self.counter = 0
                self.timer.invalidate()
                switch session.sessionDirection {
                case .incoming:
                    self.vtokSdk?.reject(session: session)
                    self.output?(.dismissCallView)
                case .outgoing:
                    self.vtokSdk?.hangup(session: session)
                    
                }
                
               
            }
        }
      
        
    }
}
