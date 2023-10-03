//  
//  LandingRouter.swift
//  iOS-one2many
//
//  Created by usama farooq on 09/07/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
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
    
    @available(iOS 15.0, *)
    func moveToIncomingCall(sdk: VideoTalkSDK, baseSession: VTokBaseSession, users: [User], broadcastData: BroadcastData?) {
        let builder = CallingBuilder().build(with: self.navigationController, vtokSdk: sdk, group: nil, screenType: .incomingCall, session: baseSession, contact: users, broadcastData: broadcastData, sessionDirection: .incoming)
        builder.modalPresentationStyle = .fullScreen
        navigationController?.present(builder, animated: true, completion: nil)
    }
    
    @available(iOS 15.0, *)
    func moveToCalling(sdk: VideoTalkSDK, group: Group? = nil, users: [User] = [], screenType: ScreenType, broadcastData: BroadcastData ) {
        let builder = CallingBuilder().build(with: self.navigationController, vtokSdk: sdk, group: group, screenType: screenType, contact: users, broadcastData: broadcastData, sessionDirection: .outgoing)
        builder.modalPresentationStyle = .fullScreen
        navigationController?.present(builder, animated: true, completion: nil)
    }
    
}
