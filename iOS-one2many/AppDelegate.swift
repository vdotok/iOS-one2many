//
//  AppDelegate.swift
//  Many-to-many-call
//
//  Created by usama farooq on 13/06/2021.
//

import UIKit
import IQKeyboardManagerSwift
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let navigationController = UINavigationController()
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        window?.makeKeyAndVisible()
        window?.overrideUserInterfaceStyle = .light
     
        guard let _ =  VDOTOKObject<UserResponse>().getData() else  {
            let viewController = LoginBuilder().build(with: self.navigationController)
            viewController.modalPresentationStyle = .fullScreen
            self.window?.rootViewController = viewController
            return true
        }
        let navigationControlr = UINavigationController()
        navigationControlr.modalPresentationStyle = .fullScreen
        let viewController = LandingBuilder().build(with: navigationControlr)
        
        //ControlsViewBuilder().build(with: navigationControlr)
        viewController.modalPresentationStyle = .fullScreen
        navigationControlr.setViewControllers([viewController], animated: true)
        self.window?.rootViewController = navigationControlr
        
        setUpAudioSession()
        return true
    }

   


}


extension AppDelegate{
    
    private func setUpAudioSession() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .longFormAudio)
        } catch {
            print("Failed to set audio session route sharing policy: \(error)")
        }
        
//        let requestedCodecs = [
//            AudioClassDescription(mType: kAudioEncoderComponentType, mSubType: kAudioFormatMPEG4AAC, mManufacturer: kAppleHardwareAudioCodecManufacturer),
//            AudioClassDescription(mType: kAudioDecoderComponentType, mSubType: kAudioFormatMPEG4AAC, mManufacturer: kAppleHardwareAudioCodecManufacturer)
//        ]
//
//        let req = UnsafeMutablePointer<AudioClassDescription>.allocate(capacity: 2)
//        req[0].mType = kAudioEncoderComponentType
//        req[0].mSubType = kAudioFormatMPEG4AAC
//        req[0].mManufacturer = kAppleSoftwareAudioCodecManufacturer
//        req[1].mType = kAudioDecoderComponentType
//        req[1].mSubType = kAudioFormatMPEG4AAC
//        req[1].mManufacturer = kAppleSoftwareAudioCodecManufacturer
//
//        print(MemoryLayout.size(ofValue: req))
//
//        var successfulCodecs:UInt32 = 0
//        var len:UInt32 = UInt32(MemoryLayout.size(ofValue: successfulCodecs))
//        let result = AudioFormatGetProperty(kAudioFormatProperty_HardwareCodecCapabilities, 24, requestedCodecs, &len, &successfulCodecs)
//        if result == noErr {
//            print("SUCODE:", successfulCodecs)
//        } else if result == kAudioFormatUnsupportedPropertyError {
//            print("NOT SUPPORTED PROPERTY")
//        }
/*
        switch successfulCodecs {
            case 0:
            
                // aac hardware encoder is unavailable. aac hardware decoder availability
                // is unknown; could ask again for only aac hardware decoding
            
            case 1:
                // aac hardware encoder is available but, while using it, no hardware
                // decoder is available.
            case 2:
                // hardware encoder and decoder are available simultaneously
        }*/

    }
    
}
