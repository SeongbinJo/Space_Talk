//
//  ImagePage.swift
//  SpaceTalk
//
//  Created by 조성빈 on 10/22/23.
//


import Foundation
import SwiftUI

struct ImagePage: View {
    
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    
    @Binding var goToImagePage : Bool
    @Binding var selectedImage : UIImage
    
    var body: some View {
        NavigationView{
                Text("hi")
        }
        .onAppear{
            
        }
        .toolbarBackground(
                        Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)),
                        for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
//            self.chatListToChatPageActive = false
        }){
            HStack{
                Image(systemName: "chevron.left")
                Text("Back")
            }
        })
        
        
    }
}
