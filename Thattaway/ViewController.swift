//
//  ViewController.swift
//  Thattaway
//
//  Created by Chris Dalldorf on 6/19/18.
//  Copyright © 2018 Chris Dalldorf. All rights reserved.
//

import UIKit
import MapKit


class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    var pin : MKPlacemark?
    
    var location : CLLocation?
    
    var location2d : CLLocation?
    
    let navModel = Navigator()
    
    var type = ""

    @IBOutlet weak var nameSwitch: UISwitch!
    
    @IBAction func toggleNameShow(_ sender: UISwitch) {
        updateLocationName(name: navModel.name)
    }
    
    @IBOutlet weak var typeButton: UIButton!
    
    @IBOutlet weak var foundPlaceLabel: UILabel!
    
    @IBAction func suggestLocation(_ sender: UIButton) {
        navModel.findRatedLocation(typeRequested: type)
        updateLocationName(name: navModel.name)
        
        // check to see if the location didn't change
        foundPlaceLabel.text = navModel.changed ? "✔" : "𐄂"
    }
    
    @IBOutlet weak var targetName: UILabel!
    
    func updateLocationName(name: String) {
        if (targetName != nil) {
            targetName.text = nameSwitch.isOn ? navModel.name : " "
        }
    }
    
    @IBOutlet weak var arrowView: Arrow!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // setting up location stuff
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // helper funcs
    func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }
    
    
    // returns radian bearings between two points
    func getBearingBetweenTwoPoints(point1 : CLLocation, point2 : CLLocation) -> Double {
        let lat1 = degreesToRadians(degrees: point1.coordinate.latitude)
        let lon1 = degreesToRadians(degrees: point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(degrees: point2.coordinate.latitude)
        let lon2 = degreesToRadians(degrees: point2.coordinate.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansBearing
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let oldBearing = navModel.bearing
        navModel.bearing = newHeading.trueHeading * (Double.pi / 180);
        arrowView.rotationAngle = arrowView.rotationAngle + (navModel.bearing - oldBearing)
        
        // now update the arrow if location != nil
        if let userLocation = location, let destinationLocation = navModel.location {
            arrowView.rotationAngle = getBearingBetweenTwoPoints(point1: userLocation, point2: destinationLocation) - navModel.bearing
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        location = locations[0]
        
        // update distance
        if navModel.initDistance == nil {
            navModel.initDistance = navModel.getDistance(destination: location!)
        }
        arrowView.distRatio = navModel.getDistance(destination: location!) / navModel.initDistance!
        
        
        // now calculate the new rotationAngle
        if let destinationLocation = navModel.location {
            arrowView.rotationAngle = getBearingBetweenTwoPoints(point1: userLocation, point2: destinationLocation) - navModel.bearing
        }
        
        //print("user latitude = \(userLocation.coordinate.latitude)")
        //print("user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToMap" {
            if let nextViewController = segue.destination as? MapViewController {
                nextViewController.location = self.location
                nextViewController.navModel = navModel
                nextViewController.mainVC = self
            }
        } else if segue.identifier == "goToTypeSelection" {
            if let nextViewController = segue.destination as? TypeTableViewController {
                nextViewController.mainVC = self
            }
        }
    }
    
}
