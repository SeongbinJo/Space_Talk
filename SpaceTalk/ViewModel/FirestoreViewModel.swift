//
//  FirestoreViewModel.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/05/05.
//

import Combine
import Firebase
import FirebaseFirestore
import SwiftUI
import FirebaseFirestoreSwift

class FirestoreViewModel: ObservableObject{
    
    @ObservedObject var loginViewModel: LoginViewModel
    
    let db = Firestore.firestore()
    
    //HomePage의 무전기 속 텍스트필드 변수.
    @Published var firstSendText: String = ""
    //현재 유저의 닉네임이 담길 변수.
    @Published var currentNickName: String = ""
    @Published var receiverNickName: String = ""
    //채팅 방의 메시지 입력 텍스트필드 변수.
    @Published var sendMessageText: String = ""
    
    //firestore에서 가져올 데이터들을 담을 배열.
    //채팅방 안의 메시지들을 담을 배열 messages.
    @Published private(set) var messages: [Messages] = []
    //PUSH를 눌러 생성될 채팅방 데이터 담을 배열.
    @Published private(set) var pushButtonMessages: [PushButtonMessages] = []
    @Published private(set) var acceptButtonMessages: [PushButtonMessages] = []
    //무전기의 우편함에 첫 메시지 데이터들을 담을 배열 newmessages.
    @Published private(set) var newmessages: [Messages] = []
    
    
    init(loginViewModel: LoginViewModel) {
        self.loginViewModel = loginViewModel
//        getMessages()
        getFirstMessage()
        generateChatList()
    }
    
    //현재 유저의 닉네임 불러오는 함수.
    func currentUserNickName() -> String {
        db.collection("users").document(loginViewModel.currentUser!.uid).getDocument(){ snapshot, error in
            guard error == nil else {
                print("현재 유저 닉네임 조회 Error : \(error!)")
                return
            }
            self.currentNickName = snapshot?.get("nickname") as! String
        }
        return currentNickName
    }
    
    func receivernickname(nicknamecomplete: @escaping (String?) -> Void) -> String {
        db.collection("users").document("fa4QWpAbzqeWUUJbMZAqpo2OdRq1").getDocument(){ snapshot, error in
            guard error == nil else {
                print("현재 유저 닉네임 조회 Error : \(error!)")
                nicknamecomplete(nil)
                return
            }
            self.receiverNickName = snapshot?.get("nickname") as! String
            nicknamecomplete(self.receiverNickName)
        }
        return receiverNickName
    }
    
    ///////////////////////////////////////////////////메시지 관련/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //homepage의 무전기 PUSH버튼 함수.
    //해당 버튼으로 메시지를 전송하는 경우는 isFirstMsg필드가 true로 새로 추가되어 저장되어야한다.
    //Sender가 PUSH를 눌러 첫 메시지를 발송하면 채팅방도 같이 생성시킨다. (생성된 채팅방의 활성화 여부는 Receiver의 'O'버튼에 따라 달라지게끔.
    func sendFirstMessageInHomePage(completion: @escaping (Bool) -> Void){
        guard let currentUser = loginViewModel.currentUser?.uid else {
            print("현재 유저의 uid가 비어있습니다.")
            return
        }
    
        let chatDoc = db.collection("chatroom").document()
        let chatroomDoc = chatDoc.collection(chatDoc.documentID).document()
        //chatroom/roomid 의 필드 저장.(postbox 생성위함)
        //이때 firstSenderId 필드를 추가해서 sender가 PUSH눌렀을때 이 필드 값을 참조해서 뷰에 채팅방 추가되게끔.
        //isAvailable 필드도 추가해서 'o'눌렀을때 true로 바뀌고 이 값이 true 일 경우에 채팅 텍스트필드가 활성화 되게끔.
        
        receivernickname(){ receivernickname in
            guard let receivernickname = receivernickname else {
                print("상대방 닉네임 가져오기 실패.")
                return
            }
            chatDoc.setData(["roomId" : chatDoc.documentID, "messageId" : chatroomDoc.documentID, "messageText" : self.firstSendText, "sendTime" : Date(), "senderId" : currentUser, "receiverId" : "fa4QWpAbzqeWUUJbMZAqpo2OdRq1", "isRead" : false, "senderNickName" : self.currentUserNickName(), "receiverNickName" : receivernickname, "firstSenderId" : currentUser, "firstReceiverId" : "fa4QWpAbzqeWUUJbMZAqpo2OdRq1", "isAvailable" : false]){ error in
                if let error = error {
                    print("무전기 메시지 발송 에러1 : \(error)")
                    completion(false)
                }else{
                    print("무전기 메시지 발송 성공!")
                    completion(true)
                }
            }
            
            //chatroom/roomid/roomid/ 필드 저장.
            chatroomDoc.setData(["roomId" : chatDoc.documentID, "messageId" : chatroomDoc.documentID, "messageText" : self.firstSendText, "sendTime" : Date(), "senderId" : currentUser, "receiverId" : "fa4QWpAbzqeWUUJbMZAqpo2OdRq1", "isRead" : false]){ error in
                if let error = error {
                    print("무전기 메시지 발송 에러2 : \(error)")
                    completion(false)
                }else{
                    print("첫 메시지 저장완료.")
                    completion(true)
                }
            }
        }
        
        
        
    }
    
