//
//  GameLogTableViewCell.swift
//  Coup
//
//  Created by Sungwook Kim on 2021/07/29.
//

import UIKit

class GameLogTableViewCell: UITableViewCell {

    @IBOutlet weak var aiImageView: UIImageView!
    @IBOutlet weak var aiNameLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var identity1Label: UILabel!
    @IBOutlet weak var identity2Label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
