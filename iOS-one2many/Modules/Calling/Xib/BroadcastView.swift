//
//  BroadcastView.swift
//  iOS-one2many
//
//  Created by usama farooq on 09/07/2021.
//

import UIKit
import iOSSDKStreaming
import MMWormhole
import ReplayKit

protocol BroadcastDelegate: AnyObject {
    func didTapMute(for baseSession: VTokBaseSession, state: AudioState)
    func didTapHangUp(for session: VTokBaseSession)
    func didTapSpeaker(for session: VTokBaseSession, state: SpeakerState)
    func didTapFlipCamera(for session: VTokBaseSession, type: CameraType)
    
}

class BroadcastView: UIView {
    
    @IBOutlet weak var localView: UIView!
    @IBOutlet weak var smallLocalView: UIView!
    @IBOutlet weak var screenShareBtn: UIButton!
    @IBOutlet weak var hangupBtn: UIButton!
    @IBOutlet weak var screenShareAudio: UIButton!
    @IBOutlet weak var cameraSwitchIcon: UIButton!
    @IBOutlet weak var speakerIcon: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var broadCastDummyView: UIStackView!
    
    var publicURL: String?
    var session: VTokBaseSession?
    weak var delegate: BroadcastDelegate?
    
    let wormhole = MMWormhole(applicationGroupIdentifier: AppsGroup.group,
                              optionalDirectory: "wormhole")
    
    @IBAction func didTapAppAudio(_ sender: UIButton) {
        screenShareAudio.isSelected = !sender.isSelected
        let message = getScreenShareAudio(state: screenShareAudio.isSelected ? .none : .passAll)
        wormhole.passMessageObject(message, identifier: "updateAudioState")
    }
    
    @IBAction func didTapScreenShare(_ sender: UIButton) {
        screenShareBtn.isSelected = !sender.isSelected
        let message = getScreenShareScreen(state: screenShareBtn.isSelected ? .none : .passAll)
        wormhole.passMessageObject(message, identifier: "updateScreenState")
    }
    
    @IBAction func didTapHangup(_ sender: UIButton) {
        guard let session = session else {return}
        delegate?.didTapHangUp(for: session)
    }
    
    @IBAction func didTapFlip(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let session = session else {return}
        delegate?.didTapFlipCamera(for: session, type: sender.isSelected ? .front : .rear)
    }
    
    @IBAction func didTapSpeaker(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let session = session else {return}
        delegate?.didTapSpeaker(for: session, state: sender.isSelected ? .onSpeaker : .onEarPiece)
    }
    
    @IBAction func didTapMute(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let session = session else {return}
        delegate?.didTapMute(for: session, state: sender.isSelected ? .mute : .unMute)
        
    }
    
    @IBAction func didTapCopyURL(_ sender: UIButton) {
        guard let url = publicURL else { return }
        print("<<<<<public url \(url)")
        let pastBoard = UIPasteboard.general
        pastBoard.string = url
    }
    
