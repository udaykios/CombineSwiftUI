//
//  UserViewModel.swift
//  CombinePOC
//
//  Created by Quin Design on 17/08/2023.
//

import Foundation
import Combine
import SwiftUI

class UserViewModel: ObservableObject {
    @Published var userData:UserData? = nil
    
    func getUsers() {
        NetWorkViewModel.shared.networkCall(endPoint: .root, responseType: UserData.self, requestBody: nil) { resp,status in
            if status == .success {
                self.userData = resp
            }
        }
    }
}
