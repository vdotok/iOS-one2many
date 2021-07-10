//
//  BroadcastView.swift
//  iOS-one2many
//
//  Created by usama farooq on 09/07/2021.
//

import UIKit
import iOSSDKStreaming
import MMWormhole

class BroadcastView: UIView {
    
    @IBOutlet weak var localView: UIView!
    @IBOutlet weak var smallLocalView: UIView!
    @IBOutlet weak var screenShareBtn: UIButton!
    @IBOutlet weak var hangupBtn: UIButton!
    @IBOutlet weak var screenShareAudio: UIButton!
    @IBOutlet weak var cameraSwitchIcon: UIButton!
    @IBOutlet weak var speakerIcon: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    var session: VTokBaseSession?
    
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
    
    func updateView(with session: VTokBaseSession)  {
        switch session.sessionDirection {
        case .incoming:
            setIncomingView()
        case .outgoing:
            setOutGoingView()
        }
    }
    
    func configureView(with userStreams: [UserStream], and session: VTokBaseSession) {
        guard let stream = userStreams.first else {return}
        setViewsForIncoming(session: session, with: stream)
    }
    
    private func setViewsForIncoming(session: VTokBaseSession, with userStream: UserStream) {
        switch session.sessionType {
        case .call:
            smallLocalView.isHidden = false
            smallLocalView.removeAllSubViews()
            smallLocalView.addSubview(userStream.renderer)
            userStream.renderer.translatesAutoresizingMaskIntoConstraints = false
            userStream.renderer.fixInSuperView()
            
        case .screenshare:
            localView.isHidden = false
            localView.removeAllSubViews()
            localView.addSubview(userStream.renderer)
            userStream.renderer.translatesAutoresizingMaskIntoConstraints = false
            userStream.renderer.fixInSuperView()
        }
    }
    
    func setViewsForOutGoing(session: VTokBaseSession, renderer: UIView) {
        localView.removeAllSubViews()
        localView.addSubview(renderer)
        renderer.translatesAutoresizingMaskIntoConstraints = false
        renderer.fixInSuperView()
    }

    private func setIncomingView() {
        screenShareBtn.isHidden = true
        screenShareAudio.isHidden = true
        cameraSwitchIcon.isHidden = true
        speakerIcon.isHidden = true
        smallLocalView.isHidden = true
    }
    
    private func setOutGoingView() {
        screenShareBtn.isHidden = false
        screenShareAudio.isHidden = false
        cameraSwitchIcon.isHidden = false
        speakerIcon.isHidden = false
        smallLocalView.isHidden = false
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
}

