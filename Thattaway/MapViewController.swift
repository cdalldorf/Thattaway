//
//  MapViewController.swift
//  Thattaway
//
//  Created by Chris Dalldorf on 6/20/18.
//  Copyright © 2018 Chris Dalldorf. All rights reserved.
//

// TODO: change everything to delegate stuff

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

protocol MapDelegate: class {
    func mapUpdated(annotation: MKPointAnnotation)
}

internal class MapViewController : UIViewController {
    var endPin:MKPlacemark? = nil
    var delegate : MapDelegate?
    @IBOutlet weak var MapView: MKMapView!
    var location : CLLocation?
    var resultSearchController : UISearchController? = nil
    var annotation : MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // add an annotation if one exists
        if annotation != nil {
            let span = MKCoordinateSpan(latitudeDelta: abs((annotation?.coordinate.latitude)! - (location?.coordinate.latitude)!) + 0.05, longitudeDelta: abs((annotation?.coordinate.longitude)! - (location?.coordinate.longitude)!) + 0.05)
            let middle = CLLocationCoordinate2D(latitude: 0.5 * ((annotation?.coordinate.latitude)! + (location?.coordinate.latitude)!), longitude: 0.5 * ((annotation?.coordinate.longitude)! + (location?.coordinate.longitude)!))
            let region = MKCoordinateRegionMake(middle, span)
            MapView.setRegion(region, animated: true)
        } else {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: (self.location?.coordinate)!, span: span)
            MapView.setRegion(region, animated: true)
        }
        
        
        // setting up ability to click on map
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.mapLongPress(_:))) // colon needs to pass through info
        longPress.minimumPressDuration = 1.5 // in seconds
        //add gesture recognition
        MapView.addGestureRecognizer(longPress)
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        locationSearchTable.delegate = self
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Pick a place to go you fool"
        navigationItem.titleView = resultSearchController?.searchBar
  
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = MapView
        
        // drop a pin if there already was one
        if annotation != nil {
            MapView.addAnnotation(annotation!)
        }
    }
    
    func dropPinZoomIn(){
        // clear existing pins
        MapView.removeAnnotations(MapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = (endPin?.coordinate)!
        annotation.title = endPin?.name ?? "uh oh"
        if let city = endPin?.locality,
            let state = endPin?.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        MapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake((endPin?.coordinate)!, span)
        MapView.setRegion(region, animated: true)
        
        // transitioning to delegate
        delegate?.mapUpdated(annotation: annotation)
    }
    
    // func called when long press
    @objc func mapLongPress(_ recognizer: UIGestureRecognizer) {
        // first clear existing pins
        MapView.removeAnnotations(MapView.annotations)
        
        // add our new pin
        let touchedAt = recognizer.location(in: self.MapView) // adds the location on the view it was pressed
        let touchedAtCoordinate : CLLocationCoordinate2D = MapView.convert(touchedAt, toCoordinateFrom: self.MapView) // will get coordinates
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchedAtCoordinate
        annotation.title = "Custom Destination"
        MapView.addAnnotation(annotation)
        
        // transitioning to delegate
        delegate?.mapUpdated(annotation: annotation)
    }
}

extension MapViewController: SearchDelegate {
    func searchCompleted(endpin: MKPlacemark) {
        self.endPin = endpin
        dropPinZoomIn()
    }
}




