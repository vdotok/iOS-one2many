//  
//  ChannelRouter.swift
//  one-to-many-call
//
//  Created by usama farooq on 13/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation
import UIKit
import iOSSDKStreaming
class ChannelRouter {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

extension ChannelRouter {
    func moveToCalling(sdk: VideoTalkSDK, group: Group, users: [User], screenType: ScreenType, broadcastData: BroadcastData) {
        let builder = CallingBuilder().build(with: self.navigationController, vtokSdk: sdk,group: group, screenType: screenType, contact: users, broadcastData: broadcastData, sessionDirection: .outgoing)
        builder.modalPresentationStyle = .fullScreen
        navigationController?.present(builder, animated: true, completion: nil)
    }
    
    func moveToIncomingCall(sdk: VideoTalkSDK, baseSession: VTokBaseSession, users: [User], broadcastData: BroadcastData) {
        let builder = CallingBuilder().build(with: self.navigationController, vtokSdk: sdk, group: nil, screenType: .incomingCall, session: baseSession, contact: users, broadcastData: broadcastData, sessionDirection: .incoming)
        builder.modalPresentationStyle = .fullScreen
        navigationController?.present(builder, animated: true, completion: nil)
    }
}
