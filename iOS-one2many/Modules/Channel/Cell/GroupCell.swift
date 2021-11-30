//
//  GroupCell.swift
//  one-to-many-call
//
//  Created by usama farooq on 14/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import UIKit
import iOSSDKStreaming
import ReplayKit

protocol GroupCallDelegate: AnyObject {
    func didTapScreen(group: Group, broadcastData: BroadcastData)
    func didTapVideo(participants: [Participant])
}

class GroupCell: UITableViewCell {
    
    @IBOutlet weak var groupTitle: UILabel!
    @IBOutlet weak var ssButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var selectedView: UIView! {
        didSet {
            selectedView.layer.cornerRadius = 20/2
        }
    }
    weak var delegate: GroupCallDelegate?
    var group: Group?
    var broadcastData: BroadcastData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func didTapAudio(_ sender: UIButton) {
        guard let group = group, let data = broadcastData else {return}
        delegate?.didTapScreen(group: group, broadcastData: data)
    }
    
    @IBAction func didTapVideo(_ sender: UIButton) {
        guard let group = group else {return}
        delegate?.didTapVideo(participants: group.participants)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with group: Group, broadcastData: BroadcastData , delegate: GroupCallDelegate, isSelected: Bool) {
        self.broadcastData = broadcastData
        selectedView.isHidden = isSelected
            ssButton.isEnabled = isSelected ? false : true
            videoButton.isEnabled = isSelected ? false : true
        self.group = group
        groupTitle.text = group.groupTitle
        self.delegate = delegate
        
        switch broadcastData.broadcastOptions {
        case .videoCall:
            videoButton.isHidden = false
              break
        default:
            ssButton.isHidden = false
            addRPViewToSSButton()
            break
        }
    }
    
    
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
                if let image = UIImage(named: "EndScreenShare"){
                    button.setImage(nil, for: .normal)
                }
            }
        }
        ssButton.addSubview(recordingView)

    }
    
}


