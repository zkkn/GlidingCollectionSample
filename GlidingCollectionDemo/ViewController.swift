//
//  ViewController.swift
//  GlidingCollectionDemo
//
//  Created by Abdurahim Jauzee on 04/03/2017.
//  Copyright © 2017 Ramotion Inc. All rights reserved.
//

import GlidingCollection
import Photos
import UIKit

class ViewController: UIViewController {
    @IBOutlet var glidingView: GlidingCollection!
    fileprivate var collectionView: UICollectionView!
    fileprivate var assetThumbnailSize: CGSize!
    
    var photoAlbums = [PhotoAlbum]()
    
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
        DispatchQueue.main.async {
            self.glidingView.reloadData()
        }
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
        return smartFolderLists
    }
    
    fileprivate func getSmartFolder(smartFolderList: [PHAssetCollection]) {
        var photoAlbums = [PhotoAlbum]()
        for smartFolder in smartFolderList {
            let fetchOption = PHFetchOptions()
            fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: smartFolder, options: fetchOption)
            if fetchResult.count != 0 {
                var photoAlbum = PhotoAlbum()
                photoAlbum.name = smartFolder.localizedTitle!
                fetchResult.enumerateObjects({ (photo, idx, stop) -> Void in
                    photoAlbum.photos.append(photo)
                })
                photoAlbums.append(photoAlbum)
            }
        }
        self.photoAlbums = photoAlbums
    }
}


// MARK: - CollectionView

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = glidingView.expandedItemIndex
        return photoAlbums[section].photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CollectionCell else { return UICollectionViewCell() }
        let section = glidingView.expandedItemIndex
        cell.setConfigure(assets: photoAlbums[section].photos[indexPath.row])
        
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

extension ViewController: GlidingCollectionDatasource {
    func numberOfItems(in collection: GlidingCollection) -> Int {
        return photoAlbums.count
    }
    
    func glidingCollection(_ collection: GlidingCollection, itemAtIndex index: Int) -> String {
        return "\(photoAlbums[index].name)"
    }
}
