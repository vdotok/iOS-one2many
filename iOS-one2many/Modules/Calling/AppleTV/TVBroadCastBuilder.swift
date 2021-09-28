//  
//  TVBroadCastBuilder.swift
//  Many-to-many-call
//
//  Created by usama farooq on 23/08/2021.
//

import Foundation
import UIKit
import iOSSDKStreaming

class TVBroadCastBuilder {

    func build(with navigationController: UINavigationController?, userStreams: [UserStream]) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "TVBroadCast", bundle: Bundle(for: TVBroadCastBuilder.self))
        let viewController = storyboard.instantiateViewController(withIdentifier: "TVBroadCastViewController") as! TVBroadCastViewController
        let coordinator = TVBroadCastRouter(navigationController: navigationController)
        let viewModel = TVBroadCastViewModelImpl(router: coordinator, userStreams: userStreams)

        viewController.viewModel = viewModel
        
        return viewController
    }
}


