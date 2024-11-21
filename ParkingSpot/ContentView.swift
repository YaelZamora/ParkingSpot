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

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let location: CLLocationCoordinate2D
}

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State var positionView = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 0,
            longitude: 0
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.01,
            longitudeDelta: 0.01
        )
    )
    
    @State var location = [Location]()
    
    var body: some View {
        VStack {
            if let coordinate = locationManager.lastKnownLocation {
                Map(
                    coordinateRegion: $positionView,
                    annotationItems: location
                ) { location in
                    MapAnnotation(coordinate: location.location) {
                        Image(systemName: "car.fill")
                    }
                }
            } else {
                Text("Unknown Location")
            }
            
            
            Button("Get location") {
                locationManager.checkLocationAuthorization()
                positionView.center = locationManager.lastKnownLocation ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
            }
            
            Button("Place Car Location") {
                location.append(
                    Location(
                        name: "Car",
                        location: CLLocationCoordinate2D(
                            latitude: positionView.center.latitude,
                            longitude: positionView.center.longitude
                        )
                    )
                )
            }
            
        }
        .padding()
        .onAppear {
            locationManager.checkLocationAuthorization()
            if let coordinate = locationManager.lastKnownLocation {
                let position = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude),
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.01,
                        longitudeDelta: 0.01
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
