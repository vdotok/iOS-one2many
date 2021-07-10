//  
//  ChannelRouter.swift
//  one-to-many-call
//
//  Created by usama farooq on 13/06/2021.
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
    func moveToCalling(sdk: VideoTalkSDK, particinats: [Participant], users: [User], screenType: ScreenType, broadcastData: BroadcastData ) {
        let builder = CallingBuilder().build(with: self.navigationController, vtokSdk: sdk, participants: particinats, screenType: screenType, contact: users, broadcastData: broadcastData)
        builder.modalPresentationStyle = .fullScreen
        navigationController?.present(builder, animated: true, completion: nil)
    }
    
    func moveToIncomingCall(sdk: VideoTalkSDK, baseSession: VTokBaseSession, users: [User], broadcastData: BroadcastData) {
        let builder = CallingBuilder().build(with: self.navigationController, vtokSdk: sdk, participants: nil, screenType: .incomingCall, session: baseSession, contact: users, broadcastData: broadcastData)
        builder.modalPresentationStyle = .fullScreen
        navigationController?.present(builder, animated: true, completion: nil)
    }
}
