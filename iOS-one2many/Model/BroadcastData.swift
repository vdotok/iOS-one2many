//
//  BroadcastData.swift
//  iOS-one2many
//
//  Created by usama farooq on 09/07/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation
import iOSSDKStreaming

struct BroadcastData:Codable {
    var broadcastType: BroadcastType
    var broadcastOptions: BroadcastOptions
    var broadcastGroupID: String?
    
}

struct ScreenShareAudioState: Codable {
    let screenShareAudio: ScreenShareBytes
}

struct ScreenShareScreenState: Codable {
    let screenShareScreen: ScreenShareBytes
}
