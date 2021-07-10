//
//  NextButton.swift
//  Many-to-many-call
//
//  Created by usama farooq on 15/06/2021.
//

import Foundation
import UIKit

class NextButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
       
    }
    
    func setupButton() {
        layer.cornerRadius = 8
        backgroundColor = .white
        setTitleColor(.appDarkIndigoColor, for: .normal)
        titleLabel?.font = UIFont.init(name: "Manrope-Bold", size: 14)
        titleEdgeInsets = UIEdgeInsets(top: 2,left: 10,bottom:2,right: 10)
        layer.borderWidth = 3
        layer.borderColor = UIColor.appDarkIndigoColor.cgColor
        titleLabel?.adjustsFontSizeToFitWidth = true
    }
}
