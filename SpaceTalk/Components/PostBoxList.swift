//
//  PostBoxList.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/08/29.
//

import SwiftUI

struct PostBoxList: View {
    
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    
    var firstMessage: PushButtonMessages
    
    @State var width: CGFloat
    @State var height: CGFloat
    
    var body: some View {
            VStack{
                HStack{
                    Text("\(firstMessage.firstSenderNickname)님의 무전 : \(firstMessage.messageText)")
                        .padding(.horizontal, 10)
                    Spacer()
                    Button(action: {
                        //'O' 버튼 눌렀을때, 해당 메시지를 따로 저장후 해당 위치에 후에 쌓일 메시지들 저장.(해당 수신,발신자)
                        firestoreViewModel.acceptFirstMessage(roomid: firstMessage.roomId)
                    }){
                        Text("O")
                            .foregroundColor(.black)
                    }
                    Button(action: {
                        firestoreViewModel.refuseFirstMessage(roomid: firstMessage.roomId, messageid: firstMessage.messageId)
                    }){
                        Text("X")
                            .foregroundColor(.black)
                    }
                    .padding(.trailing, 10)
                }
                .frame(width: width, height: height)
                .background(Color(UIColor(r: 132, g: 141, b: 136, a: 1.0)))
                .cornerRadius(15, corners: .allCorners)
            }
        }
    }
