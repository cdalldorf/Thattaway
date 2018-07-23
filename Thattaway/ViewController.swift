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
    var location : CLLocation?
    var location2d : CLLocation?
    let navModel = Navigator()
    var type = "any"

    @IBOutlet weak var nameSwitch: UISwitch!
    
    @IBAction func toggleNameShow(_ sender: UISwitch) {
        updateLocationName(name: navModel.name)
    }
    
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var foundPlaceLabel: UILabel!
    @IBOutlet weak var suggestLocationButton: UIButton!
    
    @IBAction func suggestLocation(_ sender: UIButton) {
        sender.isEnabled = false
        navModel.findRatedLocation(typeRequested: type)
    }
    
    @IBOutlet weak var targetName: UILabel!
    
    func updateLocationName(name: String) {
        if (targetName != nil) {
            targetName.text = nameSwitch.isOn ? navModel.name : " "
        }
    }
    
    func updateView() {
        updateLocationName(name: navModel.name)
        foundPlaceLabel.text = navModel.changed ? "✔" : "𐄂"
        typeButton.setTitle(type, for: .normal)
        
        // add other UI stuff here
    }
    
    @IBOutlet weak var arrowView: Arrow!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        navModel.location = CLLocation(latitude: 90.0, longitude: 0.0)
        
        // setting up location stuff
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        // delegate stuff
        navModel.delegate = self
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
                nextViewController.location = self.location!
                nextViewController.annotation = self.navModel.annotation
                nextViewController.delegate = self
                
                // TODO fully change to delegate stuff
            }
        } else if segue.identifier == "goToTypeSelection" {
            if let nextViewController = segue.destination as? TypeTableViewController {
                nextViewController.delegate = self
            }
        }
    }
}

extension ViewController: NavigatorDelegate {
    func dataUpdated() {
        updateView()
        suggestLocationButton.isEnabled = true
    }
}

extension ViewController: TypeTableDelegate {
    func typeUpdated(type: String) {
        self.type = type
        updateView()
    }
}

extension ViewController: MapDelegate {
    func mapUpdated(annotation: MKPointAnnotation) {
        self.navModel.annotation = annotation
        self.navModel.location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        self.navModel.name = annotation.title!
        self.updateLocationName(name: self.navModel.name)
    }
}
