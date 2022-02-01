//
//  IncomingCall.swift
//  one-to-many-call
//
//  Created by usama farooq on 15/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import UIKit
import iOSSDKStreaming

protocol IncomingCallDelegate: class {
    func didReject(session: VTokBaseSession)
    func didAccept(session: VTokBaseSession)
}

class IncomingCall: UIView {
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var title: UILabel!

    weak var delegate: IncomingCallDelegate?
    var session: VTokBaseSession?
    var participants: [Participant]?
    
    func configureView(baseSession: VTokBaseSession, user: User) {
        userName.text = user.fullName
        self.session = baseSession
        switch baseSession.sessionMediaType {
        case .audioCall:
            title.text = "Incoming Group Audio Call from "
            acceptButton.setImage(UIImage(named: "Accept"), for: .normal)
            break
        case .videoCall:
            title.text = "Incoming Group Video Call from"
            
            acceptButton.setImage(UIImage(named: "StopVideo"), for: .normal)
        default:
            break
        }
    }
    
    @IBAction func didTapAccept(_ sender: UIButton) {
        guard let sessionRequest = session else {return}
        delegate?.didAccept(session: sessionRequest)
    }
    
    @IBAction func didTapReject(_ sender: UIButton) {
        guard let sessionRequest = session else {return}
        delegate?.didReject(session: sessionRequest)
    }
    
    static func loadView() -> IncomingCall {
        let viewsArray = Bundle.main.loadNibNamed("IncomingCall", owner: self, options: nil) as AnyObject as? NSArray
            guard (viewsArray?.count)! < 0 else{
                let view = viewsArray?.firstObject as! IncomingCall
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }
        return IncomingCall()
    }
}
