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
                    starScanning()
                }
            }
        }
    }
    
    func starScanning() {
        
        //you need to add beacon information: uuid major and minor
        let uuid = UUID(uuidString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6")!
        let beaconRegion = CLBeaconRegion(uuid: uuid, major: 123, minor: 456, identifier: "MyBeacon")
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
    }
    
    
    func update(distance: CLProximity) {
        
        UIView.animate(withDuration: 1) {
            
            switch distance {
                
            case .unknown:
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKNOWN"
                
            case .far:
                self.view.backgroundColor = .blue
                self.distanceReading.text = "FAR"
                
            case .immediate:
                self.view.backgroundColor = .red
                self.distanceReading.text = "RIGHT HERE"
                
            case .near:
                self.view.backgroundColor = .orange
                self.distanceReading.text = "NEAR"
            
            @unknown default:
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKNOWN"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        if let beacon = beacons.first {
            
            update(distance: beacon.proximity)
        } else {
            
            update(distance: .unknown)
        }
    }
}

