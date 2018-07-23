//
//  MapViewController.swift
//  Thattaway
//
//  Created by Chris Dalldorf on 6/20/18.
//  Copyright © 2018 Chris Dalldorf. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

internal class MapViewController : UIViewController {
    var endPin:MKPlacemark? = nil {
        didSet {
            
        }
    }
    
    @IBOutlet weak var MapView: MKMapView!
    
    var mainVC : ViewController?
    
    var location : CLLocation?
    
    var navModel : Navigator?
    
    var resultSearchController : UISearchController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: (self.location?.coordinate)!, span: span)
        MapView.setRegion(region, animated: true)
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        locationSearchTable.mainVC = mainVC
        locationSearchTable.mapVC = self
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
        if let annotation = mainVC?.navModel.annotation {
            MapView.addAnnotation(annotation)
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
        mainVC?.pin = endPin
        mainVC?.navModel.annotation = annotation
    }
}
