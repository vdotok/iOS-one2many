//
//  SceneDelegate.swift
//  Many-to-many-call
//
//  Created by usama farooq on 13/06/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let navigationController = UINavigationController()
    var sceneBackgroudTime: TimeInterval? = nil
    var sceneActiveTime: TimeInterval? = nil

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        window?.makeKeyAndVisible()
        window?.overrideUserInterfaceStyle = .light
        
        guard let _ =  VDOTOKObject<UserResponse>().getData() else  {
            let viewController = LoginBuilder().build(with: self.navigationController)
            viewController.modalPresentationStyle = .fullScreen
            self.window?.rootViewController = viewController
            return
        }
        let navigationControlr = UINavigationController()
        navigationControlr.modalPresentationStyle = .fullScreen
        let viewController = LandingBuilder().build(with: navigationControlr)
        
        //ControlsViewBuilder().build(with: navigationControlr)
        viewController.modalPresentationStyle = .fullScreen
        navigationControlr.setViewControllers([viewController], animated: true)
        self.window?.rootViewController = navigationControlr
    
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        sceneActiveTime = Date().timeIntervalSince1970
        guard let newTime = sceneActiveTime, let oldTime = sceneBackgroudTime else {return}
        let interval = newTime - oldTime
        NotificationCenter.default.post(name: Notification.Name("sceneActive"), object: self, userInfo: ["interval": interval])
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        sceneBackgroudTime = Date().timeIntervalSince1970
    }

}

