//
//  FindFriendsCell.swift
//  Makestagram
//
//  Created by Sakada Lim on 7/12/17.
//  Copyright © 2017 Sakada Lim. All rights reserved.
//

import UIKit


protocol FindFriendsCellDelegate: class {
    func didTapFollowButton(_ followButton: UIButton, on cell: FindFriendsCell)
}


class FindFriendsCell: UITableViewCell{
    
    weak var delegate: FindFriendsCellDelegate?
    
    
    // MARK: - Properties
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    
    // MARK: - Cell Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        followButton.layer.borderColor = UIColor.lightGray.cgColor
        followButton.layer.borderWidth = 1
        followButton.layer.cornerRadius = 6
        followButton.clipsToBounds = true
        
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitle("Following", for: .selected)
    }
    
    // MARK: - IBActions
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        delegate?.didTapFollowButton(sender, on: self)
    }
    
    
}

