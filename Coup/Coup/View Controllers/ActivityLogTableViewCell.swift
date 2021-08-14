//
//  GameLogTableViewCell.swift
//  Coup
//
//  Created by Sungwook Kim on 2021/07/25.
//

import UIKit

class ActivityLogTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfile: UIImageView!
    @IBOutlet weak var gameLogLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
