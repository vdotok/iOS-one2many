//
//  BroadcastView.swift
//  iOS-one2many
//
//  Created by usama farooq on 09/07/2021.
//


//MARKTags

// 0 -> call renderer
// 1 -> paused call view
// 2 -> screenshare renderer
// 3 -> paused screenshare view



import UIKit
import iOSSDKStreaming
import MMWormhole
import ReplayKit

protocol BroadcastDelegate: AnyObject {
    func didTapMute(for baseSession: VTokBaseSession, state: AudioState)
    func didTapHangUp(for session: VTokBaseSession)
    func didTapSpeaker(for session: VTokBaseSession, state: SpeakerState)
    func didTapFlipCamera(for session: VTokBaseSession, type: CameraType)
    func didTapVideo(for session: VTokBaseSession, type: VideoState)
    
}

class BroadcastView: UIView {
   
    @IBOutlet weak var localView: UIView!
    @IBOutlet weak var smallLocalView: DraggableView! {
        didSet {
            smallLocalView.clipsToBounds = true
            smallLocalView.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var screenShareBtn: UIButton!
    @IBOutlet weak var hangupBtn: UIButton!
    @IBOutlet weak var screenShareAudio: UIButton!
    @IBOutlet weak var cameraSwitchIcon: UIButton!
    @IBOutlet weak var speakerIcon: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var broadCastDummyView: UIStackView!
    @IBOutlet weak var copyUrlBtn: UIButton! {
        didSet {
            copyUrlBtn.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var broadCastTitle: UILabel!
    @IBOutlet weak var broadCastIcon: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    
    
    
    var screenSharePausedView: UIView {
        
        let screenSharePausedView = UIView()
        screenSharePausedView.backgroundColor = .white
        let broadCastView = UIImageView(image: UIImage(named: "broadcast"))
        broadCastView.addConstraintsFor(width: 80, and: 80)
        let message = UILabel()
        message.numberOfLines = 0
        message.text = "Stream paused"
        message.setContentCompressionResistancePriority(.required, for: .vertical)
        let stackView = UIStackView(arrangedSubviews: [message, broadCastView])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        
        screenSharePausedView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.fixInMiddleOfSuperView()
        
        screenSharePausedView.tag = 1
        
        return screenSharePausedView
    }
    
    
    var videoPausedView: UIView {
        
        let videoPausedView = UIView()
        videoPausedView.backgroundColor = .white
        let broadCastView = UIImageView(image: UIImage(named: "broadcast"))
        broadCastView.addConstraintsFor(width: 80, and: 80)
        broadCastView.contentMode = .scaleAspectFit
        let message = UILabel()
        message.numberOfLines = 0
        message.text = "Stream paused"
        message.setContentCompressionResistancePriority(.required, for: .vertical)
        let stackView = UIStackView(arrangedSubviews: [message, broadCastView])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        stackView.alignment = .center
        
        videoPausedView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.fixInMiddleOfSuperView()
        
        videoPausedView.tag = 0
        
        return videoPausedView
    }
    
    
    
    
    var publicURL: String?
    var session: VTokBaseSession?
    weak var delegate: BroadcastDelegate?
    private var counter: Int = 0
    let wormhole = MMWormhole(applicationGroupIdentifier: AppsGroup.group,
                              optionalDirectory: "wormhole")
    private weak var timer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapLocalView))
        tap.numberOfTapsRequired = 2
        smallLocalView.addGestureRecognizer(tap)
        smallLocalView.frame = CGRect(x: UIScreen.main.bounds.size.width - smallLocalView.frame.size.width + 1.1, y: UIScreen.main.bounds.size.height - smallLocalView.frame.size.height * 1.1, width: 120, height: 170)
    }
    
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
    
    @IBAction func didTapVideo(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let session = session else {return}
        delegate?.didTapVideo(for: session, type: sender.isSelected ? .videoDisabled : .videoEnabled)
    }
    
    @objc func didTapLocalView()  {
        guard let session = session else {return}
        
        switch session.sessionDirection {
        case .incoming:
            guard let smallView = smallLocalView, let largeView = localView else {return}
            let smallSubView = smallView.subviews.first!
            let largeSubView = largeView.subviews.first!
            smallView.removeAllSubViews()
            largeView.removeAllSubViews()
            smallView.addSubview(largeSubView)
            largeSubView.fixInSuperView()
            largeView.addSubview(smallSubView)
            smallSubView.fixInSuperView()
            let callTag = smallView.tag
            let ssTag = largeView.tag
            smallView.tag = ssTag
            largeView.tag = callTag
            
        default:
            break
        }
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
            broadCastTitle.isHidden = true
            cameraButton.isHidden = true
            setIncomingView(for: session)
        case .outgoing:
            if session.sessionType == .call {
                cameraButton.isHidden = false
            }
            guard let broadCastType = session.broadcastType
            else {return}
            configureTimer()
            switch broadCastType {
            case .group:
                broadCastTitle.text = "Group BroadCast"
                copyUrlBtn.isHidden = true
            case .publicURL:
                broadCastTitle.text = "Public BroadCast"
                copyUrlBtn.isHidden = false
            }
            
            setOutGoingView(for: session)
            
        }
    }
    
