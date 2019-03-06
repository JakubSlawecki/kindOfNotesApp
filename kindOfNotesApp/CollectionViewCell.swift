//
//  CollectionViewCell.swift
//  kindOfNotesApp
//
//  Created by Jakub Slawecki on 27/02/2019.
//  Copyright © 2019 Jakub Slawecki. All rights reserved.
//

import UIKit


protocol CollectionViewCellProtocol {
    func deleteData(index: Int)
}


class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    var delegate: CollectionViewCellProtocol?
    var index: IndexPath?
    
    
    @IBAction func deleteButton(_ sender: Any) {
        delegate?.deleteData(index: (index?.row)!)
    }
}
