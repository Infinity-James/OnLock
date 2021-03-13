//
//  ContentView.swift
//  OnLock
//
//  Created by James Valaitis on 11/03/2021.
//

import SwiftUI

//  MARK: Content View
internal struct ContentView: View {
    var body: some View {
        Map()
			.edgesIgnoringSafeArea(.all)
    }
}

//  MARK: Previews
internal struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
