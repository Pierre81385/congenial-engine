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

struct AuthView: View {
    @State var showRegistration: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Toggle(isOn: $showRegistration, label: {
                    Text("Create Account")
                }).tint(.black)
                if(showRegistration){
                    RegistrationView()
                }else{
                    LoginView()
                }
            }
        }
    }
}

struct RegistrationView: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var verifyPassword: String = ""
    @State var success: Bool = false
    @ObservedObject var auth = FireAuth(authStatus: false, authErrorMessage: "")
    @ObservedObject var user = UserAccount.init(userAccount: Account(id: "", email: "", password: "", isActive: false), userAccounts: [], responseMessage: "", responseStatus: false)

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
                Button(action: {
                    auth.CreateUser(email: email, password: password)
                    if(Auth.auth().currentUser?.uid != nil){
                        user.userAccount.id = Auth.auth().currentUser!.uid
                        user.userAccount.email = email.lowercased()
                        user.userAccount.password = password
                        user.userAccount.isActive = false
                        user.createUserAccount()
                        if(auth.authStatus && user.responseStatus){
                            success = true
                        }
                    }else{
                        email = ""
                        password = ""
                        verifyPassword = ""
                    }
                }, label: {
                    Text("SUBMIT")
                }).navigationDestination(isPresented: $user.responseStatus, destination: { SuccessView(user: user.userAccount).navigationBarBackButtonHidden(true) })
            }
        }.onAppear{
            email = ""
            password = ""
            verifyPassword = ""
            auth.authErrorMessage = ""
            user.responseMessage = ""
        }
    }
}

struct LoginView: View {
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
                Button(action: {
                    auth.SignInWithEmailAndPassword(email: email, password: password)
                    if(Auth.auth().currentUser?.uid != nil){
                        user.getUserAccount(id: Auth.auth().currentUser!.uid)
                        if(auth.authStatus && user.responseStatus){
                            success = true
                        }
                    }else{
                        email = ""
                        password = ""
                    }
                    
                }, label: {
                    Text("SUBMIT")
                }).navigationDestination(isPresented: $success, destination: { SuccessView(user: user.userAccount).navigationBarBackButtonHidden(true) })
            }
        }
    }
}

struct SuccessView: View {
    var user: Account?
    @State var logout: Bool = false
    @ObservedObject var auth = FireAuth(authStatus: false, authErrorMessage: "")
    
    var body: some View {
        NavigationStack{
            VStack{
                Text("SUCCESS").font(.largeTitle)
                Text(user?.email ?? "Welcome")
                Button(action: {
                    auth.SignOut()
                    logout = true
                }, label: {
                    Text("Logout")
                }).navigationDestination(isPresented: $logout, destination: { AuthView() })
            }
        }
    }
}

#Preview {
    AuthView()
}
