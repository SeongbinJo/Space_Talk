//
//  MessageBubble.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/04/27.
//

import SwiftUI

struct MessageBubble: View {

    var message: Messages
    
    @State var geoHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                HStack(alignment: .bottom){
                    Text(message.isRead ? " " : "1")
                        .foregroundColor(.yellow)
                    Text(message.formattedTime)
                        .font(.system(size: geometry.size.width * 0.03))
                    // 나중에 currentuser의 uid와 senderid/receiverid를 비교해서 width = 0으로 정함.
                        .frame(width: geometry.size.width * 0.2)
                    Text(message.messageText)
                        .font(.system(size: geometry.size.width * 0.04))
                        .padding(7)
                        .background{
                            Color.yellow
                            GeometryReader{ geo in
                                Text("")
                                    .onAppear{
                                        geoHeight = geo.size.height + 5
                                    }
                            }
                        }
                        .cornerRadius(5, corners: .allCorners)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(message.formattedTime)
                        .font(.system(size: geometry.size.width * 0.03))
                    // 나중에 currentuser의 uid와 senderid/receiverid를 비교해서 width = 0으로 정함.
                        .frame(width: 0)
                }
                // 나중에 currentuser의 uid와 senderid/receiverid를 비교해서 .trailing, .leading 정함.
                .frame(maxWidth: geometry.size.width * 0.9, maxHeight: .infinity, alignment: .trailing)
            }
            // 나중에 currentuser의 uid와 senderid/receiverid를 비교해서 .trailing, .leading 정함.
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        }
        .frame(height: geoHeight)
        
        
    }
}

//struct MessageBubble_Previews: PreviewProvider {
//    static var previews: some View {
////        MessageBubble(message: Messages(document: .data()))
//    }
//}
