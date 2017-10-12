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
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .fastFormat
        
        manager.requestImage(for: assets,
                             targetSize: frame.size,
                             contentMode: .aspectFit,
                             options: requestOptions,
                             resultHandler: { [weak self] (image, info) in
                                guard let _ = self, let image = image else { return }
                                self?.imageView.image = image
        })
    }
}
