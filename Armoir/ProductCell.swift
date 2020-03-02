//
//  ProductCell.swift
//  Armoir
//
//  Created by alex weitzman on 11/29/18.
//  Copyright © 2018 CS147. All rights reserved.
//

import UIKit

class ProductCell: UICollectionViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var productPrice: UILabel!
    
    @IBOutlet weak var productDistance: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImage.image = nil
    }
}
