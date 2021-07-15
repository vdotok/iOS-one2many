//
//  UIView+Extension.swift
//  iOS-one2many
//
//  Created by usama farooq on 09/07/2021.
//

import Foundation
import UIKit

extension UIView {
    func removeAllSubViews() {
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
    }
    
    func fixInSuperView() {
        guard let _superView = self.superview else {return}
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: _superView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo:_superView.trailingAnchor),
            self.topAnchor.constraint(equalTo: _superView.topAnchor),
            self.bottomAnchor.constraint(equalTo: _superView.bottomAnchor)
        ])
    }
    
    func fixInMiddleOfSuperView(){
        guard let _superView = self.superview else {return}
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: _superView.centerXAnchor),
            self.centerYAnchor.constraint(equalTo:_superView.centerYAnchor)
        ])
    }
    
    func addConstraintsFor(width: CGFloat, and height: CGFloat){
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: height),
            self.widthAnchor.constraint(equalToConstant: width)
        ])
    }
}
