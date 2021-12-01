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
        return true
    }

   


}
