//
//  ViewController.swift
//  Project22
//
//  Created by Guillermo Suarez on 15/4/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var distanceReading: UILabel!
    
    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
    }


    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        print("locationManagerDidChangeAuthorization")
        if manager.authorizationStatus == .authorizedAlways {
            
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    //do stuff
                    
                }
            }
        }
    }
    
    
}

