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
    //수신자가 'O'를 눌러 생성될 채팅방 데이터 담을 배열.
    @Published private(set) var acceptButtonMessages: [PushButtonMessages] = []
    //무전기의 우편함에 첫 메시지 데이터들을 담을 배열 newmessages.
    @Published private(set) var newmessages: [Messages] = []
    
    //랜덤유저를 뽑기위해
    @Published var userCount = 0
    @Published var randomUserUid = ""
    @Published var myUserNumber = 0
    
    //'나가기' 버튼 눌렀을때 해당 방 메시지들의 id를 담기위한 배열. 이 배열의 요소들로 문서를 찾아 삭제한다.
    //꽤나 많은 비용이 들 수 있지만 firestore에서는 하위 컬렉션을 한번에 지우는 기능이 존재하지 않는다. ㅅㅂ;
    var deleteChatRoomId: [String] = []
    
    //'나가기' 버튼을 누른 채팅방의 firstSenderId를 가져오기위한 변수.
    @Published var firstSenderId: String = ""
    //'나가기' 버튼을 누른 채팅방의 isExit의 값을 가져오기위한 변수.
    @Published var isExit: Bool = false

    //클릭한 채팅방의 roomid -> 해당 채팅 메시지 불러오기위함.
    @Published var selectChatRoomId: String = "testid123"

    init(loginViewModel: LoginViewModel) {
        self.loginViewModel = loginViewModel
        getMessages()
        getFirstMessage()
        generateChatList()
    }


    //현재 유저의 닉네임 불러오는 함수.
    func currentUserNickName() -> String {
        guard let currentuser = loginViewModel.currentUser?.uid else { return "" }
        db.collection("users").document(currentuser).getDocument(){ snapshot, error in
            guard error == nil else {
                print("현재 유저 닉네임 조회 Error : \(error!)")
                return
            }
            self.currentNickName = snapshot?.get("nickname") as? String ?? "정보가 없음"
        }
        return currentNickName
    }


    ///////////////////////////////////////////////////메시지 관련/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///
    
    //homepage의 무전기 PUSH버튼 눌렀을때 상대방 지정 후, 상대방의 닉네임 구해주는 함수.
    func firstMessageReceiverNickName(completion: @escaping (Bool) -> Void){
        db.collection("users").document(self.randomUserUid).getDocument(){  snapshot, error in
            guard error == nil else {
                print("상대방 닉네임 조회 Error : \(error!)")
                completion(false)
                return
            }
            self.receiverNickName = snapshot?.get("nickname") as! String
            completion(true)
        }
    }
    
    //homepage의 무전기 PUSH버튼 함수.
    //해당 버튼으로 메시지를 전송하는 경우는 isFirstMsg필드가 true로 새로 추가되어 저장되어야한다.
    //Sender가 PUSH를 눌러 첫 메시지를 발송하면 채팅방도 같이 생성시킨다. (생성된 채팅방의 활성화 여부는 Receiver의 'O'버튼에 따라 달라지게끔.
    func sendFirstMessageInHomePage(completion: @escaping (Bool) -> Void){
        firstMessageReceiverNickName(){ complete in
            if complete{
                guard let currentUser = self.loginViewModel.currentUser?.uid else {
                    print("현재 유저의 uid가 비어있습니다.")
                    return
                }
                let chatDoc = self.db.collection("chatroom").document()
                let chatroomDoc = chatDoc.collection(chatDoc.documentID).document()
                //chatroom/roomid 의 필드 저장.(postbox 생성위함)
                //이때 firstSenderId 필드를 추가해서 sender가 PUSH눌렀을때 이 필드 값을 참조해서 뷰에 채팅방 추가되게끔.
                //isAvailable 필드도 추가해서 'o'눌렀을때 true로 바뀌고 이 값이 true 일 경우에 채팅 텍스트필드가 활성화 되게끔.
                chatDoc.setData(["roomId" : chatDoc.documentID, "messageId" : chatroomDoc.documentID, "messageText" : self.firstSendText, "sendTime" : Date(), "senderId" : currentUser, "receiverId" : self.randomUserUid, "isRead" : false, "senderNickName" : self.currentUserNickName(), "receiverNickName" : self.receiverNickName, "firstSenderId" : currentUser, "firstReceiverId" : self.randomUserUid, "isAvailable" : false, "isExit" : false]){ error in
                    if let error = error {
                        print("무전기 메시지 발송 에러1 : \(error)")
                        completion(false)
                    }else{
                        print("무전기 메시지 발송 성공!")
                        completion(true)
                    }
                }

                //chatroom/roomid/roomid/ 필드 저장.
                chatroomDoc.setData(["roomId" : chatDoc.documentID, "messageId" : chatroomDoc.documentID, "messageText" : self.firstSendText, "sendTime" : Date(), "senderId" : currentUser, "receiverId" : self.randomUserUid, "isRead" : false, "senderNickName" : self.currentUserNickName()]){ error in
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
            guard let documents = snapshot?.documents  else {
                print("generateChatList 에러1 : \(String(describing: error))")
                return
            }
            guard !documents.isEmpty else {
                self.pushButtonMessages.removeAll()
                return
            }
            
            self.pushButtonMessages = documents.compactMap(){ document -> PushButtonMessages? in
                PushButtonMessages(dictionaryData: document.data())
            }
            
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
                self.acceptButtonMessages.removeAll()
                return
            }

            //데이터가 nil값인 데이터를 걸러주고 PushButtonMessages로 타입 변환 후 배열에 추가한다.
            self.acceptButtonMessages = documents.compactMap(){ document -> PushButtonMessages? in
                PushButtonMessages(dictionaryData: document.data())
            }

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
                self.newmessages.removeAll()
                return
            }

            self.newmessages = documents.compactMap(){ document -> Messages? in
                Messages(dictionaryData: document.data())
            }

            self.newmessages.sort { $0.sendTime < $1.sendTime }
            print("첫 메시지 불러오기 완료.")
        }
    }

    //수신자가 postbox에서 'o'버튼을 눌렀을경우.
    func acceptNewMessage(roomid: String){
        //해당 메시지 'O' 눌렀을 경우, isAvailable 값을 true로 변경. -> 채팅방 내 텍스트필드 활성화되게끔.
        self.db.collection("chatroom").document(roomid).updateData(["isAvailable" : true])
    }

    //수신자가 postbox에서 'X'버튼을 눌렀을경우.
    func refuseNewMessage(roomid: String, messageid: String){
        self.db.collection("chatroom").document(roomid).collection(roomid).document(messageid).delete()
        self.db.collection("chatroom").document(roomid).delete()
    }


    //메시지 전송 버튼시 firestore에 저장하는 함수.
    func writeMessageToFirestore(){
        guard let currentUser = loginViewModel.currentUser?.uid else {
            print("currentUser.uid 가 비어있습니다.")
            return
        }
        
        //chatroom/roomid/roomid 에 전체 메시지 저장.
        let chatRoomDoc = db.collection("chatroom").document(self.selectChatRoomId).collection(self.selectChatRoomId).document()
        chatRoomDoc.setData(["roomId" : self.selectChatRoomId, "messageText" : self.sendMessageText, "sendTime" : Date(), "senderId" : currentUser, "receiverId" : self.randomUserUid, "isRead" : false, "messageId" : chatRoomDoc.documentID, "senderNickName" : self.currentUserNickName()]){ err in
            if let err = err {
                print("메시지 전송 에러: \(err)")
            } else {
                print("메시지 성공적으로 저장완료!")
                print("현재 메시지를 보낸 채팅방의 roomid : \(self.selectChatRoomId)")
            }
        }
        
        //chatroom/roomid 에 최신 메시지 업데이트.
        let lastMessageDoc = db.collection("chatroom").document(self.selectChatRoomId)
        lastMessageDoc.updateData(["messageId" : chatRoomDoc.documentID, "messageText" : self.sendMessageText, "sendTime" : Date(), "senderId" : currentUser, "receiverId" : self.randomUserUid, "isRead" : false])
    }
    
    func selectRoomIdSave(roomid: String, completion: @escaping (Bool) -> Void){
        guard let currentUser = loginViewModel.currentUser?.uid else {
            print("currentUser.uid 가 비어있습니다.")
            completion(false)
            return
        }
        let userDoc = db.collection("users").document(currentUser)
        userDoc.updateData(["selectChatRoomId" : roomid])
        completion(true)
    }
    
    func loadSelectRoomId(completion: @escaping (Bool) -> Void){
        guard let currentUser = loginViewModel.currentUser?.uid else {
            print("currentUser.uid 가 비어있습니다.")
            completion(false)
            return
        }
        db.collection("users").document(currentUser).getDocument(){ snapshot, error in
            guard error == nil else {
                print("Error : \(error!)")
                return
            }
            self.selectChatRoomId = snapshot?.get("selectChatRoomId") as? String ?? "정보없음"
            completion(true)
        }
    }

    func getMessages(){
        //chatroom 콜렉션에서 현재 유저의 uid와 같은 senderId를 갖는 메시지들만 나타내기.
        //appsnapshotListener를 사용해서 데이터에 업데이트가 있을시 바로바로 뷰에서 변경된다.
        //지금은 senderId로 구분하지만, 나중에 roomId로 구분하게되면  roomId값으로 데이터들을 담은 후, senderId가 현재유저 uid와 동일하면 뷰 우측에, 아니면 좌측에 붙게 만들면 될 듯함.
        //룸id가 같은 데이터들을 전부다 불러와서 MessageBubble파일에서 senderId가 currentuser.uid인지에 따라 왼쪽 오른쪽 구분.!!
        loadSelectRoomId(){ completion in
            if completion{
                self.db.collection("chatroom").document(self.selectChatRoomId).collection(self.selectChatRoomId).addSnapshotListener { snapshot, error in
                    guard error == nil else {
                        print("getMessages() firestore 인덱싱 에러 : \(String(describing: error))")
                        return
                    }
                    guard let documents = snapshot?.documents else {
                        print("getMessages() 에러2 : \(String(describing: error))")
                        return
                    }
                    guard !(documents.isEmpty) else {
                        self.messages.removeAll()
                        return
                    }
                    self.messages = documents.compactMap(){ document -> Messages? in
                        Messages(dictionaryData: document.data())
                    }
                    self.messages.sort { $0.sendTime < $1.sendTime }
                }
            }
        }
    }

    func exitChatRoom(){
        guard let currentUser = loginViewModel.currentUser?.uid else {
            print("currentUser.uid 가 비어있습니다.")
            return
        }
        getDeleteChatRoomMessageId(){ complete in
            if complete{
                guard self.deleteChatRoomId.count > 0 else {return}
                //채팅방 안의 메시지들을 삭제하는 부분.
                for i in 0...self.deleteChatRoomId.count-1{
                    self.db.collection("chatroom").document(self.selectChatRoomId).collection(self.selectChatRoomId).document(self.deleteChatRoomId[i]).delete()
                }
                //배열을 비워줌 -> 다른 채팅방을 나갈때 해당 채팅방의 메시지 id들을 담아야하기 때문.
                self.deleteChatRoomId.removeAll()
                //가져온 firstSenderId와 본인의 uid를 비교함. 참/거짓에 따라서 firstSenderId/firstReceiverId의 값을 nil로 바꿔준다.
                self.getFirstSenderId{ complete in
                    if complete{
                        //현재 uid와 삭제할 채팅방의 firstSenderId와 같다면.
                        if currentUser == self.firstSenderId{
                            //firstSenderId를 nil로 수정하여 채팅방 목록에 나오지 않도록 한다.
                            self.db.collection("chatroom").document(self.selectChatRoomId).updateData(["firstSenderId" : "nil"])
                        }else{
                            //현재 uid와 삭제할 채팅방의 firstSenderId가 아닌 firstReceiverId와 같다면 -> firstReceiverId를 nil로 수정해서 채팅방 목록에서 안 보이도록 한다.
                            self.db.collection("chatroom").document(self.selectChatRoomId).updateData(["firstReceiverId" : "nil"])
                        }
                        //채팅방 안의 메시지들을 전부 삭제한 후에 최신 메시지 데이터에 'isExit'라는 필드의 값을 true로 바꿔놓는다. (이 필드의 값이 true일 경우 상대방이 해당 채팅방을 클릭했을 경우에 Alert창이 나오면서 채팅방 목록이 삭제된다.
                        self.db.collection("chatroom").document(self.selectChatRoomId).updateData(["isExit" : true])
                    }
                }
            }
        }
    }
    
    func deleteChatRoom(){
        //채팅방의 최신 메시지를 삭제하는 부분.(이 부분으로 채팅방 목록을 불러오기 때문에 채팅방 목록을 지우는 것과 같다.)
        self.db.collection("chatroom").document(self.selectChatRoomId).delete()
    }
    
    func isExitBool(complete: @escaping (Bool) -> Void){
        self.db.collection("chatroom").document(self.selectChatRoomId).getDocument{ snapshot, error in
            guard error == nil else {
                complete(false)
                return
            }
            guard snapshot?.data() != nil else {
                print("isExit값이 존재하지 않습니다. isExit : \(snapshot?.data())")
                print("클릭한 채팅방의 roomid : \(self.selectChatRoomId)")
                complete(false)
                return
            }
            self.isExit = snapshot?.data()!["isExit"] as! Bool
            print("isExitBool의 실행후 isExit 값은 : \(self.isExit)")
            complete(true)
        }
    }
    
    
    //삭제할 방의 firstSenderId를 담는 함수.
    //firstSenderId를 가져와 '나가기' 버튼을 눌렀을때 본인의 uid와 비교해서 참일 경우 firstSenderId를 nil로 바꿔주고, 거짓일 경우 firstReceiverId를 nil로 바꿔준다.
    func getFirstSenderId(complete: @escaping (Bool) -> Void){
        self.db.collection("chatroom").document(self.selectChatRoomId).getDocument{ snapshot, error in
            guard error == nil else {
                complete(false)
                return
            }
            guard snapshot != nil else {
                complete(false)
                return
            }
            self.firstSenderId = snapshot?.data()!["firstSenderId"] as! String
            complete(true)
        }
    }
    
    func getDeleteChatRoomMessageId(complete: @escaping (Bool) -> Void){
        db.collection("chatroom").document(self.selectChatRoomId).collection(self.selectChatRoomId).getDocuments{ snapshot, error in
            guard error == nil else {
                complete(false)
                return}
            guard snapshot != nil else {
                complete(false)
                return
            }
            guard let documents = snapshot?.documents else {
                complete(false)
                return
            }
            for document in documents{
                self.deleteChatRoomId.append(document.data()["messageId"] as! String)
            }
            complete(true)
        }
    }

    //랜덤으로 유저 uid 뽑기
    func randomUser(complete1: @escaping (Bool) -> Void){
        self.loginViewModel.getMaxUserCount(){ complete in
            if complete{
                    //0~총 유저수 중 랜덤숫자.
                    self.userCount = Int.random(in: 1...self.loginViewModel.maxUserNumber)
                print("랜덤으로 뽑은 유저넘버 : \(self.userCount)")
                    //내 userNumber 가져오기.
                    self.getMyUserNumber(){ completion in
                        if completion{
                            //내 userNumber와 랜덤으로 뽑은 숫자와 비교. -> 같으면 다시 뽑아야함.
                            if self.myUserNumber == self.userCount{
                                print("랜덤으로 뽑은 userNumber와 나의 userNumber가 같습니다. 번호를 다시 뽑습니다.")
                                self.randomUser(complete1: complete1)
                            }else{
                                print("랜덤으로 뽑은 userNumber와 나의 userNumber가 다릅니다. 뽑은 userNumber의 Uid를 가져옵니다.")
                                //랜덤으로 뽑은 userNumber의 uid 가져오기.
                                self.getRandomUid(){ useruid in
                                    self.randomUserUid = useruid
                                    if(self.randomUserUid == "nil"){
                                        self.randomUser(complete1: complete1)
                                    }else{
                                        complete1(true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

    
    func getMyUserNumber(completion: @escaping (Bool) -> Void){
        guard let currentUser = self.loginViewModel.currentUser?.uid else {
                            print("현재 유저의 uid가 비어있습니다.")
                            return
                        }
        db.collection("users").whereField("uid", isEqualTo: currentUser).getDocuments{ snapshot, error in
            if error != nil{
                print("내 유저넘버 가져오기 실패.")
                completion(false)
            }else if snapshot == nil{
                print("내 uid를 가진 데이터 없음.")
                completion(false)
            }else{
                self.myUserNumber = snapshot?.documents.first?.data()["userNumber"] as! Int
                completion(true)
            }
        }
    }
    
    func getRandomUid(completion: @escaping (String) -> Void){
        var useruid = ""
        db.collection("users").whereField("userNumber", isEqualTo: self.userCount).getDocuments{ snapshot, error in
            if error != nil{
                print("getRandomUid Error!!!")
                completion("nil")
            }else if snapshot == nil{
                print("해당 숫자를 가진 userNumber는 존재하지 않습니다.")
                completion("nil")
            }else{
                useruid = snapshot?.documents.first?.data()["uid"] as? String ?? "정보없음."
                print("헤헤~ : \(useruid)")
                completion(useruid)
            }
        }
    }
    
}
