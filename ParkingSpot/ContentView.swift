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
    @State private var latitudSave = UserDefaults.standard.double(forKey: "latitudSave")
    @State private var longitudSave = UserDefaults.standard.double(forKey: "longitudSave")
    @State var locationAdded = UserDefaults.standard.bool(forKey: "Added")
    
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
    
    @State var location = [
        Location(
            name: "Car",
            location: CLLocationCoordinate2D(
                latitude: 0,
                longitude: 0
            )
        )
    ]
    
    var body: some View {
        NavigationView {
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
                    withAnimation {
                        locationManager.checkLocationAuthorization()
                        positionView.center = locationManager.lastKnownLocation ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
                        positionView.span.latitudeDelta = 0.01
                        positionView.span.longitudeDelta = 0.01
                    }
                }
                
                Button("Place Car Location") {
                    location[0] = Location(
                        name: "Car",
                        location: CLLocationCoordinate2D(
                            latitude: positionView.center.latitude,
                            longitude: positionView.center.longitude
                        )
                    )
                    latitudSave = positionView.center.latitude
                    longitudSave = positionView.center.longitude
                    
                    UserDefaults.standard.set(latitudSave, forKey: "latitudSave")
                    UserDefaults.standard.set(longitudSave, forKey: "longitudSave")
                    locationAdded.toggle()
                    UserDefaults.standard.set(locationAdded, forKey: "Added")
                }
            }.toolbar {
                Button {
                    if locationAdded {
                        withAnimation {
                            positionView.center.latitude = latitudSave
                            positionView.center.longitude = longitudSave
                            positionView.span.latitudeDelta = 0.01
                            positionView.span.longitudeDelta = 0.01
                        }
                    }
                } label: {
                    Image(systemName: "car.fill")
                }.disabled((locationAdded) ? false : true)
            }
            .navigationTitle("Parking Spot")
            .navigationBarTitleDisplayMode(.inline)
        }
        .padding()
        .onAppear {
            locationManager.checkLocationAuthorization()
            if let coordinate = locationManager.lastKnownLocation {
                let position = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    ),
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.01,
                        longitudeDelta: 0.01
                    )
                )
                
                positionView = position
            }
            
            if UserDefaults.standard.bool(forKey: "Added") == true {
                location[0] = Location(
                    name: "Car",
                    location: CLLocationCoordinate2D(
                        latitude: latitudSave,
                        longitude: longitudSave
                    )
                )
                
                Map(
                    coordinateRegion: $positionView,
                    annotationItems: location
                ) { location in
                    MapAnnotation(coordinate: location.location) {
                        Image(systemName: "car.fill")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
