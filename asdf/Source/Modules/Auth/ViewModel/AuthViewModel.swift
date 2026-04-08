//
//  AuthVIewModel.swift
//  asdf
//
//  Created by admin on 2026/2/14.
//

import Foundation

@MainActor
final class AuthViewModel {
    var onLoginSuccess: (() -> Void)?
    var onLoginFailure: ((String) -> Void)?
    
    /*
    func login() {
        AuthService.shared.login(username: "ldmartin@sina.cn", pass: "AAbb12#$", showLoading: true, success: { [weak self] token in
            self?.getUserInfo()
        }, failure: { [weak self] errorMsg in
            self?.onLoginFailure?(errorMsg)
        })
    }
    
    func getUserInfo() {
        AuthService.shared.userInfo(showLoading: true) { [weak self] user in
            if let user = user {
                UserManager.shared.saveUser(user)
            }
            self?.onLoginSuccess?()
        }
    }
    */
    
    func login() async {
        do {
            _ = try await AuthService.shared.login(username: "ldmartin@sina.cn",
                                                   pass: "AAbb12#$",
                                                   showLoading: true)
            let user = try await getUserInfo()
            UserManager.shared.saveUser(user)
            onLoginSuccess?()
        } catch {
            onLoginFailure?(error.localizedDescription)
        }
    }
    
    private func getUserInfo() async throws -> UserModel {
        try await AuthService.shared.userInfo(showLoading: true)
    }
    
}
