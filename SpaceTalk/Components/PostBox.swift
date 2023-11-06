//
//  PostBox.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/08/29.
//

import SwiftUI

struct PostBox: View {
    
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    
    @Binding var postBoxZIndex: Double
    
    var body: some View {
        GeometryReader{ geomtry in
            ZStack(alignment: .topTrailing){
                VStack{
                        Text("새로 온 무전")
                            .padding(.top, geomtry.size.height * 0.015)
                    ScrollView{
                        ForEach(firestoreViewModel.firstMessages, id: \.id){ firstMessage in
                            PostBoxList(firstMessage: firstMessage, width: geomtry.size.width * 0.8, height: geomtry.size.height * 0.1)
                        }
                    }
                }
                .frame(width: geomtry.size.width * 0.8)
                Button(action: {
                    postBoxZIndex = -2
                }){
                    Text("닫기")
                        .foregroundColor(.black)
                        .padding(.top, geomtry.size.height * 0.015)
                        .padding(.trailing, 5)
                }
            }
            .frame(width: geomtry.size.width * 0.85, height: geomtry.size.height * 0.5)
            .background(Color(UIColor(r: 94, g: 94, b: 94, a: 0.7)))
            .cornerRadius(20, corners: .allCorners)
            .position(x: geomtry.frame(in: .local).midX, y: geomtry.frame(in: .local).midY)
        }
        .onAppear{
        }
    }
}
