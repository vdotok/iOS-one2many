//  
//  TVBroadCastViewModel.swift
//  Many-to-many-call
//
//  Created by usama farooq on 23/08/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation
import iOSSDKStreaming

typealias TVBroadCastViewModelOutput = (TVBroadCastViewModelImpl.Output) -> Void

protocol TVBroadCastViewModelInput {
    
}

protocol TVBroadCastViewModel: TVBroadCastViewModelInput {
    var output: TVBroadCastViewModelOutput? { get set}
    var userStreams: [UserStream] {get set}
    func viewModelDidLoad()
    func viewModelWillAppear()
}

class TVBroadCastViewModelImpl: TVBroadCastViewModel, TVBroadCastViewModelInput {

    private let router: TVBroadCastRouter
    var output: TVBroadCastViewModelOutput?
    var userStreams: [UserStream]  = []
    
    init(router: TVBroadCastRouter, userStreams: [UserStream]) {
        self.router = router
        self.userStreams = userStreams
    }
    
    func viewModelDidLoad() {
        
    }
    
    func viewModelWillAppear() {
        
    }
    
    //For all of your viewBindings
    enum Output {
        
    }
}

extension TVBroadCastViewModelImpl {

}
