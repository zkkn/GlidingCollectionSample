//
//  Photo.swift
//  GlidingCollection
//
//  Created by Shoichi Kanzaki on 2017/10/07.
//  Copyright © 2017年 Ramotion Inc. All rights reserved.
//

import Photos
import UIKit

struct Photos {
    var exist: Bool = false
    var photos: [PHAsset] = []
}

// モーメントリストを取得する
private func getMomentList() -> [PHCollectionList] {
    let fetchResult: PHFetchResult = PHCollectionList.fetchCollectionLists(with: .momentList, subtype: .any, options: nil)
    var momentLists = [PHCollectionList]()
    fetchResult.enumerateObjects({ (moment, idx, stop) -> Void in
        momentLists.append(moment)
    })
    return momentLists
}

// モーメントを取得する
private func getMoment(momentList: PHCollectionList) -> [PHAssetCollection] {
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
private func getPhotosByMonth(moment: PHAssetCollection) -> [Photos] {
    
    // 年の文字列を取得する
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    let year = formatter.string(from: moment.startDate!)
    
    var photosByMonth = [Photos]()
    
    for i in 1..<13 {
        // 月初日と月末日を生成します
        let month = NSString(format:"%02d", i) as String
        let fromDate = getDateFromString(year: year, month: month, day: "01")
        let toDate = getMonthEndingDate(beginningDate: fromDate!)
        
        // オプションを指定してフェッチします
        let fetchOption = PHFetchOptions()
        fetchOption.predicate = NSPredicate(format: "(creationDate >= %@) and (creationDate) < %@", fromDate!, toDate)
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: moment, options: fetchOption)
        var photos = Photos()
        if fetchResult.count != 0 {
            photos.exist = true
            fetchResult.enumerateObjects({ (photo, idx, stop) -> Void in
                photos.photos.append(photo)
            })
        }
        else {
            photos.exist = false
        }
        photosByMonth.append(photos)
    }
    return photosByMonth
}

private func getDateFromString(year: String, month: String, day: String) -> NSDate? {
    let formatter = DateFormatter()
    formatter.calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)! as Calendar!  // 24時間表示対策
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone!
    formatter.dateFormat = "yyyyMMdd"
    let dateString = year + month + day
    return formatter.date(from: dateString) as NSDate?
}

private func getMonthEndingDate(beginningDate: NSDate) -> NSDate {
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
