//
//  HttpClient.swift
//  Sortify
//
//  Created by Coskun Deniz on 16/02/2021.
//

import Foundation
import Combine



final class HttpClient {
    typealias Output = URLSession.DataTaskPublisher.Output
    typealias Failure = URLError
    typealias HttpResponse = AnyPublisher<Output,Failure>
    private static var instance: HttpClient = HttpClient()
    static var shared: HttpClient {
        get {
        self.instance
        }
        set {
        self.instance = newValue
        }
    }
    static let handler = { (request: URLRequest) in URLSession.shared.dataTaskPublisher(for: request)}
    

    private func makeRequest(url: String, httpMethod: String, httpBody: Data? = nil) -> URLRequest {
        let components = URLComponents(string: url)!
        var request = URLRequest(url: components.url!)
        request.httpMethod = httpMethod
        if let data = httpBody {
            request.httpBody = data
        }
        return request
    }

    private func send(request: URLRequest, headers: [String: String] = [:]) -> HttpResponse  {
        var req = request
        headers.forEach{key, value in req.setValue(value, forHTTPHeaderField: key)}
        return HttpClient.handler(req)
            .eraseToAnyPublisher()
    }

    func get<T: Decodable>(_ type: T.Type, url: String, headers: [String: String] = [:]) -> AnyPublisher<T,Error> {
        let request = makeRequest(url: url,httpMethod:"GET")
        return self.send(request: request, headers: headers)
            .map({$0.data})
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func get(url: String, headers: [String: String] = [:]) -> HttpResponse {
        let request = makeRequest(url: url, httpMethod:"GET")
        return self.send(request: request,headers: headers)
            .eraseToAnyPublisher()
    }

    func post(url: String, data: Data, headers: [String: String] = [:]) -> HttpResponse {
        let request = makeRequest(url: url, httpMethod:"POST", httpBody: data)
        return self.send(request: request, headers: headers)
    }
    
    func post<T: Decodable>(_ type: T.Type, url: String, data: Data, headers: [String: String]=[:]) -> AnyPublisher<T,Error> {
        let request = makeRequest(url: url, httpMethod:"POST", httpBody: data)
        return self.send(request: request, headers: headers).map({$0.data})
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func put(url: String, data: Data?, headers: [String: String] = [:]) -> HttpResponse {
        let request = makeRequest(url: url, httpMethod:"PUT", httpBody: data)
        return self.send(request: request, headers: headers)
    }
    
    func put<T: Decodable>(_ type: T.Type, url: String, data: Data, headers: [String: String]=[:]) -> AnyPublisher<T,Error> {
        let request = makeRequest(url: url, httpMethod:"PUT", httpBody: data)
        return self.send(request: request, headers: headers).map({$0.data})
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
