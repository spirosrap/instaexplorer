//
//  CollectionViewCell.swift
//
//  The cell for collection view. It displays the images for the album.
//  Created by spiros on 14/3/15.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//
//

import UIKit
class CollectionViewCell: UICollectionViewCell {
    //Cell will display the image and the activity indicator while loading.

    @IBOutlet var photo: UIImageView!
    @IBOutlet var indicator: UIActivityIndicatorView!
    var deleteImageView: UIImageView! //Temporary Image View to Hold the delete image that will be put on top of the collection view cell image
    var image:UIImage!
}

