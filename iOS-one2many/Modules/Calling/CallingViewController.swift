//  
//  CallingViewController.swift
//  one-to-many-call
//
//  Created by usama farooq on 15/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import UIKit
import iOSSDKStreaming
import AVKit
import SnapKit


@available(iOS 15.0, *)
public class CallingViewController: UIViewController, AVPictureInPictureControllerDelegate{
    
    
    private var playerLayer: AVPlayerLayer!
    var pipController: AVPictureInPictureController!
    var pipContentSource: AVPictureInPictureController.ContentSource!
    let pipVideoCallViewController = AVPictureInPictureVideoCallViewController()
    // 你的自定义view
    var customView: UIView!
    var textView: UITextView!
    // 开启/关闭画中画按钮
    private var pipButton: UIButton!
    // timer
    private var displayerLink: CADisplayLink!

    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    
    
    

    var viewModel: CallingViewModel!
    var groupCallingView: GroupCallingView?
    var incomingCallingView: IncomingCall?
    var broadcastView: BroadcastView?
    var session : VTokBaseSession?
    var counter = 0
    var timer = Timer()
    
    
    
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        // 打印所有window
        print("画中画初始化后：\(UIApplication.shared.windows)")
        // 注意是 first window
        if let window = UIApplication.shared.windows.first {
            // 把自定义view加到画中画上
            window.addSubview(customView)
            // 使用自动布局
            customView.snp.makeConstraints { (make) -> Void in
                make.edges.equalToSuperview()
            }
        }
    }
    
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
//        startTimer()
        // 打印所有window
        print("画中画弹出后：\(UIApplication.shared.windows)")
    }
    
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
//        stopTimer()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        bindViewModel()
        viewModel.viewModelDidLoad()
        
        
        
        
        
        if AVPictureInPictureController.isPictureInPictureSupported() {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            } catch {
                print(error)
            }
            setupUI()
            setupPlayer()
//            setupPip()
            setupCustomView()
        
        } else {
            print("不支持画中画")
        }
        
        UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(UIBackgroundTaskIdentifier.invalid)
        }
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        
        
        
        
        stillImageOutput = AVCapturePhotoOutput()
        
        

        
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back ) //AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
                
                
                
//                DispatchQueue.global(qos: .background).async { //[weak self] in
//                    self.captureSession.startRunning()
//                    //Step 13
//                }
                
                
                captureSession.beginConfiguration()
                if #available(iOS 16.0, *) {
                    if captureSession.isMultitaskingCameraAccessSupported {
                        // Enable use of the camera in multitasking modes.
                        captureSession.isMultitaskingCameraAccessEnabled = true
                    }
                } else {
                    // Fallback on earlier versions
                }
                           captureSession.commitConfiguration()
                
                /* starting capture session */
//                DispatchQueue.global(qos: .default).async {
                DispatchQueue.global(qos: .background).async {
                    self.captureSession.startRunning()
                }
            }
            
            
            
            //Step 9
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }

       
        
        DispatchQueue.main.async {
            self.videoPreviewLayer.frame = self.playerLayer.bounds
        }
        
        // Do any additional setup after loading the view.
        
