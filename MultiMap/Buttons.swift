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
            .buttonStyle(.bordered)
            
            Button {
                search(for: "beach")
            } label: {
                Label("Beaches", systemImage: "beach.umbrella")
            }
            .buttonStyle(.bordered)
                   
            Button {
                searchResults = []
            } label: {
                Label("Trash", systemImage: "trash")
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
