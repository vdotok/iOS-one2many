//  
//  LandingViewModel.swift
//  iOS-one2many
//
//  Created by usama farooq on 09/07/2021.
//

import Foundation
import iOSSDKStreaming

typealias LandingViewModelOutput = (LandingViewModelImpl.Output) -> Void

protocol LandingViewModelInput {
    
}

protocol LandingViewModel: LandingViewModelInput {
    var output: LandingViewModelOutput? { get set}
    var broadCastData: BroadcastData {get set}
    func viewModelDidLoad()
    func viewModelWillAppear()
    func moveToChat(with broadCastData: BroadcastData)
}

class LandingViewModelImpl: LandingViewModel, LandingViewModelInput {

    private let router: LandingRouter
    var output: LandingViewModelOutput?
    var vtokSdk: VideoTalkSDK?
    var broadCastData: BroadcastData = BroadcastData(broadcastType: .publicURL,
                                                     broadcastOptions: .screenShareWithAppAudio)
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
        
    }
}

extension LandingViewModelImpl {
    func moveToChat(with broadCastData: BroadcastData) {
        guard let sdk = vtokSdk else {return}
        router.moveToChat(with: broadCastData, sdk: sdk)
    }
    
    private func configureVdotTok() {
        guard let authResponse = VDOTOKObject<AuthenticateResponse>().getData() else {return}
        guard let user = VDOTOKObject<UserResponse>().getData() else {return}
        let request = RegisterRequest(type: Constants.Request,
                                      requestType: Constants.Register,
                                      referenceID: user.refID!,
                                      authorizationToken: user.authorizationToken!,
                                      requestID: getRequestId(),
                                      tenantID: AuthenticationConstants.PROJECTID)
        self.vtokSdk = VTokSDK(url: authResponse.mediaServerMap.completeAddress, registerRequest: request, connectionDelegate: self)
        
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
