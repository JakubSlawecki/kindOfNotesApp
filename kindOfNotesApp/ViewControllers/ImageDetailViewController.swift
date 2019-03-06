//
//  ImageDetailViewController.swift
//  kindOfNotesApp
//
//  Created by Jakub Slawecki on 28/02/2019.
//  Copyright © 2019 Jakub Slawecki. All rights reserved.
//

import UIKit


class ImageDetailViewController: UIViewController {
    @IBOutlet weak var detailImage: UIImageView!


    var image = UIImage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailImage.image = image
        detailImage.layer.cornerRadius = 10.0
        detailImage.clipsToBounds = true
    }
    

}
