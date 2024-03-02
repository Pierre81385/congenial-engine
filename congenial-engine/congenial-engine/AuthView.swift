//
//  AuthView.swift
//  congenial-engine
//
//  Created by Peter Bishop on 3/1/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import CryptoKit

struct AuthView: View {
    @State var showRegistration: Bool = false
    
    var body: some View {
        ZStack {
            
                if(showRegistration){
                    RegistrationView(showRegistration: $showRegistration)
                }else{
                    LoginView(showRegistration: $showRegistration)
                }
            
        }
    }
}

struct RegistrationView: View {
    @Binding var showRegistration: Bool
    @State var email: String = ""
    @State var password: String = ""
    @State var verifyPassword: String = ""
    @State var success: Bool = false
    @ObservedObject var auth = FireAuth(authStatus: false, authErrorMessage: "")
    @ObservedObject var user = UserAccount.init(userAccount: Account(id: "", email: "", password: "", isActive: false), userAccounts: [], responseMessage: "", responseStatus: false)
    
    func hashPass(data: Data) -> String {
        let digest = SHA256.hash(data: data)
        let hashString = digest
            .compactMap { String(format: "%02x", $0) }
            .joined()
        return hashString
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("REGISTER")
                    .font(.largeTitle)
                TextField("email address", text: $email)
                    .accentColor(.black)
                    .padding()
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                SecureField("password", text: $password)
                    .accentColor(.black)
                    .padding()
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .autocorrectionDisabled(true)
                SecureField("verify password", text: $verifyPassword)
                    .accentColor(.black)
                    .padding()
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .autocorrectionDisabled(true)
                Text(auth.authErrorMessage).tint(.red)
                Text(user.responseMessage).tint(.red)
                HStack {
                    Button(action: {
                        showRegistration = false
                    }, label: {
                        Text("to LOGIN")
                    })
                    Button(action: {
                        if(email != "" && password != "" && verifyPassword != ""){
                            if(password == verifyPassword){
                                auth.CreateUser(email: email, password: password)
                                Auth.auth().addStateDidChangeListener { (fireAuth, fireUser) in
                                    switch fireUser {
                                    case .none:
                                        print("USER NOT FOUND IN CHECK AUTH STATE")
                                    case .some(let fireUser):
                                        print("USER FOUND WITH ID: \(fireUser.uid)")
                                        user.userAccount.id = fireUser.uid
                                        user.userAccount.email = email.lowercased()
                                        user.userAccount.password = password
                                        user.userAccount.isActive = true
                                        user.createUserAccount()
                                        if(auth.authStatus && user.responseStatus){
                                            success = true
                                        }else{
                                            email = ""
                                            password = ""
                                            verifyPassword = ""
                                        }
                                    }
                                }
                            }else{
                                auth.authErrorMessage = "Passwords must match!"
                            }
                        }else{
                            auth.authErrorMessage = "All inputs must not be empty."
                        }
                    }, label: {
                        Text("SUBMIT")
                    }).navigationDestination(isPresented: $success, destination: { SuccessView(userAccount: user.userAccount).navigationBarBackButtonHidden(true) })
                }
            }
        }.onAppear{
            auth.SignOut()
            email = ""
            password = ""
            verifyPassword = ""
            auth.authErrorMessage = ""
            user.responseMessage = ""
        }
    }
}

struct LoginView: View {
    @Binding var showRegistration: Bool
    @State var email: String = ""
    @State var password: String = ""
    @State var success: Bool = false
    @ObservedObject var auth = FireAuth(authStatus: false, authErrorMessage: "")
    @ObservedObject var user = UserAccount.init(userAccount: Account(id: "", email: "", password: "", isActive: false), userAccounts: [], responseMessage: "", responseStatus: false)
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("LOGIN")
                    .font(.largeTitle)
                TextField("email address", text: $email)
                    .accentColor(.black)
                    .padding()
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                SecureField("password", text: $password)
                    .accentColor(.black)
                    .padding()
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .autocorrectionDisabled(true)
                Text(auth.authErrorMessage).tint(.red)
                Text(user.responseMessage).tint(.red)
                HStack {
                    Button(action: {
                        showRegistration = true
                    }, label: {
                        Text("to REGISTRATION")
                    })
                    Button(action: {
                        if(email != "" && password != ""){
                            auth.SignInWithEmailAndPassword(email: email, password: password)
                            Auth.auth().addStateDidChangeListener { (fireAuth, fireUser) in
                                switch fireUser {
                                case .none:
                                    print("USER NOT FOUND IN CHECK AUTH STATE")
                                case .some(let fireUser):
                                    print("USER FOUND WITH ID: \(fireUser.uid)")
                                    user.getUserAccount(id: Auth.auth().currentUser!.uid)
                                    user.userAccount.isActive = true
                                    success = true
                                }
                            }
                        }else{
                            auth.authErrorMessage = "All inputs must not be empty."
                        }
                    }, label: {
                        Text("SUBMIT")
                    }).navigationDestination(isPresented: $success, destination: { SuccessView(userAccount: user.userAccount).navigationBarBackButtonHidden(true) })
                }
            }
        }.onAppear{
            auth.SignOut()
            email = ""
            password = ""
            auth.authErrorMessage = ""
            user.responseMessage = ""
        }
    }
}

struct SuccessView: View {
    var userAccount: Account?
    @State var logout: Bool = false
    @ObservedObject var auth = FireAuth(authStatus: false, authErrorMessage: "")
    
    var body: some View {
        NavigationStack{
            VStack{
                Text("SUCCESS").font(.largeTitle)
                Text(userAccount?.email ?? "Welcome")
                Button(action: {
                    auth.SignOut()
                    logout = true
                }, label: {
                    Text("Logout")
                }).navigationDestination(isPresented: $logout, destination: { AuthView().navigationBarBackButtonHidden(true) })
            }
        }
    }
}

#Preview {
    AuthView()
}
