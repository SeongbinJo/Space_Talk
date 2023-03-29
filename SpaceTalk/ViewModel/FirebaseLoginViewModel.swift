//
//  FirebaseLoginViewModel.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/03/29.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject{
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordCheck: String = ""
    
    
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
    
    
}
