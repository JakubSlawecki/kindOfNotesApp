//
//  CollectionViewCell.swift
//  kindOfNotesApp
//
//  Created by Jakub Slawecki on 27/02/2019.
//  Copyright © 2019 Jakub Slawecki. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet var noteImage : UIImageView!
    
    func displayContent(image: UIImage) {
        noteImage.image = image
    }
    
}