    func updateURL(with url: String) {
        publicURL = url
        copyUrlBtn.isEnabled = true
        copyUrlBtn.backgroundColor = .appDarkGreenColor
    }
    
    func configureView(with userStreams: [UserStream], and session: VTokBaseSession) {
        guard let stream = userStreams.first else {return}
        configureTimer()
        self.session = session
        setIncomingView(for: session)
        setViewsForIncoming(session: session, with: stream)
    }
    
    
    func handleStateView(session: VTokBaseSession, with userStream: UserStream){
        
        guard let stateInfo = userStream.stateInformation else {
            return
        }
   
        if stateInfo.videoInformation == 0 {
            switch session.sessionType {
            case .call:
                let callContainerView : UIView! = localView.tag == 0 ? localView : smallLocalView
                callContainerView.removeAllSubViews()
                let videoPausedView = self.videoPausedView
                callContainerView.addSubview(videoPausedView)
                videoPausedView.fixInSuperView()
                
            case .screenshare:
                let ssContainerView : UIView! = localView.tag == 1 ? localView : smallLocalView
                ssContainerView.removeAllSubViews()
                let ssPausedView = self.screenSharePausedView
                ssContainerView.addSubview(ssPausedView)
                ssPausedView.fixInSuperView()
        }
        
        }
        else {
            
                switch session.sessionType {
                case .call:
                    let callContainerView : UIView! = localView.tag == 0 ? localView : smallLocalView
                    callContainerView.removeAllSubViews()
                    callContainerView.addSubview(userStream.renderer)
                    userStream.renderer.fixInSuperView()
                    
                case .screenshare:
                    let ssContainerView : UIView! = localView.tag == 1 ? localView : smallLocalView
                    ssContainerView.removeAllSubViews()
                    ssContainerView.addSubview(userStream.renderer)
                    userStream.renderer.fixInSuperView()
            }
        }
        
    }
    
    
    private func setViewsForIncoming(session: VTokBaseSession, with userStream: UserStream) {
        
        switch session.sessionType {
        case .call:
            if session.associatedSessionUUID != nil {
                let callView: UIView! = localView.tag == 0 ? localView : smallLocalView
                callView.isHidden = false
                callView.removeAllSubViews()
                callView.addSubview(userStream.renderer)
                userStream.renderer.fixInSuperView()
                callView.tag = callView.tag
            } else {
                
                localView.removeAllSubViews()
                localView.addSubview(userStream.renderer)
                smallLocalView.isHidden = true
                userStream.renderer.translatesAutoresizingMaskIntoConstraints = false
                userStream.renderer.fixInSuperView()
                localView.tag = 0
            }
        case .screenshare:
            
            let ssView: UIView! = localView.tag == 1 ? localView : smallLocalView
            let callView: UIView! = localView.tag == 0 ? localView : smallLocalView
            
            titlelabel.isHidden = true
            broadCastDummyView.isHidden = true
            ssView.removeAllSubViews()
            ssView.addSubview(userStream.renderer)
            userStream.renderer.fixInSuperView()
            ssView.tag = ssView.tag
            if session.associatedSessionUUID != nil {
                ssView.isHidden = false
                callView.isHidden = false
            } else {
                ssView.isHidden = false
                callView.isHidden = true
            }
        }
        
        handleStateView(session: session, with: userStream)
        
       
        
    }
    
    func setViewsForOutGoing(session: VTokBaseSession, renderer: UIView) {
        localView.isHidden = false
        localView.removeAllSubViews()
        localView.addSubview(renderer)
        renderer.translatesAutoresizingMaskIntoConstraints = false
        renderer.fixInSuperView()
    }

    private func setIncomingView(for session: VTokBaseSession) {
        copyUrlBtn.isHidden = true
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
    
    private func setOutGoingView(for session: VTokBaseSession) {
        
        guard let options = session.broadcastOption else {return}
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
            titlelabel.isHidden = true
            broadCastIcon.isHidden = true
            if session.broadcastType == .publicURL {
                copyUrlBtn.isHidden = false
                broadCastDummyView.isHidden = false
            }
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


extension BroadcastView {
    private func configureTimer() {
        timer?.invalidate()
        timer = nil
        counter = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @objc private func timerAction() {
        counter += 1
        let (h, m, s) = secondsToHoursMinutesSeconds(seconds: counter)
        var timeString = ""
        if h > 0 {
            timeString += intervalFormatter(interval: h) + ":"
        }
        timeString += intervalFormatter(interval: m) + ":" +
                        intervalFormatter(interval: s)
        timerLabel.text = timeString
    }
    
    private func intervalFormatter(interval: Int) -> String {
        if interval < 10 {
            return "0\(interval)"
        }
        return "\(interval)"
    }
    
    private func secondsToHoursMinutesSeconds (seconds :Int) -> (hours: Int, minutes: Int, seconds: Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
