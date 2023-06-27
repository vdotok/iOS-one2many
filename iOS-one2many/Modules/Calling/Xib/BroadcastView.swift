//
//  BroadcastView.swift
//  iOS-one2many
//
//  Created by usama farooq on 09/07/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
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
import AVKit
import MaterialComponents.MaterialSnackbar

protocol BroadcastDelegate: AnyObject {
    func didTapMute(for baseSession: VTokBaseSession, state: AudioState)
    func didTapHangUp(for session: VTokBaseSession)
    func didTapSpeaker(for session: VTokBaseSession, state: SpeakerState)
    func didTapFlipCamera(for session: VTokBaseSession, type: CameraType)
    func didTapVideo(for session: VTokBaseSession, type: VideoState)

    func didTapStream( with state: StreamStatus )

    func didTapRoute()

    
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
    @IBOutlet weak var streamcontrolView: UIStackView!{
        didSet{
            streamcontrolView.isHidden = true
        }
    }
    @IBOutlet weak var copyUrlBtn: UIButton! {
        didSet {
            copyUrlBtn.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var broadCastTitle: UILabel!
    @IBOutlet weak var broadCastIcon: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var connectedUser: UILabel!
    
    @IBOutlet weak var routePickerViewContainer: UIView!
    
    var externalWindow: UIWindow!
    var secondScreenView : UIView?
    var testScreen: UIScreen = UIScreen()
    var selectedStreams: [UserStream] = []
    
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
    var appDidEnterBackgroundDate :Date?
    var session: VTokBaseSession? {
        didSet{
            if session?.sessionDirection == .incoming{
                streamcontrolView?.isHidden = false
            }
        }
    }
    weak var delegate: BroadcastDelegate?
    private var counter: Int = 0
    let wormhole = MMWormhole(applicationGroupIdentifier: AppsGroup.APP_GROUP,
                              optionalDirectory: Constants.Wormhole)
    private weak var timer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addNotificationObserver()
        addRoutePicker()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapLocalView))
        tap.numberOfTapsRequired = 2
        smallLocalView.addGestureRecognizer(tap)
        smallLocalView.frame = CGRect(x: UIScreen.main.bounds.size.width - smallLocalView.frame.size.width + 1.1, y: UIScreen.main.bounds.size.height - smallLocalView.frame.size.height * 1.1, width: 120, height: 170)
        
    }
    
    
    
    @IBAction func didTapStream(_ sender: UIButton) {
        delegate?.didTapStream(with: .initiate)
    }
    
    
    @IBAction func didTapStreamPlay(_ sender: UIButton) {
        //        sender.isHighlighted = !sender.isHighlighted
        delegate?.didTapStream(with: sender.isHighlighted == true ? .play : .pause)
    }
    
    @IBAction func didTapStreamStop(_ sender: UIButton) {
        sender.isHighlighted = !sender.isHighlighted
        delegate?.didTapStream(with: .stop)
    }
    
    
    @IBAction func didTapPlay(_ sender: UIButton) {
        
        
        
    }
    @IBAction func didTapRoute(_ sender: UIButton) {
        delegate?.didTapRoute()
        
    }
    
    @IBAction func didTapAppAudio(_ sender: UIButton) {
        screenShareAudio.isSelected = !sender.isSelected
        let message = getScreenShareAudio(state: screenShareAudio.isSelected ? .none : .passAll)
        wormhole.passMessageObject(message, identifier: WormHoleConstants.updateAudioState)
    }
    
    @IBAction func didTapScreenShare(_ sender: UIButton) {
        screenShareBtn.isSelected = !sender.isSelected
        let message = getScreenShareScreen(state: screenShareBtn.isSelected ? .none : .passAll)
        wormhole.passMessageObject(message, identifier: WormHoleConstants.updateScreenState)
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
        delegate?.didTapSpeaker(for: session, state: sender.isSelected ? .onEarPiece: .onSpeaker)
    }
    
    @IBAction func didTapAppleTV(_ sender: UIButton) {
        setUpExternal(screen: testScreen, streams: selectedStreams)
    }
    
    @IBAction func didTapMute(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let session = session else {return}
        
        switch session.broadcastOption {
        case .screenShareWithMicAudio:
            screenShareAudio.isSelected = sender.isSelected
            let message = getScreenShareAudio(state: screenShareAudio.isSelected ? .none : .passAll)
            wormhole.passMessageObject(message, identifier: WormHoleConstants.updateAudioState)
        default:
            delegate?.didTapMute(for: session, state: sender.isSelected ? .mute : .unMute)
        }
        
        
        
    }
    
    @IBAction func didTapCopyURL(_ sender: UIButton) {
        guard let url = publicURL else { return }
        print("<<<<<public url \(url)")
        let pastBoard = UIPasteboard.general
        pastBoard.string = url
        let message = MDCSnackbarMessage()
        message.duration = 1
        message.text = "URL is Copied to Clipboard."
        MDCSnackbarManager.show(message)
    }
    
    @IBAction func didTapVideo(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let session = session else {return}
        delegate?.didTapVideo(for: session, type: sender.isSelected ? .videoDisabled : .videoEnabled)
    }
    
    func addNotificationObserver(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleScreenDidConnect(_:)), name: UIScreen.didConnectNotification , object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleScreenDidDisconnect(_:)), name: UIScreen.didDisconnectNotification , object: nil)
        
    }
    
    @objc  func handleScreenDidConnect(_ notification: Notification) {
        guard let newScreen = notification.object as? UIScreen else {
            return
        }
        self.testScreen = newScreen
        setUpExternal(screen: testScreen, streams: selectedStreams)
        
    }
    
    @objc   func handleScreenDidDisconnect(_ notification: Notification){
        guard externalWindow != nil else {
            return
        }
        externalWindow.isHidden = true
        externalWindow = nil
        
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
    
    func updateUser(count: Int) {
        if count != 0 {
            connectedUser.text = "+ \(count)"
            connectedUser.isHidden = false
        } else {
            connectedUser.isHidden = true
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
            switch session.broadcastOption {
            case .videoCall, .screenShareWithAppAudioAndVideoCall, .screenShareWithVideoCall:
                cameraButton.isHidden = false
            default:
                cameraButton.isHidden = true
            }
            guard let broadCastType = session.broadcastType
            else {return}
            if timer == nil {
                configureTimer()
            }
            
            switch broadCastType {
            case .group:
                broadCastTitle.text = session.data?.groupName
                copyUrlBtn.isHidden = true
            case .publicURL:
                broadCastTitle.text = "Public BroadCast"
                copyUrlBtn.isHidden = false
                
            default:
                break
            }
            VdotokShare.shared.setSession(session: session)
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
        hangupBtn.isUserInteractionEnabled = true
        self.selectedStreams = [stream]
        if timer == nil {
            configureTimer()
        }
        self.session = session
        VdotokShare.shared.setSession(session: session)
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
            if session.associatedSessionUuid != nil {
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
            if session.associatedSessionUuid != nil {
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
        hangupBtn.isUserInteractionEnabled = true
        copyUrlBtn.isHidden = true
        if let _ = session.associatedSessionUuid {
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
        case .screenShareWithAppAudio:
            screenShareBtn.isHidden = false
            screenShareAudio.isHidden = false
            cameraSwitchIcon.isHidden = true
            speakerIcon.isHidden = true
            smallLocalView.isHidden = true
            muteButton.isHidden = true
            broadCastDummyView.isHidden = false
            addRPViewToSSButton()
            
        case .screenShareWithMicAudio:
            screenShareBtn.isHidden = false
            screenShareAudio.isHidden = true
            cameraSwitchIcon.isHidden = true
            speakerIcon.isHidden = true
            smallLocalView.isHidden = true
            muteButton.isHidden = false
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
        case .screenShareWithAppAudioAndVideoCall:
            screenShareBtn.isHidden = false
            screenShareAudio.isHidden = false
            cameraSwitchIcon.isHidden = false
            speakerIcon.isHidden = true
            smallLocalView.isHidden = true
            muteButton.isHidden = false
            broadCastDummyView.isHidden = false
            addRPViewToSSButton()
            
        case .screenShareWithVideoCall:
            screenShareBtn.isHidden = false
            screenShareAudio.isHidden = true
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
        switch session?.broadcastOption {
        case .screenShareWithAppAudio, .screenShareWithMicAudio:
            listenForScene()
        default:
            break
        }
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

extension BroadcastView {
    func listenForScene() {
        NotificationCenter.default.addObserver(self, selector: #selector(didRecieveActive(notification:)), name: Notification.Name("sceneActive"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,selector:#selector(applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func applicationDidEnterBackground(_ notification: NotificationCenter) {
        appDidEnterBackgroundDate = Date()
    }

    @objc func applicationWillEnterForeground(_ notification: NotificationCenter) {
        guard let previousDate = appDidEnterBackgroundDate else { return }
        let calendar = Calendar.current
        let difference = calendar.dateComponents([.second], from: previousDate, to: Date())
        let seconds = difference.second!
        counter += seconds
    }
    
    @objc  func didRecieveActive(notification: Notification) {
        print(notification.object ?? "")
        guard let time = notification.userInfo?["interval"] as? TimeInterval else {return}
        counter += Int(time)
        
    }
}


extension BroadcastView {
    
    func addRoutePicker(){
        let routePickerView = AVRoutePickerView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        routePickerView.backgroundColor = UIColor.clear
        routePickerViewContainer.addSubview(routePickerView)
        routePickerView.prioritizesVideoDevices = true
        routePickerView.fixInSuperView()
    }
    
    
    
    
    
}

extension AVAudioSession {

func ChangeAudioOutput(presenterViewController : UIViewController) {
    
    let CHECKED_KEY = "checked"
    let IPHONE_TITLE = "iPhone"
    let HEADPHONES_TITLE = "Headphones"
    let SPEAKER_TITLE = "Speaker"
    let HIDE_TITLE = "Hide"
    
    var deviceAction = UIAlertAction()
    var headphonesExist = false
    
    let currentRoute = self.currentRoute
    
    let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    for input in self.availableInputs!{
        
        switch input.portType  {
        case AVAudioSession.Port.bluetoothA2DP, AVAudioSession.Port.bluetoothHFP, AVAudioSession.Port.bluetoothLE:
            let action = UIAlertAction(title: input.portName, style: .default) { (action) in
                do {
                    // remove speaker if needed
                    try self.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                    
                    // set new input
                    try self.setPreferredInput(input)
                } catch let error as NSError {
                    print("audioSession error change to input: \(input.portName) with error: \(error.localizedDescription)")
                }
            }
            
            if currentRoute.outputs.contains(where: {return $0.portType == input.portType}){
                action.setValue(true, forKey: CHECKED_KEY)
            }
            
            optionMenu.addAction(action)
            break
            
        case AVAudioSession.Port.builtInMic, AVAudioSession.Port.builtInReceiver:
            deviceAction = UIAlertAction(title: IPHONE_TITLE, style: .default) { (action) in
                do {
                    // remove speaker if needed
                    try self.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
//                    try self.setCategory(.playAndRecord, mode: .voiceChat, policy: .default, options: options)
                    // set new input
                    try self.setPreferredInput(input)
                } catch let error as NSError {
                    print("audioSession error change to input: \(input.portName) with error: \(error.localizedDescription)")
                }
            }
            
            if currentRoute.outputs.contains(where: {return $0.portType == input.portType}){
                deviceAction.setValue(true, forKey: CHECKED_KEY)
            }
            break
            
        case AVAudioSession.Port.headphones, AVAudioSession.Port.headsetMic:
            headphonesExist = true
            let action = UIAlertAction(title: HEADPHONES_TITLE, style: .default) { (action) in
                do {
                    // remove speaker if needed
                    try self.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                    
                    // set new input
                    try self.setPreferredInput(input)
                } catch let error as NSError {
                    print("audioSession error change to input: \(input.portName) with error: \(error.localizedDescription)")
                }
            }
            
            if currentRoute.outputs.contains(where: {return $0.portType == input.portType}){
                action.setValue(true, forKey: CHECKED_KEY)
            }
            
            optionMenu.addAction(action)
            break
        default:
            break
        }
    }
    
    if !headphonesExist {
        optionMenu.addAction(deviceAction)
    }
    
    let speakerOutput = UIAlertAction(title: SPEAKER_TITLE, style: .default, handler: {
        (alert: UIAlertAction!) -> Void in
        
        do {
            try self.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch let error as NSError {
            print("audioSession error turning on speaker: \(error.localizedDescription)")
        }
    })
    
    if currentRoute.outputs.contains(where: {return $0.portType == AVAudioSession.Port.builtInSpeaker}){
        speakerOutput.setValue(true, forKey: CHECKED_KEY)
    }
    
    optionMenu.addAction(speakerOutput)
    
    
    let cancelAction = UIAlertAction(title: HIDE_TITLE, style: .cancel, handler: {
        (alert: UIAlertAction!) -> Void in
      //  try! self.setCategory(.playback, mode: .default, policy: .longFormAudio, options: [])
    })
    optionMenu.addAction(cancelAction)
    presenterViewController.present(optionMenu, animated: true, completion: nil)
    
 }
}


extension BroadcastView {
    func setUpExternal(screen: UIScreen, streams: [UserStream]) {
        self.externalWindow = UIWindow(frame: screen.bounds)
        
        //windows require a root view controller
           // let viewcontroller = TVBroadCastBuilder().build(with: nil, userStreams: streams)
        self.externalWindow.rootViewController = UIViewController()
        
        
        
        
        //tell the window which screen to use
        self.externalWindow?.screen = screen
        
        let stream = streams.first!
        let renderer = stream.renderer
        self.externalWindow.addSubview(renderer)
        renderer.fixInSuperView()
        
        
        self.externalWindow?.isHidden = false

    }
}
