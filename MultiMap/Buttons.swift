//
//  Buttons.swift
//  MultiMap
//
//  Created by Brian Balthazor on 7/24/23.
//

import SwiftUI
import MapKit


struct Buttons: View {
    @ObservedObject var locationsHandler = LocationsHandler.shared

    @Binding var position: MapCameraPosition
    @Binding var searchResults: [MKMapItem]
    
    var visibleRegion: MKCoordinateRegion?

    var body: some View {
        HStack {
            Button {
                search(for: "playground")
            } label: {
                Label("Playgrounds", systemImage: "figure.and.child.holdinghands")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                search(for: "beach")
            } label: {
                Label("Beaches", systemImage: "beach.umbrella")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                let location = locationsHandler.manager.location
                guard let latitude = location?.coordinate.latitude else { return }
                guard let longitude = location?.coordinate.longitude else { return }

                let central = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    )

                position = .region(central)
            } label: {
                Label("Central", systemImage: "plus.magnifyingglass")
            }
            .buttonStyle(.bordered)
            
            Button {
                let location = locationsHandler.manager.location
                guard let latitude = location?.coordinate.latitude else { return }
                guard let longitude = location?.coordinate.longitude else { return }

                let wide = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
                    )

                position = .region(wide)
            } label: {
                Label("Wide", systemImage: "minus.magnifyingglass")
            }
            .buttonStyle(.bordered)
            
        }
        .labelStyle(.iconOnly)
    }
        
    func search(for query: String) {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        
        guard let region = visibleRegion else { return }
        request.region = region
        
        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            searchResults = response?.mapItems ?? []
        }
    }
    
}
