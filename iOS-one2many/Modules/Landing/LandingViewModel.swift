//  
//  LandingViewModel.swift
//  iOS-one2many
//
//  Created by usama farooq on 09/07/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation
import iOSSDKStreaming
import MMWormhole
typealias LandingViewModelOutput = (LandingViewModelImpl.Output) -> Void

protocol LandingViewModelInput {
    
}

protocol LandingViewModel: LandingViewModelInput {
    var output: LandingViewModelOutput? { get set}
    var broadCastData: BroadcastData {get set}
    func viewModelDidLoad()
    func viewModelWillAppear()
    func viewModelWillDisappear()
    func logout()
    
    func moveToChat(with broadCastData: BroadcastData)
    func moveToCalling(with broadcastData: BroadcastData)
}

class LandingViewModelImpl: LandingViewModel, LandingViewModelInput {

    private let router: LandingRouter
    var output: LandingViewModelOutput?
    var vtokSdk: VideoTalkSDK?
    var broadCastData: BroadcastData = BroadcastData(broadcastType: .publicURL,
                                                     broadcastOptions: .screenShareWithAppAudio)
    let wormhole = MMWormhole(applicationGroupIdentifier: AppsGroup.APP_GROUP, optionalDirectory: Constants.Wormhole)
    var contacts: [User] = []
    private let allUserStoreAble: AllUserStoreAble = AllUsersService(service: NetworkService())
    
    init(router: LandingRouter) {
        self.router = router
    }
    
    func viewModelDidLoad() {
        configureVdotTok()
        fetchUsers()
        
    }
    
    func viewModelWillAppear() {
        registerForCommand()
    }
    
    func viewModelWillDisappear() {
        unRegisterForCommand()
    }
    func logout() {
        vtokSdk?.closeConnection()
    }
    
    func fetchUsers() {
        let request = AllUserRequest()
        allUserStoreAble.fetchUsers(with: request) { [weak self] (response) in
            guard let self = self else {return}
            switch response {
            case .success(let response):
                self.contacts = response.users
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //For all of your viewBindings
    enum Output {
        case connected
        case disconnected
        case dismissView
        
    }
}

extension LandingViewModelImpl {
    func moveToChat(with broadCastData: BroadcastData) {
        guard let sdk = vtokSdk else {return}
        router.moveToChat(with: broadCastData, sdk: sdk)
    }
    
    private func configureVdotTok() {
        guard let user = VDOTOKObject<UserResponse>().getData(),
              let url = user.mediaServerMap?.completeAddress
        else {return}
        let request = RegisterRequest(type: Constants.Request,
                                      requestType: Constants.Register,
                                      referenceId: user.refID!,
                                      authorizationToken: user.authorizationToken!,
                                      requestId: getRequestId(),
                                      projectId: AuthenticationConstants.PROJECTID)
        self.vtokSdk = VTokSDK(url: url, registerRequest: request, connectionDelegate: self)
        VdotokShare.shared.setSdk(sdk: self.vtokSdk!)
        
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
}

extension LandingViewModelImpl: SDKConnectionDelegate {
    func didGenerate(output: SDKOutPut) {
        switch output {
        case .disconnected(_):
            self.output?(.disconnected)
        case .registered:
            self.output?(.connected)
        case .sessionRequest(let sessionRequest):
            guard let sdk = vtokSdk else {return}
            router.moveToIncomingCall(sdk: sdk, baseSession: sessionRequest, users: self.contacts, broadcastData: broadCastData)
        }
    }

}

extension LandingViewModelImpl {
    
    func unRegisterForCommand(){
        wormhole.stopListeningForMessage(withIdentifier: WormHoleConstants.command)
    }
    
    func registerForCommand() {
        
        wormhole.listenForMessage(withIdentifier: WormHoleConstants.command, listener: { [weak self] (messageObject) -> Void in
            
            if let message = messageObject as? String, message == WormHoleConstants.startScreenSharing  {
                self?.output?(.dismissView)
                
                guard let sdk = self?.vtokSdk, let broadcastData = self?.broadCastData else {return }
                self?.router.moveToCalling(sdk: sdk, screenType: .videoAndScreenShare, broadcastData: broadcastData)
                print("screen share start")
            }
        })
    }
    
    func moveToCalling(with broadcastData: BroadcastData) {
        guard let sdk = self.vtokSdk else {return }
        self.router.moveToCalling(sdk: sdk, screenType: .videoAndScreenShare, broadcastData: broadcastData)
    }
}
