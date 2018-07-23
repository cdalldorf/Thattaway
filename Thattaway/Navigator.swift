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
}

class Navigator {
    var error : NSError!
    var annotation : MKPointAnnotation?
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
    
    
    // unsure what this was used for, I think before I used google places
    /*private func findBestLocation(near location: CLLocation) {
        let request = MKLocalSearchRequest()
        let coorSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        request.region = MKCoordinateRegion(center: location.coordinate, span: coorSpan)
        //request.naturalLanguageQuery = "Restaurant"
        let search = MKLocalSearch(request: request)
        search.start {
            (response: MKLocalSearchResponse!, error: Error?) in
            
            for item in response.mapItems {
                print(item.name ?? "didn't find")
                
                //println("Latitude = \(item.placemark.location.coordinate.latitude)")
                //println("Longitude = \(item.placemark.location.coordinate.longitude)")
            }
        }
    }*/
    
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
                if (typeRequested == "any" || self.likelyPlaces[index].types.contains(typeRequested)) {
                    if (self.likelyPlaces[index].rating > maxRating) && !(self.likelyPlaces[index].coordinate.latitude == self.latitude && self.likelyPlaces[index].coordinate.longitude == self.longitude) {
                        maxRating = self.likelyPlaces[index].rating
                        maxIndex = index
                    }
                }
            }
            
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
