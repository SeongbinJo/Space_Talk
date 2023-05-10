//
//  FirebaseLoginViewModel.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/03/29.
//

import Combine
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseFirestore
import SwiftUI


class LoginViewModel: ObservableObject{

    let db = Firestore.firestore()
    
    @Published var currentUser: User?
    
    //회원가입 페이지 텍스트필드
    @Published var signUpNickname: String = ""
    @Published var signUpEmail: String = ""
    @Published var signUpPassword: String = ""
    @Published var signUpPasswordCheck: String = ""
    //회원가입 페이지 '가입' 버튼 비/활성화
    @Published var emailCheck = false
    @Published var pwdCheck = false
    @Published var pwdSecondCheck = false
    @Published var nickNameCheck = false
    
    //회원가입 페이지 - 닉네임/이메일 중복확인 alert창 bool
    @Published var showNickNameResult: Bool = false
    @Published var showEmailResult: Bool = false
    
    //회원가입 페이지 - 닉네임/이메일 중복확인 bool
    @Published var isAlreadyNickName: Bool = false
    @Published var isAlreadyEmail: Bool = false
    
    //채팅방이 열리면 MainPage의 하단 바가 사라지게 하기위한 변수.
    @Published var isChatRoomOpened: Bool = false
    
    
    init() {
        currentUser = Auth.auth().currentUser
    }

    //combine 메모리 누수 방지?
    private var cancellables: Set<AnyCancellable> = []
    
