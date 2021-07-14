//
//  ScreenSharePopup.swift
//  iOS-one2many
//
//  Created by usama farooq on 13/07/2021.
//

import UIKit
import ReplayKit
import VisualEffectView

protocol ScreenShareDelegate: AnyObject {
    func didTapDismiss()
}

class ScreenSharePopup: UIViewController {

    @IBOutlet weak var ssButton: UIButton! {
        didSet {
            ssButton.layer.cornerRadius = 20
            ssButton.clipsToBounds = true
        }
    }
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var popupView: UIView! {
        didSet {
            popupView.layer.cornerRadius = 20
        }
    }
    weak var delegate: ScreenShareDelegate?
    var broadcastData: BroadcastData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBlureView()
        addRPViewToSSButton()
        
    }
    
    @IBAction func didTapCross(_ sender: UIButton) {
        delegate?.didTapDismiss()
    }
    
    @IBAction func didTapScreenShare(_ sender: UIButton) {
//        delegate?.didTapDismiss()
    }
    
    func addBlureView() {
        let visualEffectView = VisualEffectView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

        // Configure the view with tint color, blur radius, etc
        visualEffectView.colorTint = .black
        visualEffectView.colorTintAlpha = 0.2
        visualEffectView.blurRadius = 10
        visualEffectView.scale = 1

        blurView.addSubview(visualEffectView)
    }
    
    
}

extension ScreenSharePopup {
    func addRPViewToSSButton() {
        
        let recordingView = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        recordingView.preferredExtension = AppsGroup.SCREEN_SHARE_PREFERED_EXTENSION
        guard let options = broadcastData else {return}
        
        switch options.broadcastOptions {
        case .screenShareWithMicAudio:
            recordingView.showsMicrophoneButton = true
        default:
            recordingView.showsMicrophoneButton = false
        }
        recordingView.tintColor = .white
        
        for subView in recordingView.subviews {
            if subView is UIButton, let button = subView as? UIButton{
                if let _ = UIImage(named: ""){
                    button.setImage(nil, for: .normal)
                }
            }
        }
        ssButton.addSubview(recordingView)

    }
}
