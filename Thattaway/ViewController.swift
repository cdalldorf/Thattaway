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

    @IBOutlet weak var nameSwitch: UISwitch!
    
    @IBAction func toggleNameShow(_ sender: UISwitch) {
        updateLocationName(name: navModel.name)
    }
    
    @IBAction func moveToMap(_ sender: Any) {
        
    }
    
    @IBAction func suggestLocation(_ sender: UIButton) {
        navModel.findRatedLocation()
        updateLocationName(name: navModel.name)
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
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        navModel.bearing = newHeading.trueHeading * (Double.pi / 180);
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
        let y = sin(navModel.longitude-userLocation.coordinate.longitude) * cos(navModel.latitude);
        let x = cos(userLocation.coordinate.latitude)*sin(navModel.latitude) -
            sin(userLocation.coordinate.latitude)*cos(navModel.latitude)*cos(navModel.longitude-userLocation.coordinate.longitude);
        let brng = atan2(y, x) - navModel.bearing;
        arrowView.rotationAngle = brng
        
        //print("user latitude = \(userLocation.coordinate.latitude)")
        //print("user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToMap"{
            if let nextViewController = segue.destination as? MapViewController {
                nextViewController.location = self.location
                nextViewController.navModel = navModel
                nextViewController.mainVC = self
            }
        }
    }
    
}
