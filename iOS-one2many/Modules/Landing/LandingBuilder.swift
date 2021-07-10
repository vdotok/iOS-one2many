//  
//  LandingBuilder.swift
//  iOS-one2many
//
//  Created by usama farooq on 09/07/2021.
//

import Foundation
import UIKit

class LandingBuilder {

    func build(with navigationController: UINavigationController?) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Landing", bundle: Bundle(for: LandingBuilder.self))
        let viewController = storyboard.instantiateViewController(withIdentifier: "LandingViewController") as! LandingViewController
        let coordinator = LandingRouter(navigationController: navigationController)
        let viewModel = LandingViewModelImpl(router: coordinator)

        viewController.viewModel = viewModel
        
        return viewController
    }
}


