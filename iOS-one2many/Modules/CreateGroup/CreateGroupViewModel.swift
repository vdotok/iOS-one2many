//  
//  CreateGroupViewModel.swift
//  one-to-many-call
//
//  Created by usama farooq on 14/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation

protocol CreateGroupDelegate: class {
    func didGroupCreated(group: Group)
}

typealias CreateGroupViewModelOutput = (CreateGroupViewModelImpl.Output) -> Void

protocol CreateGroupViewModelInput {
    
}

protocol CreateGroupViewModel: CreateGroupViewModelInput {
    var output: CreateGroupViewModelOutput? { get set }
    var selectedItems: [Int] {get set}
    var delegate: CreateGroupDelegate? {get set}
    var contacts: [User] {get set}
    var isSearching: Bool {get set}
    var searchContacts: [User] {get set}
    func viewModelDidLoad()
    func viewModelWillAppear()
    func reloadUsers()
    func rowsCount() -> Int
    func viewModelItem(row: Int) -> User
    func filterGroups(with text: String)
    func deleteUser(id: Int)
    func addUser(userId:Int, row: Int)
    func check(id: Int) -> Bool
    func createGroup(with title: String)
    func createGroup(with user: User)
}

class CreateGroupViewModelImpl: CreateGroupViewModel, CreateGroupViewModelInput {
    
    var contacts: [User] = []
    var isSearching: Bool = false
    private let router: CreateGroupRouter
    var delegate: CreateGroupDelegate?
    var output: CreateGroupViewModelOutput?
    var searchContacts: [User] = []
    var selectedItems = [Int]()
    var groupStorable: GroupStorable = CreateGroupService(service: NetworkService())
    private let allUserStoreAble: AllUserStoreAble = AllUsersService(service: NetworkService())
    
    init(router: CreateGroupRouter, delegate: CreateGroupDelegate) {
        self.router = router
        self.delegate = delegate
    }
    
    func viewModelDidLoad() {
        getUsers()
    }
    
    func viewModelWillAppear() {
        
    }
    
    func reloadUsers() {
        getUsers()
    }
    //For all of your viewBindings
    enum Output {
        case reload
        case showProgress
        case hideProgress
        case groupCreated(group: Group)
        case updateRow(index: Int)
        case failure(message: String)
    }
}

extension CreateGroupViewModelImpl {
    func viewModelItem(row: Int) -> User {
        return isSearching ? searchContacts[row] : contacts[row]
    }
    
    func rowsCount() -> Int {
        return isSearching ? searchContacts.count : contacts.count
    }
    
    private func getUsers() {
        let request = AllUserRequest()
        output?(.showProgress)
        allUserStoreAble.fetchUsers(with: request) { [weak self] (result) in
            guard let self = self else {return}
            self.output?(.hideProgress)
            switch result {
            case .success(let response):
                switch  response.status {
                case 503:
                    self.output?(.failure(message: response.message ))
                case 500:
                    self.output?(.failure(message: response.message))
                case 401:
                    self.output?(.failure(message: response.message))
                case 200:
                    guard let user = VDOTOKObject<UserResponse>().getData() else {return}
                    self.contacts = response.users.filter({ $0.userID != user.userID})
                    self.searchContacts = self.contacts
                    DispatchQueue.main.async {
                        self.output?(.reload)
                    }
                    
                default:
                    break
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func filterGroups(with text: String) {
        self.searchContacts = contacts.filter({$0.fullName.lowercased().prefix(text.count) == text.lowercased()})
        output?(.reload)
    }
    
    internal func deleteUser(id: Int) {
        let index = selectedItems.firstIndex(of: id)
        selectedItems.remove(at: index!)
    }
    func addUser(userId:Int, row: Int) {
        if selectedItems.contains(userId) {
           deleteUser(id: userId)
            output?(.updateRow(index: row))
        } else {
            if selectedItems.count == 4 {return}
            selectedItems.append(userId)
            output?(.updateRow(index: row))
        }
    }
    
    func check(id: Int) -> Bool {
        selectedItems.contains(id) ? false : true
    }
    
    
    func createGroup(with title: String) {
        
        let request = CreateGroupRequest(groupTitle: title, participants: selectedItems)
        output?(.showProgress)
        groupStorable.createGroup(with: request) { [weak self] (result) in
            guard let self = self else {return }
            self.output?(.hideProgress)
            switch result {
            case .success(let response):
                guard let group = response.group else {return }
                DispatchQueue.main.async {
                    self.output?(.groupCreated(group: group))
                }
            case .failure(let error):
                self.output?(.failure(message: error.localizedDescription))
                print(error)
            }
        }
    }
    
    func createGroup(with user: User) {
        return
        
    }
    
}
