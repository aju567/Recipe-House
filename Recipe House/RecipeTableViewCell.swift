//
//  RecipeTableViewCell.swift
//  Recipe House
//
//  Created by Ajay Vandra on 2/26/20.
//  Copyright © 2020 Ajay Vandra. All rights reserved.
//

import UIKit


class RecipeTableViewCell: UITableViewCell {
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var RecipeTypeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var recipeNameLabel: UILabel!
     @IBOutlet weak var timeLabel: UILabel!
     @IBOutlet weak var levelLabel: UILabel!
     @IBOutlet weak var peopleLabel: UILabel!
    
    @IBOutlet weak var editButtonOutlet: UIButton!
    @IBOutlet weak var commentButtonLabel: UIButton!
    @IBOutlet weak var favoriteButtonLabel: UIButton!
    @IBOutlet weak var count: UILabel!
    var recipeId : Int?
    
    @IBAction func commentButton(_ sender: UIButton) {
    }
    
    @IBAction func favoriteButton(_ sender: UIButton) {
//        if counts == 0{
//             favoriteButtonLabel.setImage(UIImage(named: "redHeart"), for: .normal)
//            counts = 1
//        }else if counts == 1{
//            favoriteButtonLabel.setImage(UIImage(named: "grayHeart"), for: .normal)
//            counts = 0
//        }
    }
}
