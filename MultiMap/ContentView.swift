//
//  ContentView.swift
//  MultiMap
//
//  Created by Brian Balthazor on 7/24/23.
//

import os
import SwiftUI
import MapKit


@MainActor class LocationsHandler: ObservableObject {
    
    static let shared = LocationsHandler()
    public let manager: CLLocationManager

    init() {
        self.manager = CLLocationManager()
        if self.manager.authorizationStatus == .notDetermined {
            self.manager.requestWhenInUseAuthorization()
        }
    }
}

struct ContentView: View {
    let logger = Logger(subsystem: "net.appsird.multimap", category: "Demo")
    @ObservedObject var locationsHandler = LocationsHandler.shared

    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedResult: MKMapItem?
    @State private var route: MKRoute?
    
    
    var body: some View {
        
        Map(position: $position, selection: $selectedResult){
                        
            ForEach(searchResults, id: \.self) {result in
                Marker(item: result)
            }
            .annotationTitles(.hidden)
            
            if let route {
                MapPolyline(route)
                    .stroke(.blue, lineWidth: 5)
            }

            UserAnnotation()
        }
        .mapStyle(.standard(elevation: .realistic))
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                VStack(spacing:0) {
                    if let selectedResult {
                        ItemInfoView(selectedResult: selectedResult, route: route)
                            .frame(height: 128)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding([.top, .horizontal])
                    }
                    Buttons(position: $position, searchResults: $searchResults, visibleRegion: visibleRegion)
                        .padding(.top)
                }
                Spacer()
            }
            .background(.thinMaterial)
        }
        .onChange(of: searchResults) {
            withAnimation{
                position = .automatic
           }
        }
        .onChange(of: selectedResult) {
            getDirections()
        }
        .onMapCameraChange { context in
            visibleRegion = context.region
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
    }
    
    func getDirections() {
        route = nil
        guard let selectedResult else { return }
        
        let location = locationsHandler.manager.location
        guard let coordinate = location?.coordinate else { return }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        request.destination = selectedResult
        
        Task {
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            route = response?.routes.first
        }
    }
}


#Preview {
    ContentView()
}
