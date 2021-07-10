//  
//  SignUpViewModel.swift
//  Many-to-many-call
//
//  Created by usama farooq on 13/06/2021.
//

import Foundation

typealias SignUpViewModelOutput = (SignUpViewModelImpl.Output) -> Void

protocol SignUpViewModelInput {
    
}

protocol SignUpViewModel: SignUpViewModelInput {
    var output: SignUpViewModelOutput? { get set}
    
    func viewModelDidLoad()
    func viewModelWillAppear()
    func registerUser(with userName: String, _ password: String, _ email: String)
}

class SignUpViewModelImpl: SignUpViewModel, SignUpViewModelInput {

    private let router: SignUpRouter
    var output: SignUpViewModelOutput?
    var checkUserStore: CheckUserNameStorable
    var signupStore: SignupStoreable
    init(router: SignUpRouter, checkUserStore: CheckUserNameStorable = ValidateUserNameService(service: NetworkService()), signupStore: SignupStoreable = SignupService(service: NetworkService())) {
        self.router = router
        self.checkUserStore = checkUserStore
        self.signupStore = signupStore
    }
    
    func viewModelDidLoad() {
        
    }
    
    func viewModelWillAppear() {
        
    }
    
    //For all of your viewBindings
    enum Output {
        case showProgress
        case hideProgress
        case success
        case userExist
        case failure(message: String)
    }
}

extension SignUpViewModelImpl {
    func validate(user name: String) {
        
        //length of Username should be in between 4 and 20
        guard Reachability.isConnectedToNetwork() else {
            output?(.failure(message: "Internet appears to be offline"))
            return
        }
        guard name.count >= 8 else {
            output?(.failure(message: "length of Username should be in between 8 and 20"))
            return
        }
        guard let output = output else {return }
        let request = ValidateUserNameRequest(email: name)
        output(.showProgress)
        checkUserStore.check(user: request) { [weak self] (response) in
            output(.hideProgress)
            guard let self = self else { return }
            switch response {
            case .success(let response):
                switch response.status {
                case 200:
                    output(.userExist)
                case 400:
                    output(.failure(message: response.message))
                case 407:
                    output(.failure(message: response.message))
                case 409:
                    output(.failure(message: response.message))
                case 503:
                    self.output?(.failure(message: response.message))
                case 500:
                    self.output?(.failure(message: response.message))
                default:
                    break
                }
                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func registerUser(with userName: String, _ password: String, _ email: String) {
        let name =  userName.trimmingCharacters(in: .whitespaces)
         guard Reachability.isConnectedToNetwork() else {
             output?(.failure(message: "Internet appears to be offline"))
             return
         }
        if userName.count > 20 || userName.count < 4 {
            output?(.failure(message: "Username should be between 4 and 20."))
            return
        }
        if password.count > 14 || password.count < 8 {
            output?(.failure(message: "Password should be between 8 and 14."))
            return
        }
        self.output?(.showProgress)
        let request = SignupRequest(fullName: name, email: email, password: password)
        signupStore.registerUser(with: request) { (response) in
            self.output?(.hideProgress)
            switch response {
            case .success(let response):
                switch response.status {
                case 503:
                    self.output?(.failure(message: response.message ?? "Service Unavailable"))
                case 500:
                    self.output?(.failure(message: response.message ?? "Internal Server Error server error"))
                case 409:
                    self.output?(.failure(message: response.message ?? "Username already taken. Please choose another username"))
                case 407:
                    self.output?(.failure(message: response.message ?? ""))
                case 200:
                    self.output?(.success)
                default:
                    break
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
