//
//  NetworkManager.swift
//  CombinePOC
//
//  Created by Quin Design on 25/07/2023.
//

import Foundation
import Combine
import SwiftUI

//MARK: ENUM for end-points,methods,content-type

enum EndPoints: String {
    case root = ""
}

enum APICallMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum ContentType: String {
    case json = "application/json"
    case urlEncoded = "application/x-www-form-urlencoded"
    case formData = "application/form-data"
}
enum NetworkStatus {
    case success
    case failure
    case unknown
}


class NetWorkViewModel: ObservableObject {
    static let shared = NetWorkViewModel()
    private var cancellable: AnyCancellable?
    let url = "https://dummyjson.com/users"
    
    func networkCall<T: Codable>(endPoint: EndPoints, urlQueries: String? = nil, method: APICallMethod = .get, responseType: T.Type, requestBody: Codable?, contentType: ContentType = .json,event_id:String? = nil,image:UIImage? = nil, completionHandler: @escaping (T?,NetworkStatus) -> Void) {
        
        let parameters = [
            "event_id":event_id
        ]
        
        var urlString = "\(self.url)"
        if let urlQueries = urlQueries{
            urlString += "\(endPoint.rawValue)?\(urlQueries)"
        }
        else {
            urlString += endPoint.rawValue
        }
        let url = URL(string: urlString)!
        let boundary = generateBoundary()
        var request = URLRequest(url: url)
        request.httpMethod =  method.rawValue
        request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        if event_id != nil && image != nil{
            guard let mediaImage = Media(withImage: image!, forKey: "image") else { return }
            let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
            request.allHTTPHeaderFields = [
                "X-User-Agent": "ios",
                "Accept-Language": "en",
                "Accept": "application/json",
                "Content-Type": "multipart/form-data; boundary=\(boundary)",
                "Authorization":"Bearer \("token")",
                "Content-Length": "\(dataBody.count)"
            ]
        }
        
        if method != .get && requestBody != nil{
            request.httpBody = try? requestBody!.toJSONData()
        }
        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: responseType.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    completionHandler(nil, .failure)
                    print("Error fetching data: \(error.localizedDescription)")
                case .finished:
                    print("Data fetched successfully")
                }
            } receiveValue: { data in
                completionHandler(data, .success)
            }
    }
    func generateBoundary() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    func createDataBody(withParameters params: [String: String?]?, media: [Media]?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\((value ?? "") + lineBreak)")
            }
        }
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.fileName)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
}
//MARK: Encodable.......
extension Encodable {
    func toJSONData(_ encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        let data = try encoder.encode(self)
        return data
    }
    func toDictionary(_ encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        let data = try encoder.encode(self)
        let object = try JSONSerialization.jsonObject(with: data)
        guard let json = object as? [String: Any] else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Deserialized object is not a dictionary")
            throw DecodingError.typeMismatch(type(of: object), context)
        }
        return json
    }
}
struct Media {
    let key: String
    let fileName: String
    let data: Data
    let mimeType: String
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        self.mimeType = "image/jpg"
        self.fileName = "\(arc4random()).jpeg"
        guard let data = image.jpegData(compressionQuality: 0.5) else { return nil }
        self.data = data
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

/*
 enum NetworkError: Error {
 case invalidURL
 case responseError
 case unknown
 }
 
 extension NetworkError: LocalizedError {
 var errorDescription: String? {
 switch self {
 case .invalidURL:
 return NSLocalizedString("Invalid URL", comment: "Invalid URL")
 case .responseError:
 return NSLocalizedString("Unexpected status code", comment: "Invalid response")
 case .unknown:
 return NSLocalizedString("Unknown error", comment: "Unknown error")
 }
 }
 }
 
 class NetWorkViewModel: ObservableObject {
 
 private var cancellable: AnyCancellable?
 static let shared = NetWorkViewModel()
 
 let url = "https://fly.quin.design"
 
 func networkCall<T: Codable>(endPoint: EndPoints, urlQueries: String? = nil, method: APICallMethod = .get, responseType: T.Type, requestBody: Codable?, contentType: ContentType = .json, completionHandler: @escaping (T?,Bool) -> Void) {
 
 var urlString = "\(self.url)"
 
 if let urlQueries = urlQueries{
 urlString += "\(endPoint.rawValue)?\(urlQueries)"
 }
 else {
 urlString += endPoint.rawValue
 }
 let url = URL(string: urlString)!
 var request = URLRequest(url: url)
 request.httpMethod =  method.rawValue
 request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
 if method != .get && requestBody != nil{
 request.httpBody = try? requestBody!.toJSONData()
 }
 cancellable = URLSession.shared.dataTaskPublisher(for: request)
 .map(\.data)
 .decode(type: responseType.self, decoder: JSONDecoder())
 .receive(on: DispatchQueue.main)
 .sink { completion in
 switch completion {
 case .failure(let error):
 completionHandler(nil, true)
 AlertManager.shared.showAlert(aType: .error, headerText: "OOPS!", contentString: error.localizedDescription as! String)
 print("Error fetching data: \(error)")
 case .finished:
 print("Data fetched successfully")
 }
 } receiveValue: { data in
 completionHandler(data, true)
 }
 }
 }
 
 MARK// USSAGE
 
 NetWorkViewModel.shared.networkCall(endPoint: .login,method:.post,responseType: LoginResp.self, requestBody: self.loginModel) { response,si  in
 if response?.status ?? false{
 print(response)
 DispatchQueue.main.async {
 AccountManager.shared.currentUser = response?.data
 AccountManager.shared.encodeAndSaveCurrentUser()
 AccountManager.shared.login()
 }
 } else {
 AlertManager.shared.showAlert(aType: .error, headerText: "OOPS!", contentString:  response?.message ?? "")
 }
 }
 
 */

class NetWorkViewManager: ObservableObject {
    static let shared = NetWorkViewManager()
    private var cancellable: AnyCancellable?
    let url = "https://fly.quin.design"
    func networkCall<T: Codable>(endPoint: EndPoints, urlQueries: String? = nil, method: APICallMethod = .get, responseType: T.Type, requestBody: Codable?, contentType: ContentType = .json,event_id:String? = nil,image:UIImage? = nil, completionHandler: @escaping (T?,NetworkStatus) -> Void) {
        
        let parameters = [
            "event_id":event_id
        ]
        
        var urlString = "\(self.url)"
        if let urlQueries = urlQueries{
            urlString += "\(endPoint.rawValue)?\(urlQueries)"
        }
        else {
            urlString += endPoint.rawValue
        }
        let url = URL(string: urlString)!
        let boundary = generateBoundary()
        var request = URLRequest(url: url)
        request.httpMethod =  method.rawValue
        request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        if event_id != nil && image != nil{
            guard let mediaImage = Media(withImage: image!, forKey: "image") else { return }
            let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
            request.allHTTPHeaderFields = [
                "X-User-Agent": "ios",
                "Accept-Language": "en",
                "Accept": "application/json",
                "Content-Type": "multipart/form-data; boundary=\(boundary)",
                "Authorization":"Bearer \("\("")")",
                "Content-Length": "\(dataBody.count)"
            ]
        }
        
        if method != .get && requestBody != nil{
            request.httpBody = try? requestBody!.toJSONData()
        }
        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: responseType.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    completionHandler(nil, .failure)
                    print("Error fetching data: \(error.localizedDescription)")
                case .finished:
                    print("Data fetched successfully")
                }
            } receiveValue: { data in
                completionHandler(data, .success)
            }
    }
    func generateBoundary() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    func createDataBody(withParameters params: [String: String?]?, media: [Media]?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\((value ?? "") + lineBreak)")
            }
        }
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.fileName)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
}
