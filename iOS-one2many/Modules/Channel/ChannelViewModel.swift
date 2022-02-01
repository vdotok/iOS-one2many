//  
//  ChannelViewModel.swift
//  one-to-many-call
//
//  Created by usama farooq on 13/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation
import iOSSDKStreaming
import MMWormhole


typealias ChannelViewModelOutput = (ChannelViewModelImpl.Output) -> Void

struct TempGroup {
    let group: Group
    let unReadMessageCount: Int
    let lastMessage: String
    let presentParticipant: Int
    let broadCastData: BroadcastData
}

protocol ChannelViewModelInput {
    var output: ChannelViewModelOutput? { get set}
    var groups: [Group] {get set}
    var searchGroup: [Group] {get set}
    var isSearching: Bool {get set}
    var selectedGroup: Group? {get set}
    var broadCastData: BroadcastData {get set}
  
   
    var presentCandidates: [String: [String]] {get set}

    func viewModelDidLoad()
    func viewModelWillAppear()
    func fetchGroups()
    func itemAt(row: Int) -> TempGroup
    func moveToVideo(users: [Participant])
    func moveToAudio(users: [Participant])
    func deleteGroup(with id: Int)
    func editGroup(with title: String, id: Int)
    func groupSelection(group: Group, row: Int)
    func check(id: Int) -> Bool
    func logout()
}

protocol ChannelViewModel: ChannelViewModelInput {
    var output: ChannelViewModelOutput? { get set}
    
    func viewModelDidLoad()
    func viewModelWillAppear()
    func viewModelWillDisappear()
}

class ChannelViewModelImpl: ChannelViewModel, ChannelViewModelInput {

    var groups: [Group] = []
    var searchGroup: [Group] = []
    var isSearching: Bool = false
    var store: AllGroupStroreable
    var vtokSdk: VideoTalkSDK
    var presentCandidates: [String : [String]] = [:]
    var contacts: [User] = []
    var deleteStore: DeleteStoreable = DeleteService(service: NetworkService())
    var editStore: EditGroupStoreable = EditGroupService(service: NetworkService())
    var selectedItems = [Int]()
    var broadCastData: BroadcastData
    var selectedGroup: Group?
    let wormhole = MMWormhole(applicationGroupIdentifier: AppsGroup.APP_GROUP, optionalDirectory: "wormhole")
    
    private let allUserStoreAble: AllUserStoreAble = AllUsersService(service: NetworkService())
    
    private let router: ChannelRouter
    var output: ChannelViewModelOutput?
    
    init(router: ChannelRouter, store:AllGroupStroreable = AllGroupService(service: NetworkService()), broadcastData: BroadcastData, sdk: VideoTalkSDK) {
        self.router = router
        self.store = store
        self.broadCastData = broadcastData
        self.vtokSdk = sdk
    }
    
    func viewModelDidLoad() {
        fetchGroups()
        
    }
    
    func viewModelWillAppear() {
        registerForCommand()
    }
    
    func viewModelWillDisappear() {
        unRegisterForCommand()
    }
    
    //For all of your viewBindings
    enum Output {
        case reload
        case showProgress
        case hideProgress
        case connected
        case disconnected
        case update(row: Int)
        case failure(message: String)
    }
    
}

extension ChannelViewModelImpl {
    
    func moveToVideo(users: [Participant]) {
        
        router.moveToCalling(sdk: vtokSdk, particinats: users, users: contacts, screenType: .videoView, broadcastData: broadCastData)
    }
    
