//
//  BeerTableViewCell.swift
//  Beer Test
//
//  Created by Alfredo Rinaudo on 09/03/2020.
//  Copyright © 2020 co.soprasteria. All rights reserved.
//

import UIKit

class BeerTableViewCell: UITableViewCell {

    @IBOutlet weak var beerImage: UIImageView!
    @IBOutlet weak var abv: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var tags: UILabel!
    @IBOutlet weak var abvView: UIView!
    @IBOutlet weak var pairedFood: UILabel!
    @IBOutlet weak var goodWith: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        abvView.layer.cornerRadius = 10.0
        abvView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class SuggestionTableViewCell: UITableViewCell {
    @IBOutlet weak var suggestion: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