    func generateChatList(){
        guard let currentUser = loginViewModel.currentUser?.uid else {
            print("getFirstMessage() 에러 = currentUser.uid 가 비어있습니다.")
            return
        }
        //PUSH 버튼 누른 유저가 본인인 경우.
        db.collection("chatroom").whereField("firstSenderId", isEqualTo: currentUser).addSnapshotListener{ snapshot, error in
            guard error == nil else {
                print("generateChatList firestore 인덱싱 에러1 : \(String(describing: error))")
                return
            }
            guard let documents = snapshot?.documents else {
                print("generateChatList 에러1 : \(String(describing: error))")
                return
            }
            guard !documents.isEmpty else {
                print("푸시한 메시지가 없음.")
                self.pushButtonMessages.removeAll()
                return
            }
            //try? -> 에러가 발생하면 nil을 반환.
            for document in documents {
                if let newMessage = try? document.data(as: PushButtonMessages.self) {
                    self.pushButtonMessages.append(newMessage)
//                    print("푸시해서 추가된 메시지 배열 : \(self.pushButtonMessages)")
                }else{
                    print("123")
                }
            }
            
            //날짜가 최신이면 맨 위로.
            self.pushButtonMessages.sort { $0.sendTime > $1.sendTime }
            
        }
        
        //'O' 버튼 누른 유저가 본인인 경우.
        db.collection("chatroom").whereField("firstReceiverId", isEqualTo: currentUser).whereField("isAvailable", isEqualTo: true).addSnapshotListener{ snapshot, error in
            guard error == nil else {
                print("generateChatList firestore 인덱싱 에러2 : \(String(describing: error))")
                return
            }
            guard let documents = snapshot?.documents else {
                print("generateChatList 에러2 : \(String(describing: error))")
                return
            }
            guard !documents.isEmpty else {
                print("수락한 메시지가 없음.")
                self.acceptButtonMessages.removeAll()
                return
            }
            //try? -> 에러가 발생하면 nil을 반환.
            for document in documents {
                if let newMessage = try? document.data(as: PushButtonMessages.self) {
                    self.acceptButtonMessages.append(newMessage)
//                    print("수락해서 추가된 메시지 배열 : \(self.acceptButtonMessages)")
                }else{
                    print("123")
                }
            }
            
            //날짜가 최신이면 맨 위로.
            self.acceptButtonMessages.sort { $0.sendTime > $1.sendTime }
            
        }
    }
    