    func moveToAudio(users: [Participant]) {
        
        router.moveToCalling(sdk: vtokSdk, particinats: users, users: contacts, screenType: .audioView, broadcastData: broadCastData)
    }
    
    
    func fetchGroups() {
        let request = AllGroupRequest()
        self.output?(.showProgress)
        store.fetchGroups(with: request) { [weak self] (response) in
            guard let self = self else {return}
            self.output?(.hideProgress)
            switch response {
            case .success(let response):
                switch response.status {
                case 503:
                    self.output?(.failure(message: response.message ))
                case 500:
                    self.output?(.failure(message: response.message))
                case 401:
                    self.output?(.failure(message: response.message))
                case 200:
                    self.groups = response.groups ?? []
                    DispatchQueue.main.async {
                        self.output?(.reload)
                    }
                    self.fetchUsers()
                    
                default:
                    break
                }
            case .failure(let error):
                print(error)
            }
        }
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

    func itemAt(row: Int) -> TempGroup {
        let channel = groups[row].channelName
        let present = presentCandidates[channel]
        let group = TempGroup(group: groups[row], unReadMessageCount: 0, lastMessage: "", presentParticipant: present?.count ?? 0, broadCastData: self.broadCastData)
        
        return group
    }
    
    func logout() {
        self.vtokSdk.closeConnection()
    }
    
    func deleteGroup(with id: Int) {
        output?(.showProgress)
        let request = DeleteGroupRequest(group_id: groups[id].id)
        deleteStore.delete(with: request) { [weak self] response in
            self?.output?(.hideProgress)
            switch response {
            case .success(let response):
                DispatchQueue.main.async {
                    switch response.status {
                    case 503:
                        self?.output?(.failure(message: response.message ))
                    case 500:
                        self?.output?(.failure(message: response.message))
                    case 401:
                        self?.output?(.failure(message: response.message))
                    case 600:
                        self?.output?(.failure(message: response.message))
                    case 200:
                        
                    self?.groups.remove(at: id)
                    self?.output?(.reload)
                    default:
                    break
                    }
                }
                
                print("\(response)")
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func editGroup(with title: String, id: Int) {
        guard  groups[id].participants.count != 1 else {
            output?(.failure(message: "one to one group name cannot be updated"))
            return
        }
        output?(.showProgress)
        let request = EditGroupRequest(group_title: title, group_id: groups[id].id)
        editStore.editGroup(with: request) { [weak self] result in
            self?.output?(.hideProgress)
            switch result {
            case .success(_):
                self?.groups[id].groupTitle = title
                DispatchQueue.main.async {
                    self?.output?(.reload)
                }
               
            case .failure(let error):
                print(error)
                
            }
        }
    }
    
    func check(id: Int) -> Bool {
        guard let group = selectedGroup else {return true}
        return group.id == id ? false : true
    }
    
    func groupSelection(group: Group, row: Int) {
        selectedGroup = group
        output?(.reload)
    }
}

extension ChannelViewModelImpl: SDKConnectionDelegate {
    
    func didGenerate(output: SDKOutPut) {
        switch output {
        case .disconnected(_):
            self.output?(.disconnected)
        case .registered:
            self.output?(.connected)
        case .sessionRequest(let sessionRequest):
            
            router.moveToIncomingCall(sdk: vtokSdk, baseSession: sessionRequest, users: self.contacts, broadcastData: broadCastData)
        }
    }
    
}


extension ChannelViewModelImpl {
    
    func unRegisterForCommand(){
        wormhole.stopListeningForMessage(withIdentifier: "Command")
    }
    
    
    func registerForCommand() {
        
        wormhole.listenForMessage(withIdentifier: "Command", listener: { [weak self] (messageObject) -> Void in
            if let message = messageObject as? String, message == "StartScreenSharing"  {
                self?.startSessions()
            }
        })
    }
    
    func makeCall() -> String {
        return ""
    }
         
    
    func startSessions() {
        guard let myUser = VDOTOKObject<UserResponse>().getData(), let refID = myUser.refID else {return}
        guard let users = selectedGroup?.participants.filter({$0.refID != refID}) else {return}
        router.moveToCalling(sdk: vtokSdk, particinats: users, users: contacts, screenType: .videoAndScreenShare, broadcastData: broadCastData)
        
    }

}
