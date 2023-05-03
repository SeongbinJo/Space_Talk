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
        
//        GeometryReader{ geo in
//            Text(message.msgText)
//            .padding(10)
//            .background{
//                GeometryReader{ geo1 in
//                    Text("")
//                        .onAppear{
//                            hight = geo1.size.height
//                        }
//                }
//            }
//            .cornerRadius(20, corners: .allCorners)
//            .fixedSize(horizontal: false, vertical: true)
//            .frame(maxWidth: .infinity)
//        }
//        .frame(height: self.hight)
        
        GeometryReader{ geometry in
            VStack{
                HStack(alignment: .bottom){
                    Text(message.formattedTime)
                        .font(.system(size: geometry.size.width * 0.03))
                        .frame(width: message.isMsgReceived ? 0 : geometry.size.width * 0.2)
                    Text(message.msgText)
                        .font(.system(size: geometry.size.width * 0.05))
                        .padding(7)
                        .background{
                            message.isMsgReceived ? Color.pink : Color.yellow
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
                        .frame(width: message.isMsgReceived ? geometry.size.width * 0.2 : 0)
                }
                .frame(maxWidth: geometry.size.width * 0.9, maxHeight: .infinity, alignment: message.isMsgReceived ? .leading : .trailing)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: message.isMsgReceived ? .leading : .trailing)
        }
        .frame(height: geoHeight)

    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubble(message: Messages(id: "123", msgText: "가나다라마바사아자차가나다라마바사아자차가나다라마바사아자차가나다라마바사아자차가나다라마바사아자차가나다라마바사아자차가나다라마바사아자차가나다라마바사아자차가나다라마바사아자차가나다라마바사아자차", isMsgReceived: false, timeStamp: Date()))
    }
}
