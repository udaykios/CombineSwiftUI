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
    private var cancellables = Set<AnyCancellable>()
    
    
    func getUsers() {
        NetWorkViewModel.shared.networkCall(endPoint: .root, responseType: UserData.self, requestBody: nil)
            .sink { comletion in
                switch comletion {
                case .failure(let error):
                    print("Error is \(error.localizedDescription)")
                case .finished:
                    print("finished..")
                }
            } receiveValue: { [weak self] users in
                
                self?.userData = users
            }.store(in: &cancellables)
    }
}
