//
//  ViewController.swift
//  GlidingCollectionDemo
//
//  Created by Abdurahim Jauzee on 04/03/2017.
//  Copyright © 2017 Ramotion Inc. All rights reserved.
//

// インスタンスを毎回どこかで作っって初期化されてるせいでSmart FolderのVideoしか入ってない気がする

import GlidingCollection
import Photos
import UIKit


class ViewController: UIViewController {
    
    @IBOutlet var glidingView: GlidingCollection!
    fileprivate var collectionView: UICollectionView!
    fileprivate var assetThumbnailSize: CGSize!
    
    var allPhotos = [Photos]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}


// MARK: - Setup
extension ViewController {
    
    fileprivate func setup() {
        setupGlidingCollectionView()
        loadImages()
    }
    
    fileprivate func setupGlidingCollectionView() {
        glidingView.dataSource = self
        
        let nib = UINib(nibName: "CollectionCell", bundle: nil)
        collectionView = glidingView.collectionView
        collectionView.register(nib, forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = glidingView.backgroundColor
    }
    
    fileprivate func loadImages() {
        getSmartFolder(smartFolderList: getSmartFolderList())
    }
    
    fileprivate func getSmartFolderList() -> [PHAssetCollection] {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        var smartFolderLists = [PHAssetCollection]()
        fetchResult.enumerateObjects({ (smartFolder, idx, stop) -> Void in
            smartFolderLists.append(smartFolder)
        })
//        print(smartFolderLists)
        return smartFolderLists
    }
    
    fileprivate func getSmartFolder(smartFolderList: [PHAssetCollection]) {
        var allAssets = [Photos]()
        for smartFolder in smartFolderList {
            let fetchOption = PHFetchOptions()
            fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: smartFolder, options: fetchOption)
            if fetchResult.count != 0 {
                var photos = Photos()
                photos.name = smartFolder.localizedTitle!
                fetchResult.enumerateObjects({ (asset, idx, stop) -> Void in
                    photos.photos.append(asset)
                })
                allAssets.append(photos)
            }
        }
        self.allPhotos = allAssets
    }
}


// MARK: - CollectionView

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = glidingView.expandedItemIndex
        return allPhotos[section].photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CollectionCell else { return UICollectionViewCell() }
        let section = glidingView.expandedItemIndex
        cell.setConfigure(assets: allPhotos[section].photos[indexPath.row])
        
        cell.contentView.clipsToBounds = true
        
        let layer = cell.layer
        let config = GlidingConfig.shared
        layer.shadowOffset = config.cardShadowOffset
        layer.shadowColor = config.cardShadowColor.cgColor
        layer.shadowOpacity = config.cardShadowOpacity
        layer.shadowRadius = config.cardShadowRadius
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}


// MARK: - Gliding Collection
// どうやらこいつがViewDidLoadの前に呼ばれるからallPhotos.countが0になってうまくいかない
// あらかじめ定数でセットすればうまくいくので

extension ViewController: GlidingCollectionDatasource {
    func numberOfItems(in collection: GlidingCollection) -> Int {
//        return allPhotos.count
        return 8
    }
    
    func glidingCollection(_ collection: GlidingCollection, itemAtIndex index: Int) -> String {
//        return "\(allPhotos[index].name)"
        return "\(index)"
    }
}