    private func getScreenShareScreen(state: ScreenShareBytes) -> NSString {
        let data = ScreenShareScreenState(screenShareScreen: state)
        let jsonData = try! JSONEncoder().encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)! as NSString
        return jsonString
    }
    
    private func getScreenShareAudio(state: ScreenShareBytes) -> NSString {
        let data = ScreenShareAudioState(screenShareAudio: state)
        let jsonData = try! JSONEncoder().encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)! as NSString
        return jsonString
    }
    
    func updateView(with session: VTokBaseSession) {
        self.session = session
       
        switch session.sessionDirection {
        case .incoming:
            setIncomingView(for: session)
        case .outgoing:
            guard let options = session.broadcastOption else {return}
            setOutGoingView(for: options)
        }
    }
    
    func updateURL(with url: String) {
        publicURL = url
    }
    
    func configureView(with userStreams: [UserStream], and session: VTokBaseSession) {
        guard let stream = userStreams.first else {return}
        self.session = session
        setIncomingView(for: session)
        setViewsForIncoming(session: session, with: stream)
    }
    
    private func setViewsForIncoming(session: VTokBaseSession, with userStream: UserStream) {
        switch session.sessionType {
        case .call:
            if session.associatedSessionUUID != nil {
                smallLocalView.isHidden = false
                smallLocalView.removeAllSubViews()
                smallLocalView.addSubview(userStream.renderer)
                userStream.renderer.translatesAutoresizingMaskIntoConstraints = false
                userStream.renderer.fixInSuperView()
            } else {
                localView.removeAllSubViews()
                localView.addSubview(userStream.renderer)
                smallLocalView.isHidden = true
                userStream.renderer.translatesAutoresizingMaskIntoConstraints = false
                userStream.renderer.fixInSuperView()
            }
         
            
            
        case .screenshare:
            localView.removeAllSubViews()
            localView.addSubview(userStream.renderer)
            userStream.renderer.translatesAutoresizingMaskIntoConstraints = false
            userStream.renderer.fixInSuperView()
        }
    }
    
    func setViewsForOutGoing(session: VTokBaseSession, renderer: UIView) {
        localView.isHidden = false
        localView.removeAllSubViews()
        localView.addSubview(renderer)
        renderer.translatesAutoresizingMaskIntoConstraints = false
        renderer.fixInSuperView()
    }

    private func setIncomingView(for session: VTokBaseSession) {
        
        if let _ = session.associatedSessionUUID {
            screenShareBtn.isHidden = true
            screenShareAudio.isHidden = true
            cameraSwitchIcon.isHidden = true
            speakerIcon.isHidden = false
            smallLocalView.isHidden = false
            muteButton.isHidden = true
        } else {
            screenShareBtn.isHidden = true
            screenShareAudio.isHidden = true
            cameraSwitchIcon.isHidden = true
            speakerIcon.isHidden = false
            smallLocalView.isHidden = true
            muteButton.isHidden = true
        }
     
    }
    
    private func setOutGoingView(for options: BroadcastOptions) {
        
        switch options {
        case .screenShareWithAppAudio, .screenShareWithMicAudio:
            screenShareBtn.isHidden = false
            screenShareAudio.isHidden = false
            cameraSwitchIcon.isHidden = true
            speakerIcon.isHidden = true
            smallLocalView.isHidden = true
            muteButton.isHidden = true
            broadCastDummyView.isHidden = false
            addRPViewToSSButton()
        case .videoCall:
            screenShareBtn.isHidden = true
            screenShareAudio.isHidden = true
            cameraSwitchIcon.isHidden = false
            speakerIcon.isHidden = true
            smallLocalView.isHidden = true
            muteButton.isHidden = false
            broadCastDummyView.isHidden = true
        case .screenShareWithAppAudioAndVideoCall, .screenShareWithVideoCall:
            screenShareBtn.isHidden = false
            screenShareAudio.isHidden = false
            cameraSwitchIcon.isHidden = false
            speakerIcon.isHidden = true
            smallLocalView.isHidden = true
            muteButton.isHidden = false
            broadCastDummyView.isHidden = false
            addRPViewToSSButton()
        }
        
    }

}

extension BroadcastView {
    static func loadView() -> BroadcastView {
        let viewsArray = Bundle.main.loadNibNamed("BroadcastView", owner: self, options: nil) as AnyObject as? NSArray
            guard (viewsArray?.count)! < 0 else{
                let view = viewsArray?.firstObject as! BroadcastView
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }
        return BroadcastView()
    }
    
    func addRPViewToSSButton() {
        
        let recordingView = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        recordingView.preferredExtension = AppsGroup.SCREEN_SHARE_PREFERED_EXTENSION
        guard let options = session?.broadcastOption else {return}
        
        switch options {
        case .screenShareWithMicAudio:
            recordingView.showsMicrophoneButton = true
        default:
            recordingView.showsMicrophoneButton = false
        }
        recordingView.tintColor = .white
        
        for subView in recordingView.subviews {
            if subView is UIButton, let button = subView as? UIButton{
                if let _ = UIImage(named: "EndScreenShare") {
                    button.setImage(nil, for: .normal)
                }
            }
        }
        hangupBtn.addSubview(recordingView)

    }
}

