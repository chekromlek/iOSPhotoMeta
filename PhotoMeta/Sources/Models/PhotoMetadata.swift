//
//  PhotoMetadata.swift
//  PhotoMeta
//
//  Created by Veasna Sreng on 8/12/19.
//  Copyright © 2019 Veasna Sreng. All rights reserved.
//

import UIKit
import CoreLocation

class PhotoMetadata {

    private var imgLocation: Location!
    private var imgCaptureAt: Date!
    private var imgSize: CGSize!
    private var deviceModel: String!
    private var deviceOEM: String!
    private var imgFileName: String!
    
    init(metadata aMetadata: [String:Any]) {
        if let date = aMetadata["{IPTC}"] as? NSDictionary,
            let createDateAt = date["DigitalCreationDate"] as? NSString,
            let createTimeAt = date["DigitalCreationTime"] as? NSString,
            let name = date["ObjectName"] as? String {
            
            var dateComponent = DateComponents()
            dateComponent.year = createDateAt.integerValue / 10000
            dateComponent.month = (createDateAt.integerValue % 10000) / 100
            dateComponent.day = createDateAt.integerValue % 100
            dateComponent.hour = createTimeAt.integerValue / 10000
            dateComponent.minute = (createTimeAt.integerValue % 10000) / 100
            dateComponent.second = createTimeAt.integerValue % 100
            
            self.imgCaptureAt = Calendar.current.date(from: dateComponent)
            self.imgFileName = name
        }
        
        if let exif = aMetadata["{Exif}"] as? NSDictionary,
            let xDimention = exif["PixelXDimension"] as? NSNumber,
            let yDimention = exif["PixelYDimension"] as? NSNumber {
            self.imgSize = CGSize(width: xDimention.intValue as Int, height: yDimention.intValue as Int)
        }
        
        if let tiff = aMetadata["{TIFF}"] as? NSDictionary,
            let company = tiff["Make"] as? NSString,
            let model = tiff["Model"] as? NSString {
            self.deviceOEM = company as String
            self.deviceModel = model as String
        }
        
        if let gps = aMetadata["{GPS}"] as? NSDictionary,
            let latitude = gps["Latitude"] as? NSNumber,
            let longitude = gps["Longitude"] as? NSNumber {
            self.imgLocation = Location(latitude: latitude, longitude: longitude)
        }

    }
    
    func isSensitiveMetaAvailable() -> Bool {
        return self.imgLocation != nil || self.deviceModel != nil || self.deviceOEM != nil || self.imgCaptureAt != nil
    }
    
    func address(label: UILabel?) {
        if (self.imgLocation == nil) {
            label?.text = "Unknown"
            return
        }
        label?.text = ""
        
        let clGeocoder = CLGeocoder()
        clGeocoder.reverseGeocodeLocation(CLLocation(latitude: CLLocationDegrees(exactly: self.imgLocation.latitude)!, longitude: CLLocationDegrees(exactly: self.imgLocation.longitude)!)) { (places: [CLPlacemark]?, error: Error?) in
         
            if let place = places?.first,
                place.country != nil {
                
                label?.text = "\(place.name!), \(place.country!)"
                
            } else {
                label?.text = "Unknown"
            }
            
        }
    }
    
    func coordinate() -> String {
        if self.imgLocation == nil {
            return "Unknown"
        }
        return "\(self.imgLocation.latitude) ・ \(self.imgLocation.longitude)"
    }
    
    func captureAt() -> String {
        if self.imgCaptureAt == nil {
            return "Unknown"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE, MMM d, yyyy ・ HH:mm aaa")
        return dateFormatter.string(from: self.imgCaptureAt)
    }
    
    func model() -> String {
        return self.deviceModel == nil ? "Unknown" : self.deviceModel
    }
    
    func spec(filesize: Int) -> String {
        if self.imgSize == nil {
            return "Unknown"
        }
        
        let formatter:ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .binary
        let humanReadableFileSize = formatter.string(fromByteCount: Int64(filesize))
        
        let megaPixel = floor((self.imgSize.width * self.imgSize.height) / 1000000)
        return "\(megaPixel)MP ・ \(self.imgSize.width.clean)x\(self.imgSize.height.clean)px ・ \(humanReadableFileSize)"
    }
}

class Location {
    
    var longitude: NSNumber
    var latitude: NSNumber
    
    init(latitude aLatitude: NSNumber, longitude aLongitude: NSNumber) {
        self.latitude = aLatitude
        self.longitude = aLongitude
    }
    
}
