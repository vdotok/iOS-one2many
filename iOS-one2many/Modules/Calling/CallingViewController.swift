//  
//  CallingViewController.swift
//  one-to-many-call
//
//  Created by usama farooq on 15/06/2021.
//

import UIKit
import iOSSDKStreaming

public class CallingViewController: UIViewController {

    var viewModel: CallingViewModel!
    var groupCallingView: GroupCallingView?
    var incomingCallingView: IncomingCall?
    var broadcastView: BroadcastView?
    var counter = 0
    var timer = Timer()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        bindViewModel()
        viewModel.viewModelDidLoad()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewModelWillAppear()
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
}

extension CallingViewController {
    
    private func loadBroadcastView(session: VTokBaseSession) {
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

extension CallingViewController: IncomingCallDelegate {
    func didReject(session: VTokBaseSession) {
        viewModel.rejectCall(session: session)
    }
    
    func didAccept(session: VTokBaseSession) {
        viewModel.acceptCall(session: session)
    }
    
    
}

extension CallingViewController: BroadcastDelegate {
    func didTapStream(with state: StreamStatus) {
        viewModel.didTapStream(with: state)
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


