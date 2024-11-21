//
//  ContentView.swift
//  ParkingSpot
//
//  Created by Yael Javier Zamora Moreno on 20/11/24.
//

import SwiftUI
import Foundation
import CoreLocation
import MapKit

final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    var manager = CLLocationManager()
    
    
    func checkLocationAuthorization() {
        
        manager.delegate = self
        manager.startUpdatingLocation()
        
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            
        case .restricted:
            print("Location restricted")
            
        case .denied:
            print("Location denied")
            
        case .authorizedAlways:
            print("Location authorizedAlways")
            
        case .authorizedWhenInUse:
            print("Location authorized when in use")
            lastKnownLocation = manager.location?.coordinate
            
        @unknown default:
            print("Location service disabled")
        
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first?.coordinate
    }
}

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State var positionView = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        )
    )
    
    var body: some View {
        VStack {
            if let coordinate = locationManager.lastKnownLocation {
                Text("Latitude: \(coordinate.latitude)")
                
                Text("Longitude: \(coordinate.longitude)")
                
                Map(
                    initialPosition: MapCameraPosition.region(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2DMake(
                                coordinate.latitude, coordinate.longitude
                            ),
                            span: MKCoordinateSpan(
                                latitudeDelta: 1,
                                longitudeDelta: 1
                            )
                        )
                    )
                )
            } else {
                Text("Unknown Location")
            }
            
            
            Button("Get location") {
                locationManager.checkLocationAuthorization()
            }
            
        }
        .padding()
        .onAppear {
            locationManager.checkLocationAuthorization()
            if let coordinate = locationManager.lastKnownLocation {
                let position = MapCameraPosition.region(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                    )
                )
                
                positionView = position
            }
        }
    }
}

#Preview {
    ContentView()
}
