//
//  BeantownButtons.swift
//  MultiMap
//
//  Created by Brian Balthazor on 7/24/23.
//

import SwiftUI
import MapKit


struct BeantownButtons: View {
    
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
                position = .region(.central)
            } label: {
                Label("Central", systemImage: "beach.umbrella")
            }
            .buttonStyle(.bordered)
            
            Button {
                position = .region(.wide)
            } label: {
                Label("Wide", systemImage: "beach.umbrella")
            }
            .buttonStyle(.bordered)
            
        }
        .labelStyle(.iconOnly)
    }
        
    func search(for query: String) {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = visibleRegion ?? MKCoordinateRegion(
            center: .parking,
            span: MKCoordinateSpan(latitudeDelta: 0.000005, longitudeDelta: 0.000005))
        
        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            searchResults = response?.mapItems ?? []
        }
    }
    
}
