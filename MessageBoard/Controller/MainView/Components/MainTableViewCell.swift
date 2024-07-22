//
//  MainTableViewCell.swift
//  MessageBoard
//
//  Created by imac-2627 on 2024/7/18.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var lbTest: UILabel!
    
    // MARK: - Property
    
    static let identified = "MainTableViewCell"
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lbTest.numberOfLines = 0 // 多行顯示
        lbTest.lineBreakMode = .byWordWrapping //利用單詞換行
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // MARK: - UI Settings
    
    // MARK: - IBAction
    
    // MARK: - Function
    
}

// MARK: - Extensions
