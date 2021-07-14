//  
//  LandingRouter.swift
//  iOS-one2many
//
//  Created by usama farooq on 09/07/2021.
//

import Foundation
import UIKit
import iOSSDKStreaming

class LandingRouter {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

extension LandingRouter {
    func moveToChat(with broadCastData: BroadcastData, sdk: VideoTalkSDK){
        let builder = ChannelBuilder().build(with: navigationController, broadcastData: broadCastData, sdk: sdk)
        self.navigationController?.pushViewController(builder, animated: true)
    }
    
    func moveToIncomingCall(sdk: VideoTalkSDK, baseSession: VTokBaseSession, users: [User], broadcastData: BroadcastData?) {
        let builder = CallingBuilder().build(with: self.navigationController, vtokSdk: sdk, participants: nil, screenType: .incomingCall, session: baseSession, contact: users, broadcastData: broadcastData)
        builder.modalPresentationStyle = .fullScreen
        navigationController?.present(builder, animated: true, completion: nil)
    }
    
    func moveToCalling(sdk: VideoTalkSDK, particinats: [Participant] = [], users: [User] = [], screenType: ScreenType, broadcastData: BroadcastData ) {
        let builder = CallingBuilder().build(with: self.navigationController, vtokSdk: sdk, participants: particinats, screenType: screenType, contact: users, broadcastData: broadcastData)
        builder.modalPresentationStyle = .fullScreen
        navigationController?.present(builder, animated: true, completion: nil)
    }
    
}
