//
//  AnnotationBasic.swift
//  Thattaway
//
//  Created by Chris Dalldorf on 8/17/18.
//  Copyright © 2018 Chris Dalldorf. All rights reserved.
//
// This class makes annotations codable
//

import Foundation
import MapKit


class AnnotationBasic:Codable {
    var latitude: Double?
    var longitude: Double?
    var name: String?
    
    init(latitude: Double, longitude: Double, name: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
    }
}

func getAnnotationFromBasic(basic: AnnotationBasic) -> MKPointAnnotation {
    let annotation = MKPointAnnotation()
    annotation.coordinate = CLLocationCoordinate2D(latitude: basic.latitude!, longitude: basic.longitude!)
    annotation.title = basic.name
    return(annotation)
}
