//
//  CustomPin.swift
//  SocialApp
//
//  Created by Sergey Korobin on 20.09.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import Foundation
import MapKit

class CustomPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