//        print("画中画初始化前：\(UIApplication.shared.windows)")
    }
    
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait
        customView.layer.addSublayer(videoPreviewLayer)
        
        //Step12
    }
    
    
    private func setupCustomView() {
        customView = UIView()
        customView.backgroundColor = .white
        
        textView = UITextView()
        textView.text = """
            文本文本开头
            这是自定义view，想放什么放什么
            这是自定义view，想放什么放什么
            这是自定义view，想放什么放什么
            这是自定义view，想放什么放什么
            这是自定义view，想放什么放什么
            文本
            文本
            文本
            文本文本结尾
            """
        textView.backgroundColor = .black
        textView.textColor = .white
        textView.isUserInteractionEnabled = false
        customView.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    
    private func setupUI() {
        pipButton = UIButton(type: .system)
        pipButton.setTitle("PIP Button", for: .normal)
        pipButton.addTarget(self, action: #selector(pipButtonClicked), for: .touchUpInside)
        view.addSubview(pipButton)
        pipButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
        
    }
    
    
    private func setupPlayer() {
        playerLayer = AVPlayerLayer()
        playerLayer.frame = .init(x: 90, y: 90, width: 200, height: 150)
        
        let mp4Video = Bundle.main.url(forResource: "emptyvid", withExtension: "mp4")
        let asset = AVAsset.init(url: mp4Video!)
        let playerItem = AVPlayerItem.init(asset: asset)
        
        let player = AVPlayer.init(playerItem: playerItem)
        playerLayer.player = player
        player.isMuted = true
        player.allowsExternalPlayback = true
        player.play()
        
        view.layer.addSublayer(playerLayer)
    }
    
    // 配置画中画
    private func setupPip() {
        
        
        
        
        pipController = AVPictureInPictureController.init(playerLayer: playerLayer)!
        pipController.delegate = self
        // 隐藏播放按钮、快进快退按钮
        pipController.setValue(1, forKey: "requiresLinearPlayback")
        // 进入后台自动开启画中画（必须处于播放状态）
        if #available(iOS 14.2, *) {
            pipController.canStartPictureInPictureAutomaticallyFromInline = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc private func pipButtonClicked() {
//        if pipController.isPictureInPictureActive {
//            pipController.stopPictureInPicture()
//        } else {
            
            pipVideoCallViewController.preferredContentSize = CGSize(width: 640, height: 480)
                            pipVideoCallViewController.view.addSubview(customView)
            
            pipContentSource = AVPictureInPictureController.ContentSource(
                                activeVideoCallSourceView: view,
                                contentViewController: pipVideoCallViewController)
            pipController = AVPictureInPictureController(contentSource: pipContentSource)
            pipController.canStartPictureInPictureAutomaticallyFromInline = true
            
            
            pipController.startPictureInPicture()
        
        
        captureSession.beginConfiguration()
        if #available(iOS 16.0, *) {
            if captureSession.isMultitaskingCameraAccessSupported {
                // Enable use of the camera in multitasking modes.
                captureSession.isMultitaskingCameraAccessEnabled = true
            }
        } else {
            // Fallback on earlier versions
        }
        
//        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewModelWillAppear()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("view will disapper")
    }
    
    fileprivate func bindViewModel() {

        viewModel.output = { [weak self] output in
            guard let self = self else {return}
            //handle all your bindings here
            switch output {
            case .configureLocal(let view, session: let session):
                self.configureLocalView(rendrer: view, session: session)
            case .configureRemote(let streams,let session):
                self.configureRemote(streams: streams, session: session)
            case .loadView(let mediaType):
                self.loadGroupCallingView(mediaType: mediaType)
            case .loadIncomingCallView(let session, let user):
                self.loadIncomingCallView(session: session, contact: user)
            case .dismissCallView:
                self.dismiss(animated: true, completion: nil)
            case .updateVideoView(let session):
                self.updateVideoView(session: session)
            case .updateView(let session):
                self.configureView(for: session)
            case .updateHangupButton(let status):
                self.handleHangup(status: status)
            case .loadBroadcastView(let session):
                self.loadBroadcastView(session: session)
            case .updateURL(let url):
                self.updateWith(URL: url)
            case .updateUsers(let count):
                self.broadcastView?.updateUser(count: count)
            default:
                break
            }
        }
    }
    
    private func updateWith(URL: String) {
        guard let broadCastView = broadcastView else {return}
        broadCastView.updateURL(with: URL)
    }
    
    private func updateVideoView(session: VTokBaseSession) {
        
        switch session.callType {
        case .onetoone, .manytomany:
            guard let groupCallingView = groupCallingView else {return}
            groupCallingView.updateAudioVideoview(for: session)
        case .onetomany:
            guard let broadcastView = broadcastView else {return}
            broadcastView.updateView(with: session)
        }
    
    }
    
    private func configureLocalView(rendrer: UIView, session: VTokBaseSession) {
        switch session.callType {
        case .onetoone, .manytomany:
            guard let groupCallingView = groupCallingView else {return}
            groupCallingView.configureLocal(view: rendrer)
            groupCallingView.session = session
        case .onetomany:
            guard let broadcastView = broadcastView else {return}
            broadcastView.setViewsForOutGoing(session: session, renderer: rendrer)
        }
    
    }
    
    private func configureView(for session: VTokBaseSession) {
        switch session.callType {
        case .onetoone, .manytomany:
            guard let groupCallingView = groupCallingView else {return}
            groupCallingView.updateView(for: session)
        case .onetomany:
            guard let broadcastView = broadcastView else {return}
            broadcastView.updateView(with: session)
            
        }
        
    
        
    }
    
    private func handleHangup(status: Bool) {
        guard let groupCallingView = groupCallingView else {return}
        groupCallingView.handleHanup(status: status)
    }
    
    private func configureRemote(streams: [UserStream], session: VTokBaseSession) {
        switch session.callType {
        case .manytomany, .onetoone:
            guard let groupCallingView = groupCallingView else {return}
            groupCallingView.updateDataSource(with: streams)
        case .onetomany:
            guard let broadcastView = self.broadcastView else {return}
            broadcastView.configureView(with: streams, and: session)
        }
       
    }
    
    deinit {

    }
}

@available(iOS 15.0, *)
extension CallingViewController {
    
    private func loadBroadcastView(session: VTokBaseSession) {
        self.session = session
        broadcastView = BroadcastView.loadView()
        guard let broadcastView = self.broadcastView else {return}
        broadcastView.updateView(with: session)
        broadcastView.delegate = self
        broadcastView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(broadcastView)
        broadcastView.fixInSuperView()
    }
    
    private func loadGroupCallingView(mediaType: SessionMediaType) {
        let view = GroupCallingView.getView()
        self.groupCallingView = view
        guard let groupCallingView = self.groupCallingView else {return}
        groupCallingView.loadViewFor(mediaType: mediaType)
        groupCallingView.users = viewModel.users
//        groupCallingView.delegate = self
        groupCallingView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(groupCallingView)
        
        NSLayoutConstraint.activate([
            groupCallingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            groupCallingView.trailingAnchor.constraint(equalTo:self.view.trailingAnchor),
            groupCallingView.topAnchor.constraint(equalTo: self.view.topAnchor),
            groupCallingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func loadIncomingCallView(session: VTokBaseSession, contact: User) {
        self.session = session
        let view = IncomingCall.loadView()
        self.incomingCallingView = view
        
        guard let incomingCallingView = self.incomingCallingView else {return}
        view.configureView(baseSession: session, user: contact)
        view.session = session
        incomingCallingView.delegate = self
        incomingCallingView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(incomingCallingView)
        
        NSLayoutConstraint.activate([
            incomingCallingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            incomingCallingView.trailingAnchor.constraint(equalTo:self.view.trailingAnchor),
            incomingCallingView.topAnchor.constraint(equalTo: self.view.topAnchor),
            incomingCallingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    
    func configureAppearance() {

    }
}

@available(iOS 15.0, *)
extension CallingViewController: IncomingCallDelegate {
    func didReject(session: VTokBaseSession) {
        viewModel.rejectCall(session: session)
    }
    
    func didAccept(session: VTokBaseSession) {
        viewModel.acceptCall(session: session)
    }
    
    
}

@available(iOS 15.0, *)
extension CallingViewController: BroadcastDelegate {

    func didTapStream(with state: StreamStatus) {
        viewModel.didTapStream(with: state)
}
    
    func didTapRoute() {
        AVAudioSession().ChangeAudioOutput(presenterViewController: self)

    }
    
   
    
    func didTapMute(for baseSession: VTokBaseSession, state: AudioState) {
        viewModel.mute(session: baseSession, state: state)
    }
    
    func didTapHangUp(for session: VTokBaseSession) {
        viewModel.hangupCall(session: session)
    }
    
    func didTapSpeaker(for session: VTokBaseSession, state: SpeakerState) {
        viewModel.speaker(session: session, state: state)
        
    }
    
    func didTapFlipCamera(for session: VTokBaseSession, type: CameraType) {
        viewModel.flipCamera(session: session, state: type)
    }
    
    func didTapVideo(for session: VTokBaseSession, type: VideoState) {
        viewModel.disableVideo(session: session, state: type)
    }


}
