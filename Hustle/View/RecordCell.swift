//
//  RecordCell.swift
//  Hustle
//
//  Created by Doeun Kwon on 2021-09-18.
//

import UIKit

class RecordCell: UITableViewCell {
    
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var spendLabel: UILabel!
    @IBOutlet weak var dailyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
