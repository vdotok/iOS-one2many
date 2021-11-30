//
//  VideoCell.swift
// one-to-many-call
//
//  Created by usama farooq on 15/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import UIKit
import iOSSDKStreaming

class VideoCell: UICollectionViewCell {
    
    @IBOutlet weak var remoteView: UIView! {
        didSet {
            remoteView.clipsToBounds = true
        }
    }
    @IBOutlet weak var remoteName: UILabel!
    @IBOutlet weak var personAvatar: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        
        for subView in remoteView.subviews {
            subView.removeFromSuperview()
        }
        remoteView.isHidden = false
        remoteName.text = nil
    }
    
    func configure(with stream: UserStream, users: [User]?) {
        
        guard let user = users, let currentUser = user.filter({$0.refID == stream.referenceID}).first else{return}
        remoteName.text = currentUser.fullName
        
        switch stream.sessionMediaType {
        case .audioCall:
            remoteView.isHidden = true
            
        case .videoCall:
            for subView in remoteView.subviews {
                subView.removeFromSuperview()
            }
            
            remoteView.addSubview(stream.renderer)
            stream.renderer.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stream.renderer.leadingAnchor.constraint(equalTo: self.remoteView.leadingAnchor),
                stream.renderer.trailingAnchor.constraint(equalTo:self.remoteView.trailingAnchor),
                stream.renderer.topAnchor.constraint(equalTo: self.remoteView.topAnchor),
                stream.renderer.bottomAnchor.constraint(equalTo: self.remoteView.bottomAnchor)
            ])
            if let stateInformation = stream.stateInformation {
                update(stateInformation: stateInformation)
            }
            
        default:
            break
        }
    
    }
    
    func update(stateInformation: StateInformation) {
        if stateInformation.videoInformation == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                self?.remoteView.isHidden = false
                self?.personAvatar.isHidden = true
            }
        }else {
            remoteView.isHidden = true
            personAvatar.isHidden = false
        }
    }

}
