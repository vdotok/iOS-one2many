//
//  BorderButton.swift
//  iOS-one2many
//
//  Created by usama farooq on 09/07/2021.
//

import Foundation
import UIKit

class BorderButton: UIButton {
    
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected == true {
                layer.backgroundColor = UIColor.appYellowColor.cgColor
            } else {
                layer.backgroundColor = UIColor.white.cgColor
            }
        }
    }
   
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
    
  private func setupButton() {
        layer.cornerRadius = 8
        layer.borderWidth = 2
        layer.borderColor = UIColor.appBlueColor.cgColor
        setTitleColor(.appBlueColor, for: .normal)
        titleLabel?.font = UIFont.init(name: "Manrope-Bold", size: 14)
        titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
}
