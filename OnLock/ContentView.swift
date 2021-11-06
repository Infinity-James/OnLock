//
//  ContentView.swift
//  OnLock
//
//  Created by James Valaitis on 11/03/2021.
//

import SwiftUI

private enum Constants {
    static let whiteColor = UIColor(red: 240/255, green: 246/255, blue: 246/255, alpha: 1)
    static let blueColor = UIColor(red: 8/255, green: 75/255, blue: 131/255, alpha: 1)
    static let lightBlueColor = UIColor(red: 1/255, green: 186/255, blue: 239/255, alpha: 1)
    
    static let buttonWidth: CGFloat = 50
}


//  MARK: Content View
internal struct ContentView: View {
    @State var showMenu = false
    let menuWidth: CGFloat = UIScreen.main.bounds.width / 4
    
    var menuImageName: String {
        showMenu ? "list.bullet.circle.fill" : "list.bullet.circle"
    }
    
    
    var body: some View {
        ZStack {
            Map()
                .ignoresSafeArea(.all)
            
            GeometryReader { proxy in
                HStack {
                    menu
                    
                    VStack {
                        Button(action: {
                            showMenu.toggle()
                        }, label: {
                            Image(systemName: menuImageName )
                                .resizable()
                                .frame(width: Constants.buttonWidth,
                                       height: Constants.buttonWidth)
                        })
                            .foregroundColor(Color(Constants.blueColor))
                            .padding(.all, 4)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                }
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .offset(x: showMenu ? 0 : -menuWidth)
            .animation(.default)
        }
    }
    
    var menu: some View {
        VStack {
            
            
        }
        .frame(width: menuWidth,
               height: UIScreen.main.bounds.height)
        .background(Color(Constants.blueColor))
        .padding(.trailing, 6)
        .background(Color(Constants.whiteColor))
        .ignoresSafeArea(.all)
    }
}

//  MARK: Previews
internal struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
