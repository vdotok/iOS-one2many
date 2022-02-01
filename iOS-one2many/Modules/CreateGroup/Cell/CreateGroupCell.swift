//
//  CreateGroupCell.swift
//  one-to-many-call
//
//  Created by usama farooq on 14/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import UIKit


class CreateGroupCell: UITableViewCell {
    
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var tickImage: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with user: User, selected: Bool) {
        self.userName.text = user.fullName
        tickImage.isHidden = selected
    }
    
    private func configureAppearance() {
        userName.font = UIFont(name: "Manrope-Medium", size: 15)
        userName.textColor = .appDarkColor
        
    }
    
 
    
}