    //이메일 유효성 검사
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
                return emailPredicate.evaluate(with: signUpEmail)
    }
    
    //닉네임 유효성 검사
    func isValidNickName() -> Bool {
        let nickNameRegex = "[A-Z0-9a-z가-힣]{1,10}"
        let nickNamePredicate = NSPredicate(format: "SELF MATCHES %@", nickNameRegex)
        return nickNamePredicate.evaluate(with: signUpNickname)
    }
    
    //비밀번호 유효성 검사
    func isValidPassword() -> Bool {
        return signUpPassword.count >= 8
    }
    
    //비밀번호 일치 불일치
    func isSamePassword() -> Bool {
        return signUpPassword == signUpPasswordCheck
    }
    
    //firebase User 등록(회원가입)
    func registerUser(completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: signUpEmail, password: signUpPasswordCheck) { registerResult, error in
            //등록 성공시 result에 값이 담기고, error엔 nil이 ,, 등록 실패시 result에 nil이 error엔 에러값이 담긴다.
            guard let newUser = registerResult?.user else {return}
            guard error == nil else {
                completion(false)
                print("Error : \(error!.localizedDescription)")
                return
            }
            self.currentUser = newUser
            self.writeFirestoreUser()
            newUser.sendEmailVerification{ error in
                if let error = error {
                    print("이메일 전송 에러 : \(error.localizedDescription)")
                }else{
                    print("이메일 전송 성공!!")
                }
            }
            completion(true)
            print("계정 등록 성공, 유저UID = \(newUser.uid)")
        }
    }
    
    func writeFirestoreUser(){
        db.collection("users").document(currentUser?.uid ?? "정보없음").setData(["uid" : currentUser?.uid ?? "정보없음", "email" : self.signUpEmail, "nickname" : self.signUpNickname, "registerDate" : Date()]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Firestore 쓰기 완료!!")
                //회원가입 후, 로그아웃 처리를 해주지 않으면 앱 재시작 또는 앱 재설치 했을 때 회원가입했던 정보로 자동 로그인 되어 버린다.
                self.logoutUser()
            }
        }
    }

    
    //로그인
    //로그인 성공시 현재 유저 정보(uid)가 저장되고 성공여부가 bool값으로 return 됨.
    //@escaping -> 일반적으로 비동기 처리할때 사용한다 -> 예를들어 http요청시 언제 답이 올지 모른다 -> loginUser함수 밖에서 비동기적으로 실행이 가능하다!
    func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { loginResult, error in
            if error == nil {
                self.currentUser = loginResult?.user
                if self.currentUser!.isEmailVerified {
                    completion(true)
                    print("이메일 인증을 완료한 이용자 입니다. 로그인 합니다.")
                    
                }else{
                    print("이메일 인증을 하지않은 이용자 입니다.")
                }
            }else{
                completion(false)
                print("Error : \(error!.localizedDescription)")
                print("ID 또는 PASSWORD가 잘못되었습니다.")
            }
        }
    }
    
    //로그아웃
    func logoutUser(){
        try? Auth.auth().signOut()
        self.currentUser = nil
        print("파이어베이스 로그아웃 처리 완료")
        print("내 현재정보 : \(self.currentUser?.uid ?? "정보없음")")
    }
    
    //회원탈퇴
    func deleteUser(){
        if currentUser != nil {
            db.collection("users").document(self.currentUser!.uid).delete(){ error in
                if let error = error{
                    print("Delete Error : \(error.localizedDescription)")
                }else{
                    print("해당 유저 Firestore 정보 삭제완료!")
                    self.currentUser?.delete()
                    self.logoutUser()
                }
            }
        }
        print("계정삭제 완료")
        print("내 현재정보 : \(self.currentUser?.uid ?? "정보없음")")
    }
    
    
    //인증 이메일 보내는 함수
    func sendCertifyEmail(){
        guard self.currentUser == Auth.auth().currentUser else {
            print("Firebase에 등록된 유저가 아님.")
            return
        }
        }
    
    //메인화면 텍스트 에디터 placeholder 위함. 텍스트.count 0일 경우. 보이게끔.
    func textFieldPlaceHolder(sendText: String) -> Bool {
        return sendText.count == 0
    }
    
    
    //String 값에 따라 다른 화면이 호출됨. -> 메인화면의 커스텀 탭뷰 기능임.
    func changeTabView(tabindex: String, loginViewModel: LoginViewModel, firestoreViewModel: FirestoreViewModel, loginToMainPageActive: Binding<Bool>) -> some View{
        switch tabindex{
        case "home":
            return AnyView(HomePage(loginViewModel: loginViewModel, firestoreViewModel: firestoreViewModel, loginToMainPageActive: loginToMainPageActive))
        case "chatList":
            return AnyView(ChatListpage(loginViewModel: loginViewModel))
        case "setting":
            return AnyView(SettingPage(loginViewModel: loginViewModel, loginToMainPageActive: loginToMainPageActive))
        default:
            return AnyView(HomePage(loginViewModel: loginViewModel, firestoreViewModel: firestoreViewModel, loginToMainPageActive: loginToMainPageActive))
        }
    }
    
    //isChatRoomOpened 변수를 toggle하기위한 함수.
    func isChatRoomOpenedToggle(){
        isChatRoomOpened.toggle()
    }
    
//    닉네임 중복 확인해주는 함수.
    func isNickNameAlreadyUsed(completion: @escaping (Bool) -> Void){
        db.collection("users").whereField("nickname", isEqualTo: self.signUpNickname).getDocuments(){ snapshot, error in
            guard error == nil else {
                print("닉네임 중복 Error : \(error!)")
                completion(false)
                return
            }
            if snapshot!.isEmpty{
                print("해당 닉네임이 중복되지 않음.")
                completion(false)
            }else{
                print("해당 닉네임이 이미 존재함.")
                completion(true)
            }
        }
    }

    
    //이메일 중복 확인해주는 함수.
    func isEmailAlreadyUsed(completion: @escaping (Bool) -> Void){
        db.collection("users").whereField("email", isEqualTo: self.signUpEmail).getDocuments(){ snapshot, error in
            guard error == nil else {
                print("이메일 중복 Error : \(error!)")
                completion(false)
                return
            }
            if snapshot!.isEmpty{
                print("해당 이메일이 중복되지 않음.")
                completion(false)
            }else{
                print("해당 이메일이 이미 존재함.")
                completion(true)
            }
        }
    }
    
    }//LoginViewModel
