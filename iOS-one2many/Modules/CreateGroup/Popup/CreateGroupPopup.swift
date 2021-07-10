//
//  CreateGroupPopup.swift
//  one-to-many-call
//
//  Created by usama farooq on 15/06/2021.
//

import UIKit

protocol PopupDelegate: class {
    func didTapDismiss(groupName: String?)
}

class CreateGroupPopup: UIViewController {

    @IBOutlet weak var tapView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var textFieldTitle: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    
    weak var delegate: PopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss(_:)))
        // Do any additional setup after loading the view.
        tapView.addGestureRecognizer(tapToDismiss)
        configureAppearance()
    }

     @objc func tapToDismiss(_ recognizer: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
        delegate?.didTapDismiss(groupName: nil)
       
    }
    
    @IBAction func didTapCross(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        delegate?.didTapDismiss(groupName: nil)
    }
    
    @IBAction func didTapConfirm(_ sender: UIButton) {
        guard let groupName = titleTextField.text  else { return }
        guard groupName.count > 3 else {
            ProgressHud.showError(message: "group name should be greater than 3", viewController: self)
            return
        }
        self.dismiss(animated: true, completion: nil)
        delegate?.didTapDismiss(groupName: groupName)
    }
    
    private func configureAppearance() {
        containerView.layer.cornerRadius = 8
        mainTitle.font = UIFont(name: "Poppins-SemiBold", size: 14)
        mainTitle.textColor = .appGreyColor
        textFieldTitle.font = UIFont(name: "Inter-Regular", size: 14)
        textFieldTitle.textColor = .appDarkColor
        
    }

}

