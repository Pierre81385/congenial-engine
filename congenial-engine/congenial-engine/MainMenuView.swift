//
//  MainMenuView.swift
//  congenial-engine
//
//  Created by Peter Bishop on 3/3/24.
//

import Foundation
import SwiftUI


struct MainMenuView: View {
    
    var currentUserAccount: Account
    @State var logout: Bool = false
    @ObservedObject var auth = FireAuth(authStatus: false, authErrorMessage: "")
    @ObservedObject var user = UserAccount.init(userAccount: Account(id: "", displayName: "", email: "", password: "", isActive: false), userAccounts: [], responseMessage: "", responseStatus: false)
    
    var body: some View {
        ZStack {
            NavigationStack {
                HStack {
                    Button(action: {
                        user.userAccount = currentUserAccount
                        user.userAccount.isActive = false
                        Task {
                            await user.updateUserAccountById(id: currentUserAccount.id)
                        }
                        auth.SignOut()
                        logout = true
                    }, label: {
                        Text("LOGOUT")
                    }).navigationDestination(isPresented: $logout, destination: { AuthView().navigationBarBackButtonHidden(true) })
                    Text(currentUserAccount.email)
                    Spacer()
                    Text("ONLINE: \(String(describing: currentUserAccount.isActive))")
                }
                Spacer()
                NavigationLink(destination: { ChatView(currentUserAccount: currentUserAccount) }, label: { Text("Chat") })
                NavigationLink(destination: { Text("Menu View") }, label: { Text("Menu") })
                NavigationLink(destination: { Text("Orders View") }, label: { Text("Orders") })
                NavigationLink(destination: { Text("Map View") }, label: { Text("Map") })
                NavigationLink(destination: { Text("Image View") }, label: { Text("Gallery") })
                NavigationLink(destination: { Text("Chat View") }, label: { Text("Chat") })
                Spacer()
            }
        }
    }
}
