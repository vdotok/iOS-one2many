//  
//  ChannelBuilder.swift
//  one-to-many-call
//
//  Created by usama farooq on 13/06/2021.
//

import Foundation
import UIKit
import iOSSDKStreaming

class ChannelBuilder {

    func build(with navigationController: UINavigationController?, broadcastData: BroadcastData, sdk: VideoTalkSDK) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Channel", bundle: Bundle(for: ChannelBuilder.self))
        let viewController = storyboard.instantiateViewController(withIdentifier: "ChannelViewController") as! ChannelViewController
        let coordinator = ChannelRouter(navigationController: navigationController)
        let viewModel = ChannelViewModelImpl(router: coordinator, broadcastData: broadcastData, sdk: sdk)

        viewController.viewModel = viewModel
        
        return viewController
    }
}


