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
import SwiftUI



class LoginViewModel: ObservableObject{
//    @Published var email: String = ""
//    @Published var password: String = ""
//    @Published var passwordCheck: String = ""
    
    @Published var currentUser: User?
//    @Published var emailCertifyCheck: Bool = false
    
//    @Published var sendText: String = ""
    
//    @Published var signUpNickname: String = ""
//    @Published var signUpEmail: String = ""
//    @Published var signUpPassword: String = ""
//    @Published var signUpPasswordCheck: String = ""
//    
//    @Published var emailCheck = false
//    @Published var pwdCheck = false
//    @Published var pwdSecondCheck = false
    
    @Published var chatMassageText: String = ""
    
    //채팅방이 열리면 MainPage의 하단 바가 사라지게 하기위한 변수.
    @Published var isChatRoomOpened: Bool = false
    
    
    init() {
        currentUser = Auth.auth().currentUser
    }

    //combine 메모리 누수 방지?
    private var cancellables: Set<AnyCancellable> = []
    
    //이메일 유효성 검사
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
                return emailPredicate.evaluate(with: email)
    }
    
    
    //비밀번호 유효성 검사
    func isValidPassword(password: String) -> Bool {
        return password.count >= 8
    }
    
    //비밀번호 일치 불일치
    func isSamePassword(password: String, passwordCheck: String) -> Bool {
        return password == passwordCheck
    }
    
    //firebase User 등록(회원가입)
    func registerUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { registerResult, error in
            //등록 성공시 result에 값이 담기고, error엔 nil이 ,, 등록 실패시 result에 nil이 error엔 에러값이 담긴다.
            guard let newUser = registerResult?.user else {return}
            guard error == nil else {
                completion(false)
                print("Error : \(error!.localizedDescription)")
                return
            }
            
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
    func changeTabView(tabindex: String, loginViewModel: LoginViewModel,loginToMainPageActive: Binding<Bool>) -> some View{
        switch tabindex{
        case "home":
            return AnyView(HomePage(loginViewModel: loginViewModel, loginToMainPageActive: loginToMainPageActive))
        case "chatList":
            return AnyView(ChatListpage(loginViewModel: loginViewModel))
        case "setting":
            return AnyView(SettingPage(loginViewModel: loginViewModel, loginToMainPageActive: loginToMainPageActive))
        default:
            return AnyView(HomePage(loginViewModel: loginViewModel, loginToMainPageActive: loginToMainPageActive))
        }
    }
    
    //isChatRoomOpened 변수를 toggle하기위한 함수.
    func isChatRoomOpenedToggle() {
        isChatRoomOpened.toggle()
    }
    
    }//LoginViewModel
