//
//  ProgresHud.swift
//  Many-to-many-call
//
//  Created by usama farooq on 14/06/2021.
//

import Foundation
import KRProgressHUD

class ProgressHud {
    
    static func showError(message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func show(viewController: UIViewController) {
        KRProgressHUD.show()
    }
    
    static func hide() {
        KRProgressHUD.dismiss()
    }
}