    //우편함에 새로운 메시지 보여주기 위해 배열에 데이터 저장하는 함수.
    func getFirstMessage(){
        guard let currentUser = loginViewModel.currentUser?.uid else {
            print("getFirstMessage() 에러 = currentUser.uid 가 비어있습니다.")
            return
        }
        //수신자가 본인이고, isAvailable('O' 버튼 누르기 전)이 false인 경우.
        db.collection("chatroom").whereField("receiverId", isEqualTo: currentUser).whereField("isAvailable", isEqualTo: false).addSnapshotListener{ snapshot, error in
            guard error == nil else {
                print("getFirstMessage firestore 인덱싱 에러 : \(String(describing: error))")
                return
            }
            guard let documents = snapshot?.documents else {
                print("getFirstMessage 에러2 : \(String(describing: error))")
                return
            }
            guard !documents.isEmpty else {
                print("신규 메시지가 없음.")
                self.newmessages.removeAll()
                return
            }
            //try? -> 에러가 발생하면 nil을 반환.
            for document in documents {
                if let newMessage = try? document.data(as: Messages.self) {
                    self.newmessages.append(newMessage)
                }else{
                    print("123")
                }
            }
            
            self.newmessages.sort { $0.sendTime < $1.sendTime }
            
        }
    }
    
    //수신자가 postbox에서 'o'버튼을 눌렀을경우.
    func acceptNewMessage(roomid: String){
        //해당 메시지 'O' 눌렀을 경우, isAvailable 값을 true로 변경. -> 채팅방 내 텍스트필드 활성화되게끔.
        self.db.collection("chatroom").document(roomid).updateData(["isAvailable" : true])
    }
    
    //수신자가 postbox에서 'X'버튼을 눌렀을경우.
    func refuseNewMessage(roomid: String){
        self.db.collection("chatroom").document(roomid).delete()
    }
    
//    //우편함에서 'O' 눌렀을 때, ChatListPage에 전달할 데이터 배열에 저장하는 함수.
//    func deliverNewMessageData(roomid: String, messageText: String, sendtime: Date, isread: Bool, senderid: String, receiverid: String, sendernickname: String, messageid: String){
//        let messageData = Messages(messageId: messageid, roomId: roomid, messageText: messageText, sendTime: sendtime, senderId: senderid, receiverId: receiverid, isRead: isread, senderNickName: sendernickname)
//        self.deliverMessageData.append(messageData)
//        print("이 타입은 뭘까요옹? \(type(of: self.deliverMessageData))")
//        print("내용은 뭘까요옹? \(self.deliverMessageData)")
//        print("내용의 개수는? \(self.deliverMessageData.count)")
////        print(self.deliverMessageData[0])
//    }
    
//    //우편함에서 'O'를 눌러 생성된 채팅방의 마지막 메시지를 구하는 함수.
//    func getLastMessage(roomid: String){
//        guard let currentUser = loginViewModel.currentUser?.uid else {
//            print("currentUser.uid 가 비어있습니다.")
//            return
//        }
//        let lastMessageDoc = db.collection("chatroom").document(roomid).collection(currentUser)
//        lastMessageDoc.order(by: "sendTime").limit(to: 1).addSnapshotListener{ snapshot, error in
//            guard error == nil else {
//                print("getLastMessage firestore 인덱싱 에러 : \(String(describing: error))")
//                return
//            }
//            guard let documents = snapshot?.documents else {
//                print("getLastMessage 에러2 : \(String(describing: error))")
//                return
//            }
//            guard !documents.isEmpty else {
//                print("생성할 채팅방 없음.")
////                self.chatListBoxMessages.removeAll()
//                return
//            }
//            for document in documents {
//                if let newChatList = try? document.data(as: Messages.self) {
//                    self.chatListBoxMessages.append(newChatList)
//                    print("생성될 chatList / 존재하는 마지막 메시지 : \(newChatList)")
//                }else{
//                    print("123")
//                }
//            }
//
//        }
//    }
    
