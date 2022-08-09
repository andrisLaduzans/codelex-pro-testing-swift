//
//  ContentView.swift
//  UnitTesting
//
//  Created by Andris Laduzans on 12/07/2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                List {
                    NavigationLink {
                        OhceUI()
                    } label: {
                        Text("Ohce").font(.headline)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    VStack {
                        Text("Unit testing mini projects").font(.title)
                        
                    }
                    
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
