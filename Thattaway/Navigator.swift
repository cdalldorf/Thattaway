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
import GooglePlaces

protocol NavigatorDelegate: class {
    func dataUpdated()
    func annotationSet()
}

class Navigator {
    var error : NSError!
    var annotation : MKPointAnnotation? {
        didSet{
            delegate?.annotationSet()
            location = CLLocation(latitude: (annotation?.coordinate.latitude)!, longitude: (annotation?.coordinate.longitude)!)
        }
    }
    var latitude = 0.0
    var longitude = 0.0
    var bearing = 0.0
    var changed = false
    var placesClient : GMSPlacesClient!
    var likelyPlaces: [GMSPlace] = []
    var name = " "
    weak var delegate : NavigatorDelegate?
    var location : CLLocation? {
        didSet{
            latitude = (location?.coordinate.latitude)!
            longitude = (location?.coordinate.longitude)!
            initDistance = nil
            //findBestLocation(near: location!)
        }
    }
    var initDistance : Double?
    var bestLocation : CLLocation?
    
    
    func getDistance(destination: CLLocation) -> Double {
        let latDiff = destination.coordinate.latitude - latitude
        let longDiff = destination.coordinate.longitude - longitude
        
        let a = sin(latDiff/2) * sin(latDiff/2) +
            cos(latitude) * cos(destination.coordinate.latitude) *
            sin(longDiff/2) * sin(longDiff/2)
        return(2 * atan2(sqrt(a), sqrt(1-a)))
    }
    
    func findRatedLocation(typeRequested: String) {
        placesClient = GMSPlacesClient.shared()
        
        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            if let error = error {
                // Handle the error.
                print("Current Place error: \(error.localizedDescription)")
                return
            }
            
            // TODO: figure out how "local" local places are and if it's modifiable
            
            // Get likely places and add to the list.
            if let likelihoodList = placeLikelihoods {
                for likelihood in likelihoodList.likelihoods {
                    let place = likelihood.place
                    self.likelyPlaces.append(place)
                }
            }
            
            // now pick the highest rated one
            var maxRating : Float = -1.0
            var maxIndex = -1
            self.changed = false
            for index in self.likelyPlaces.indices {
                
                // TODO implement open now status
                if (typeRequested == "any" || self.likelyPlaces[index].types.contains(typeRequested)) {
                    if (self.likelyPlaces[index].rating > maxRating) && !(self.likelyPlaces[index].coordinate.latitude == self.latitude && self.likelyPlaces[index].coordinate.longitude == self.longitude) {
                        maxRating = self.likelyPlaces[index].rating
                        maxIndex = index
                    }
                }
            }
            
            // if a max rated exists that's different, set as new destination
            if maxIndex != -1 {
                self.changed = true
                self.location = CLLocation(latitude: self.likelyPlaces[maxIndex].coordinate.latitude, longitude: self.likelyPlaces[maxIndex].coordinate.longitude)
                self.name = self.likelyPlaces[maxIndex].name
                self.annotation?.coordinate = CLLocationCoordinate2D(latitude: self.location!.coordinate.latitude, longitude: self.location!.coordinate.longitude)
                self.annotation?.title = self.name
            }
            
            self.delegate?.dataUpdated()
        })
    }
    
}