    //메시지 전송 버튼시 firestore에 저장하는 함수.
    func writeMessageToFirestore(){
        guard let currentUser = loginViewModel.currentUser?.uid else {
            print("currentUser.uid 가 비어있습니다.")
            return
        }
        let chatroomDoc = db.collection("chatroom1").document("document1")
        let chatRoomDoc = chatroomDoc.collection("subcollection").document()
        chatRoomDoc.setData(["roomId" : "testroomid", "messageText" : self.sendMessageText, "sendTime" : Date(), "senderId" : currentUser, "receiverId" : "fa4QWpAbzqeWUUJbMZAqpo2OdRq1", "isRead" : false]){ err in
            if let err = err {
                print("메시지 전송 에러: \(err)")
            } else {
                print("메시지 성공적으로 저장완료!")
            }
        }
    }

//    func getMessages() {
//        //chatroom 콜렉션에서 현재 유저의 uid와 같은 senderId를 갖는 메시지들만 나타내기.
//        //appsnapshotListener를 사용해서 데이터에 업데이트가 있을시 바로바로 뷰에서 변경된다.
//        //지금은 senderId로 구분하지만, 나중에 roomId로 구분하게되면  roomId값으로 데이터들을 담은 후, senderId가 현재유저 uid와 동일하면 뷰 우측에, 아니면 좌측에 붙게 만들면 될 듯함.
//        guard let currentUser = loginViewModel.currentUser?.uid else {
//            print("getMessages() 에러 = currentUser.uid 가 비어있습니다.")
//            return
//        }
//        //룸id가 같은 데이터들을 전부다 불러와서 MessageBubble파일에서 senderId가 currentuser.uid인지에 따라 왼쪽 오른쪽 구분.!!
//        db.collection("chatroom").document("document1").collection("subcollection").whereField("roomId", isEqualTo: "testroomid").addSnapshotListener { snapshot, error in
//            guard error == nil else {
//                print("getMessages() firestore 인덱싱 에러 : \(String(describing: error))")
//                return
//            }
//            guard let documents = snapshot?.documents else {
//                print("getMessages() 에러2 : \(String(describing: error))")
//                return
//            }
//            guard !documents.isEmpty else {
//                print("메시지가 없음.")
//                self.messages.removeAll()
//                return
//            }
//            print("documents 타입 : \(type(of: documents))")
//            //messages 배열에 whereField로 걸러진 메시지 데이터들을 담는다.
//
//            for document in documents {
//                if let message = try? document.data(as: Messages.self) {
//                    self.messages.append(message)
//                }
//            }
//            self.messages.sort { $0.sendTime < $1.sendTime }
//
//
////            self.messages = documents.compactMap(){ document -> Messages? in
////                do{
////                    return try document.data(as: Messages.self)
////                }catch{
////                    return nil
////                }
////            }
////
////            self.messages.sort { $0.sendTime < $1.sendTime }
//
//        }
//    }
    
//    func sendFirstMessageInHomePage(completion: @escaping (Bool) -> Void){
//        guard let currentUser = loginViewModel.currentUser?.uid else {
//            print("현재 유저의 uid가 비어있습니다.")
//            return
//        }
//        let chatroomDoc = db.collection("chatroom").document()
//        let chatroomId = chatroomDoc.documentID
//        let roomDoc = chatroomDoc.collection("fa4QWpAbzqeWUUJbMZAqpo2OdRq1").document()
//        roomDoc.setData(["roomId" : chatroomId, "messageId" : roomDoc.documentID, "messageText" : self.firstSendText, "sendTime" : Date(), "senderId" : currentUser, "receiverId" : "fa4QWpAbzqeWUUJbMZAqpo2OdRq1", "isRead" : false, "isFirstMessage" : true, "senderNickName" : self.currentUserNickName()]){ error in
//            if let error = error {
//                print("무전기 메시지 발송 에러 : \(error)")
//                completion(false)
//            }else{
//                print("무전기 메시지 발송 성공!")
//                completion(true)
//            }
//        }
//    }
    
    
    //homepage의 무전기 버튼으로 첫 메시지를 발송하고 수신자 측에서 이를 캐치하여 우편함에 목록을 보여주는 함수.
//    func getFirstMessage(){
//        guard let currentUser = loginViewModel.currentUser?.uid else {
//            print("getFirstMessage() 에러 = currentUser.uid 가 비어있습니다.")
//            return
//        }
//        db.collection(currentUser).whereField("isFirstMessage", isEqualTo: true).addSnapshotListener{ snapshot, error in
//            guard error == nil else {
//                print("getFirstMessage 에러1 : \(String(describing: error))")
//                return
//            }
//            guard let documents = snapshot?.documents else {
//                print("getFirstMessage 에러2 : \(String(describing: error))")
//                return
//            }
//            guard !documents.isEmpty else {
//                print("신규 메시지가 없음.")
//                return
//            }
//            print(documents)
//            self.newmessages = documents.compactMap(){ document -> PostBoxMessages? in
//                do{
//                    return try document.data(as: PostBoxMessages.self)
//                }catch{
//                    return nil
//                }
//            }
//
//            self.newmessages.sort { $0.sendTime < $1.sendTime }
//
//        }
//    }
    
//    //메시지 전송 버튼시 firestore에 저장하는 함수.
//    func writeMessageToFirestore(){
//        guard let currentUser = loginViewModel.currentUser?.uid else {
//            print("currentUser.uid 가 비어있습니다.")
//            return
//        }
//        let chatroomDoc = db.collection("chatroom1").document("document1")
//        let chatRoomDoc = chatroomDoc.collection("subcollection").document()
//        chatRoomDoc.setData(["roomId" : "testroomid", "messageId" : chatRoomDoc.documentID, "messageText" : self.sendMessageText, "sendTime" : Date(), "senderId" : currentUser, "receiverId" : "fa4QWpAbzqeWUUJbMZAqpo2OdRq1", "isRead" : false]){ err in
//            if let err = err {
//                print("메시지 전송 에러: \(err)")
//            } else {
//                print("메시지 성공적으로 저장완료!")
//            }
//        }
//    }
//
//    func getMessages() {
//        //chatroom 콜렉션에서 현재 유저의 uid와 같은 senderId를 갖는 메시지들만 나타내기.
//        //appsnapshotListener를 사용해서 데이터에 업데이트가 있을시 바로바로 뷰에서 변경된다.
//        //지금은 senderId로 구분하지만, 나중에 roomId로 구분하게되면  roomId값으로 데이터들을 담은 후, senderId가 현재유저 uid와 동일하면 뷰 우측에, 아니면 좌측에 붙게 만들면 될 듯함.
//        guard let currentUser = loginViewModel.currentUser?.uid else {
//            print("getMessages() 에러 = currentUser.uid 가 비어있습니다.")
//            return
//        }
//        //룸id가 같은 데이터들을 전부다 불러와서 MessageBubble파일에서 senderId가 currentuser.uid인지에 따라 왼쪽 오른쪽 구분.!!
//        db.collection("chatroom1").document("document1").collection("subcollection").whereField("roomId", isEqualTo: "testroomid").addSnapshotListener { snapshot, error in
//            guard error == nil else {
//                print("getMessages() 에러1 : \(String(describing: error))")
//                return
//            }
//            guard let documents = snapshot?.documents else {
//                print("getMessages() 에러2 : \(String(describing: error))")
//                return
//            }
//            guard !documents.isEmpty else {
//                print("메시지가 없음.")
//                return
//            }
//            print("메시지 개수 : \(documents.count)")
//            //messages 배열에 whereField로 걸러진 메시지 데이터들을 담는다.
//            self.messages = documents.compactMap(){ document -> Messages? in
//                do{
//                    return try document.data(as: Messages.self)
//                }catch{
//                    return nil
//                }
//            }
//
//            self.messages.sort { $0.sendTime < $1.sendTime }
//
//        }
//    }
    
    
//    //임의의 유저간 메시지 통신 성공한 코드.
    
//    //메시지 전송 버튼시 firestore에 저장하는 함수.
//    func writeMessageToFirestore(){
//        guard let currentUser = loginViewModel.currentUser?.uid else {
//            print("currentUser.uid 가 비어있습니다.")
//            return
//        }
//        let chatroomDoc = db.collection("chatroom1").document("document1")
//        let chatRoomDoc = chatroomDoc.collection("subcollection").document()
//        chatRoomDoc.setData(["roomId" : "testroomid", "messageId" : chatRoomDoc.documentID, "messageText" : self.sendMessageText, "sendTime" : Date(), "senderId" : currentUser, "receiverId" : "fa4QWpAbzqeWUUJbMZAqpo2OdRq1", "isRead" : false]){ err in
//            if let err = err {
//                print("메시지 전송 에러: \(err)")
//            } else {
//                print("메시지 성공적으로 저장완료!")
//                //메시지를 저장하고 저장된 메시지를 가져와야함.
//            }
//        }
//    }
//
//    func getMessages() {
//        //chatroom 콜렉션에서 현재 유저의 uid와 같은 senderId를 갖는 메시지들만 나타내기.
//        //appsnapshotListener를 사용해서 데이터에 업데이트가 있을시 바로바로 뷰에서 변경된다.
//        //지금은 senderId로 구분하지만, 나중에 roomId로 구분하게되면  roomId값으로 데이터들을 담은 후, senderId가 현재유저 uid와 동일하면 뷰 우측에, 아니면 좌측에 붙게 만들면 될 듯함.
//        guard let currentUser = loginViewModel.currentUser?.uid else {
//            print("getMessages() 에러 = currentUser.uid 가 비어있습니다.")
//            return
//        }
//        //룸id가 같은 데이터들을 전부다 불러와서 MessageBubble파일에서 senderId가 currentuser.uid인지에 따라 왼쪽 오른쪽 구분.!!
//        db.collection("chatroom1").document("document1").collection("subcollection").whereField("roomId", isEqualTo: "testroomid").addSnapshotListener { snapshot, error in
//            guard error == nil else {
//                print("에러다! 에러!!11 : \(String(describing: error))")
//                return
//            }
//            guard let documents = snapshot?.documents else {
//                print("에러다! 에러!!22 : \(String(describing: error))")
//                return
//            }
//            guard !documents.isEmpty else {
//                print("메시지가 없음.")
//                return
//            }
//            print("메시지 개수 : \(documents.count)")
//            //messages 배열에 whereField로 걸러진 메시지 데이터들을 담는다.
//            self.messages = documents.compactMap(){ document -> Messages? in
//                do{
//                    return try document.data(as: Messages.self)
//                }catch{
//                    return nil
//                }
//            }
//
//            self.messages.sort { $0.sendTime < $1.sendTime }
//
//        }
//    }
    
    //메시지 삭제 -> ex) 방 나가기, 신고 및 차단, 계정 삭제 등
//    func deleteMessage() {
//        db.collection("chatroom").whereField("senderId", isEqualTo: loginViewModel.currentUser!.uid)
//    }
    func deleteMessagesFromFirestore() {

        self.messages.removeAll()
    }
    
    ///////////////////////////////////////////////////메시지 관련/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}

//
//func getMessages() {
//    db.collection("chatroom").whereField("senderId", isEqualTo: loginViewModel.currentUser!.uid).addSnapshotListener { snapshot, error in
//        guard error == nil else {
//            print("에러다! 에러!!11 : \(String(describing: error))")
//            return
//        }
//        guard let documents = snapshot?.documents else {
//            print("에러다! 에러!!22 : \(String(describing: error))")
//            return
//        }
//        guard !documents.isEmpty else {
//            print("메시지가 없음.")
//            return
//        }
//        self.messages = documents.compactMap(){ document -> Messages? in
//            do{
//                return try document.data(as: Messages.self)
//            }catch{
//                return nil
//            }
//        }
//    }
//}
