//  
//  LoginViewController.swift
//  Many-to-many-call
//
//  Created by usama farooq on 13/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import UIKit

public class LoginViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var singupButton: UIButton!
    
    var viewModel: LoginViewModel!
    let navigationController2 = UINavigationController()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        bindViewModel()
        viewModel.viewModelDidLoad()
    }
    
    @IBAction func didTapScanner(_ sender: Any) {
        let builder = QRScannerBuilder().build(with: UINavigationController())
        builder.modalPresentationStyle = .fullScreen
        builder.modalTransitionStyle = .crossDissolve
        self.present(builder, animated: true, completion: nil)
    }
    
    @IBAction func didTapLogin(_ sender: UIButton) {
        guard let userName = email.text, let password = password.text else {return }
        if (AuthenticationConstants.PROJECTID.isEmpty && AuthenticationConstants.TENANTSERVER.isEmpty) {
                 ProgressHud.showError(message: "kindly scan the qr code", viewController: self)
             }else{
                 viewModel.loginUser(with: userName, password)
             }
    }
    
    @IBAction func didTapRegister(_ sender: UIButton) {
        let builder = SignUpBuilder().build(with: UINavigationController())
        builder.modalPresentationStyle = .fullScreen
        builder.modalTransitionStyle = .crossDissolve
        self.present(builder, animated: true, completion: nil)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewModelWillAppear()
    }
    
    fileprivate func bindViewModel() {
        
        viewModel.output = { [unowned self] output in
            //handle all your bindings here
            switch output {
            case .showProgress:
                ProgressHud.show(viewController: self)
            case .hideProgress:
                ProgressHud.hide()
            case .failure(let message):
                DispatchQueue.main.async {
                    ProgressHud.showError(message: message, viewController: self)
                }
               
            case .success:
                DispatchQueue.main.async {
                    let navigationControlr = UINavigationController()
                    navigationControlr.modalPresentationStyle = .fullScreen
                    let viewController = LandingBuilder().build(with: navigationControlr)
                    viewController.modalPresentationStyle = .fullScreen
                    navigationControlr.setViewControllers([viewController], animated: true)
                    present(navigationControlr, animated: true, completion: nil)
                }
            default:
                break
            }
        }
    }
}

extension LoginViewController {
    func configureAppearance() {
        containerView.layer.cornerRadius = 20
//        self.navigationController?.navigationBar.isHidden = true
        singupButton.setTitleColor(UIColor(named: "AppIndigoColor"), for: .normal)
        password.delegate = self
    }
}

extension LoginViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && string == " " {
            return false
        }
        var text = textField.text!
        if string != "" {
            text += string
        }
        if textField == password {
            if text.count > 14 {
                return false
            }
        }
        return true
    }
}


