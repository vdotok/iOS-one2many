//  
//  LandingViewController.swift
//  iOS-one2many
//
//  Created by usama farooq on 09/07/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import UIKit
import MMWormhole

public class LandingViewController: UIViewController {
    
    @IBOutlet weak var groupBroadcastButton: UIButton!
    @IBOutlet weak var publicBroadcastButton: UIButton!
    @IBOutlet weak var screenShareAppAudioBtn: BorderButton!
    @IBOutlet weak var screenShareMicAudioBtn: BorderButton!
    @IBOutlet weak var continueBtn: UIButton! {
        didSet {
            continueBtn.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var camera: BorderButton!
    @IBOutlet weak var logoutBtn: UIButton!
    
    var viewModel: LandingViewModel!
    var broadCastData: BroadcastData = BroadcastData(broadcastType: .none,
                                                     broadcastOptions: .screenShareWithAppAudio)
    let wormhole = MMWormhole(applicationGroupIdentifier: AppsGroup.APP_GROUP, optionalDirectory: Constants.Wormhole)
    
    @IBOutlet weak var blurView: UIView!
    
    let radioController: RadioButtonController = RadioButtonController()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        bindViewModel()
        viewModel.viewModelDidLoad()
        configureNavigationBar()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewModelWillAppear()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.viewModelWillDisappear()
    }
    
    
    @IBAction func didTapBroadCast(_ sender: UIButton) {
    
        switch sender.tag {
        case 100:
            // group broadcast
            radioController.buttonArrayUpdated(buttonSelected: sender)
            broadCastData.broadcastType = .group
        case 101:
            // public braodcast
            radioController.buttonArrayUpdated(buttonSelected: sender)
            broadCastData.broadcastType = .publicURL
        default:
            break
        }
        continueStatsHandling ()
    }
    
    @IBAction func didTapBroadCastOption(_ sender: UIButton) {
    
        switch sender.tag {
        case 102:
          // screen sharing with app audio
            guard !screenShareMicAudioBtn.isSelected else{return}
            screenShareAppAudioBtn.isSelected = !sender.isSelected
            broadCastData.broadcastOptions = .screenShareWithAppAudio
            
            break
        case 103:
            // screen sharing with mic
            guard !screenShareAppAudioBtn.isSelected else{return}
            screenShareMicAudioBtn.isSelected = !sender.isSelected
            break
        case 104:
        // camera
            camera.isSelected = !sender.isSelected
            break
        default:
            break
        }
        
        continueStatsHandling ()
    }
    
    private func continueStatsHandling () {
        if screenShareAppAudioBtn.isSelected == true ||
           screenShareMicAudioBtn.isSelected == true ||
           camera.isSelected == true  {
            continueBtn.backgroundColor = broadCastData.broadcastType == .none ? .appDarkGray :  .appDarkGreenColor
            continueBtn.isEnabled =  broadCastData.broadcastType == .none ? false :  true
        } else {
            continueBtn.backgroundColor = .appDarkGray
            continueBtn.isEnabled = false
        }
    }
    
    @IBAction func didTapContinue(_ sender: UIButton) {
        broadCastButtonHandling()
        switch broadCastData.broadcastType {
        case .group:
            viewModel.moveToChat(with: broadCastData)
        case .publicURL:
            if broadCastData.broadcastOptions != .videoCall {
                self.viewModel.broadCastData = broadCastData
                moveToPublicView()
            } else {
                
                self.viewModel.moveToCalling(with: broadCastData)
            }
        default:
            break
        }
        
    }
    
    @IBAction func didTapLogout(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "UserResponse")
        viewModel.logout()
        let viewController = LoginBuilder().build(with: self.navigationController)
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    private func broadCastButtonHandling() {
        
        if camera.isSelected {
            broadCastData.broadcastOptions = .videoCall
        }
        if screenShareMicAudioBtn.isSelected {
            broadCastData.broadcastOptions = .screenShareWithMicAudio
        }
         if screenShareAppAudioBtn.isSelected {
            broadCastData.broadcastOptions = .screenShareWithAppAudio
        }
         if camera.isSelected && screenShareMicAudioBtn.isSelected {
            broadCastData.broadcastOptions = .screenShareWithVideoCall
        }
         if camera.isSelected && screenShareAppAudioBtn.isSelected {
            broadCastData.broadcastOptions = .screenShareWithAppAudioAndVideoCall
        }
    }
    
    fileprivate func bindViewModel() {

        viewModel.output = { [unowned self] output in
            //handle all your bindings here
            switch output {
            case .dismissView:
                self.dismiss(animated: true, completion: nil)
            default:
                break
            }
        }
    }
    
    
    private func configureNavigationBar() {
        let navigationTitle = UILabel()
        navigationTitle.text = "Available Features"
        navigationTitle.font = UIFont(name: "Manrope-Medium", size: 20)
        navigationTitle.textColor = .appDarkGreenColor
        navigationTitle.sizeToFit()
        
        let leftItem = UIBarButtonItem(customView: navigationTitle)
        self.navigationItem.leftBarButtonItem = leftItem
    }
}

extension LandingViewController {
    func configureAppearance() {
        radioController.buttonsArray = [publicBroadcastButton,groupBroadcastButton]
        guard let data = VDOTOKObject<UserResponse>().getData() else {return}
        let title = "LOG OUT AS \(data.fullName!)"
        logoutBtn.backgroundColor = .clear
        logoutBtn.tintColor = .appDarkGray
        logoutBtn.titleLabel?.font = UIFont.init(name: "Manrope-Bold", size: 14)
        logoutBtn.setTitle(title, for: .normal)
    }
    
    private func moveToPublicView() {
        let vc = ScreenSharePopup()
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.delegate = self
        vc.broadcastData = broadCastData
        present(vc, animated: true, completion: nil)
        
    }
    
  
}

extension LandingViewController: ScreenShareDelegate {
    func didTapDismiss() {
//        blurView.isHidden = true
        self.dismiss(animated: true, completion: nil)
    }
    
}


