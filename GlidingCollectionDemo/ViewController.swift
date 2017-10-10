//
//  ViewController.swift
//  GlidingCollectionDemo
//
//  Created by Abdurahim Jauzee on 04/03/2017.
//  Copyright © 2017 Ramotion Inc. All rights reserved.
//

import UIKit
import GlidingCollection
import Photos


class ViewController: UIViewController {
  
    @IBOutlet var glidingView: GlidingCollection!
    fileprivate var collectionView: UICollectionView!
    fileprivate var assetCollection: PHAssetCollection = PHAssetCollection()
    fileprivate var photoAsset: PHFetchResult<PHAsset>!
    fileprivate var assetThumbnailSize: CGSize!
    var photoAssets: Array! = [PHAsset]()

    
    fileprivate var items = ["gloves", "boots", "bindings", "hoodie"]
    fileprivate var images: [[UIImage?]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - Setup
extension ViewController {
    
    func setup() {
        setupGlidingCollectionView()
        loadImages()
    }
    
    private func setupGlidingCollectionView() {
        glidingView.dataSource = self
        
        let nib = UINib(nibName: "CollectionCell", bundle: nil)
        collectionView = glidingView.collectionView
        collectionView.register(nib, forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = glidingView.backgroundColor
    }

    private func loadImages() {
//        for item in items {
//            let imageURLs = FileManager.default.fileUrls(for: "jpeg", fileName: item)
//            var images: [UIImage?] = []
//            for url in imageURLs {
//                guard let data = try? Data(contentsOf: url) else { continue }
//                let image = UIImage(data: data)
//                images.append(image)
//            }
//            self.images.append(images)
//        }
        getAllPhotosInfo()
    }
    
    fileprivate func getAllPhotosInfo() {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        
        let assets: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        assets.enumerateObjects({ [weak self] (asset, index, stop) -> Void in
            guard let wself = self else {
                return
            }
            wself.photoAssets.append(asset as PHAsset)
        })
    }
}

// MARK: - CollectionView 🎛
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//    let section = glidingView.expandedItemIndex
//    return images[section].count
    return photoAssets.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CollectionCell else { return UICollectionViewCell() }
//    let section = glidingView.expandedItemIndex
//    let image = images[section][indexPath.row]
    cell.setConfigure(assets: photoAssets[indexPath.row])
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
    let section = glidingView.expandedItemIndex
    let item = indexPath.item
  }
  
}

// MARK: - Gliding Collection 🎢
extension ViewController: GlidingCollectionDatasource {
  
  func numberOfItems(in collection: GlidingCollection) -> Int {
    return 1
  }
  
  func glidingCollection(_ collection: GlidingCollection, itemAtIndex index: Int) -> String {
    return "– " + "myPhotos"
  }
  
}



// モーメントリストを取得する
func getMomentList() -> [PHCollectionList] {
    let fetchResult: PHFetchResult = PHCollectionList.fetchCollectionLists(with: .momentList, subtype: .any, options: nil)
    var momentLists = [PHCollectionList]()
    fetchResult.enumerateObjects({ (moment, idx, stop) -> Void in
        momentLists.append(moment)
    })
    return momentLists
}

// モーメントを取得する
func getMoment(momentList: PHCollectionList) -> [PHAssetCollection] {
    let fetchResult: PHFetchResult = PHAssetCollection.fetchMoments(inMomentList: momentList, options: nil)
    var moments = [PHAssetCollection]()
    if fetchResult.count == 1 {
        fetchResult.enumerateObjects({ (moment, idx, stop) -> Void in
            moments.append(moment)
        })
    }
    return moments
}

// 写真を月別に取得する
func getPhotosByMonth(moment: PHAssetCollection) -> [[PHAsset]] {
    
    // 年の文字列を取得する
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    let year = formatter.string(from: moment.startDate!)
    
    var photosByMonth = [[PHAsset]]()
    
    for i in 0..<13 {
        // 月初日と月末日を生成します
        let month = NSString(format:"%02d", i) as String
        let fromDate = getDateFromString(year: year, month: month, day: "01")
        let toDate = getMonthEndingDate(beginningDate: fromDate!)
        
        // オプションを指定してフェッチします
        let fetchOption = PHFetchOptions()
        fetchOption.predicate = NSPredicate(format: "(creationDate >= %@) and (creationDate) < %@", fromDate!, toDate)
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: moment, options: fetchOption)
        var photos = [PHAsset]()
        fetchResult.enumerateObjects({ (photo, idx, stop) -> Void in
            photos.append(photo)
        })
        photosByMonth.append(photos)
    }
    return photosByMonth
}

fileprivate func getDateFromString(year: String, month: String, day: String) -> NSDate? {
    let formatter = DateFormatter()
    formatter.calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)! as Calendar!  // 24時間表示対策
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone!
    formatter.dateFormat = "yyyyMMdd"
    let dateString = year + month + day
    return formatter.date(from: dateString) as NSDate?
}

fileprivate func getMonthEndingDate(beginningDate: NSDate) -> NSDate {
    let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
    calendar.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
    var comp = calendar.components(
        [NSCalendar.Unit.year
            ,NSCalendar.Unit.month
            ,NSCalendar.Unit.day
            ,NSCalendar.Unit.hour
            ,NSCalendar.Unit.minute
            ,NSCalendar.Unit.second]
        , from:beginningDate as Date)
    comp.hour = 23
    comp.minute = 59
    comp.second = 59
    let range = calendar.range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: beginningDate as Date)
    comp.day = range.length
    return calendar.date(from: comp)! as NSDate
}
