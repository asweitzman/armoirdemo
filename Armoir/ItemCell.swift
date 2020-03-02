//
//  ItemCell.swift
//  Armoir
//
//  Created by rhea krtr on 03/12/18.
//  Copyright © 2018 CS147. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {
   
    @IBOutlet weak var due_display: UILabel!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var img_display: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        img_display.image = nil
    }
}
