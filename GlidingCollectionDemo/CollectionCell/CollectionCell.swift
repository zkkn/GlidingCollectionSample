//
//  CollectionCell.swift
//  GlidingCollection
//
//  Created by Abdurahim Jauzee on 07/03/2017.
//  Copyright © 2017 Ramotion Inc. All rights reserved.
//

import Photos
import UIKit


class CollectionCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    func setConfigure(assets: PHAsset) {
        let manager = PHImageManager()
        
        manager.requestImage(for: assets,
                             targetSize: frame.size,
                             contentMode: .aspectFill,
                             options: nil,
                             resultHandler: { [weak self] (image, info) in
                                guard let wself = self, let _ = image else {
                                    return
                                }
                                wself.imageView.image = image
        })
    }
}
