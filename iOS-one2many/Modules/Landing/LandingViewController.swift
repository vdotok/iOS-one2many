//  
//  LandingViewController.swift
//  iOS-one2many
//
//  Created by usama farooq on 09/07/2021.
//

import UIKit

public class LandingViewController: UIViewController {
    
    @IBOutlet weak var groupBroadcastButton: UIButton!
    @IBOutlet weak var publicBroadcastButton: UIButton!
    @IBOutlet weak var screenShareAppAudioBtn: BorderButton!
    @IBOutlet weak var screenShareMicAudioBtn: BorderButton!
    @IBOutlet weak var camera: BorderButton!
    var viewModel: LandingViewModel!
    var broadCastData: BroadcastData = BroadcastData(broadcastType: .publicURL,
                                                     broadcastOptions: .screenShareWithAppAudio)
    
    let radioController: RadioButtonController = RadioButtonController()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        bindViewModel()
        viewModel.viewModelDidLoad()
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
            broadCastData.broadcastType = .group
        default:
            break
        }
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
    }
    
    @IBAction func didTapContinue(_ sender: UIButton) {
        broadCastButtonHandling()
        viewModel.moveToChat(with: broadCastData)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewModelWillAppear()
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
            default:
                break
            }
        }
    }
}

extension LandingViewController {
    func configureAppearance() {
        radioController.buttonsArray = [publicBroadcastButton,groupBroadcastButton]
        radioController.defaultButton = publicBroadcastButton
    }
}
