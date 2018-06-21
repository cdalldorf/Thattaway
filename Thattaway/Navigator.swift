//
//  Navigator.swift
//  Thattaway
//
//  Created by Chris Dalldorf on 6/20/18.
//  Copyright © 2018 Chris Dalldorf. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import CoreLocation

class Navigator {
    var error : NSError!
    var latitude = 0.0
    var longitude = 0.0
    var bearing = 0.0
    var location : CLLocation? {
        didSet{
            latitude = (location?.coordinate.latitude)!
            longitude = (location?.coordinate.longitude)!
            initDistance = nil
            findBestLocation(near: location!)
        }
    }
    var initDistance : Double?
    var bestLocation : CLLocation?
    
    private func findBestLocation(near location: CLLocation) {
        let request = MKLocalSearchRequest()
        let coorSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        request.region = MKCoordinateRegion(center: location.coordinate, span: coorSpan)
        request.naturalLanguageQuery = "Restaurant"
        let search = MKLocalSearch(request: request)
        search.start {
            (response: MKLocalSearchResponse!, error: Error?) in
            
            for item in response.mapItems {
                print(item.name ?? "didn't find")
                
                //println("Latitude = \(item.placemark.location.coordinate.latitude)")
                //println("Longitude = \(item.placemark.location.coordinate.longitude)")
            }
        }
    }
    
    func getDistance(destination: CLLocation) -> Double {
        let latDiff = destination.coordinate.latitude - latitude
        let longDiff = destination.coordinate.longitude - longitude
        
        let a = sin(latDiff/2) * sin(latDiff/2) +
            cos(latitude) * cos(destination.coordinate.latitude) *
            sin(longDiff/2) * sin(longDiff/2)
        return(2 * atan2(sqrt(a), sqrt(1-a)))
    }
    
}
