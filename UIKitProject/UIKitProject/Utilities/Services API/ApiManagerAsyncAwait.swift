//
//  ApiManagerAsyncAwait.swift
//  UIKitProject
//
//  Created by Rath! on 1/10/25.
//

import Foundation
import SystemConfiguration
import UIKit

enum NetworkError: Error, LocalizedError {
    case noInternet
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(statusCode: Int)
    case decodingError(Error)
    case requestError(Error)
    case timeout
    case tokenRefreshFailed
    
    var errorDescription: String? {
        switch self {
        case .noInternet: return "No internet connection"
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response from server"
        case .unauthorized: return "Authentication required"
        case .serverError(let code): return "Internal Server Error (code: \(code))"
        case .decodingError(let error): return "Failed to decode response: \(error.localizedDescription)"
        case .requestError(let error): return "Request failed: \(error.localizedDescription)"
        case .timeout: return "Request timed out. Please try again."
        case .tokenRefreshFailed: return "Session expired. Please log in again."
        }
    }
    
}

class ApiManagerAsyncAwait {
    static let shared = ApiManagerAsyncAwait()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private var refreshTask: Task<String, Error>?
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120
        
        self.session = URLSession(configuration: configuration)
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    // MARK: - Main Request Method
    func request<T: Codable>(
        method: HTTPMethodEnum,
        endpoint: EndpointEnum,
        bodyModel: Encodable?,
        parameters: Parameters? = nil, //can use bodyModel or parameters for body (free style)
        queryItems: [URLQueryItem]? = nil,
        includeAuth: Bool = false
    ) async throws -> T {
        
        // Check internet connection
        guard isConnectedToNetwork() else {
            throw NetworkError.noInternet
        }
        
        // Create request
        let request = try await createRequest(
            method: method,
            endpoint: endpoint,
            bodyModel: bodyModel,
            parameters: parameters,
            queryItems: queryItems,
            includeAuth: includeAuth
        )
        
        // Execute request
        return try await executeRequest(request)
    }
    
    // MARK: - Request Creation
    private func createRequest(
        method: HTTPMethodEnum,
        endpoint: EndpointEnum,
        bodyModel: Encodable?,
        parameters: Parameters?,
        queryItems: [URLQueryItem]?,
        includeAuth: Bool = true
    ) async throws -> URLRequest {
        // Build URL
        var components = URLComponents(string: AppConfiguration.shared.apiBaseURL)
        components?.path += endpoint.rawValue
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = try await getHeaders(includeAuth: includeAuth)
        
        // Add body if present
        if let body = bodyModel {
            // Encode Swift object to JSON data
            request.httpBody = try encoder.encode(body)
        } else if let parameters = parameters {
            // Convert dictionary to JSON data
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } else {
            // No body for this request
            print("No body request")
        }

        
        return request
    }
    
    // MARK: - Request Execution
    private func executeRequest<T: Codable>(_ request: URLRequest) async throws -> T {
        
        do {
            let (data, response) = try await session.data(for: request)
            
            // Log response
            await logResponse(request: request,
                              data: data,
                              modelName: String(describing: T.self))
            
            guard let httpResponse = response as? HTTPURLResponse else {
                
                throw NetworkError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                do {
                    let decodedModel = try decoder.decode(T.self, from: data)
                    return decodedModel
                } catch {
                    throw NetworkError.decodingError(error)
                }
            case 401:
                return try await handleUnauthorizedResponse(request: request)
            case 404:
                throw NetworkError.invalidResponse
            case 500...599:
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            default:
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }
        } catch let error as URLError {
            
            print("❌ API Request failed: \(error)")
            throw NetworkError.requestError(error)
        } catch {
            print("❌ API Request failed: \(error)")
            throw NetworkError.requestError(error)
        }
    }
    
    // MARK: - Token Handling
    private func getHeaders(includeAuth: Bool) async throws -> HTTPHeaders {
        var headers = defaultHeaders()
        
        if includeAuth, let token = try await getValidToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
    
    private func getValidToken() async throws -> String? {
        guard let token = UserDefaults.standard.string(forKey: AppConstants.token) else {
            return nil
        }
        
        // Here you could add token validation logic (expiry check)
        return token
    }
    
    private func refreshToken() async throws -> String {
        if let refreshTask = refreshTask {
            return try await refreshTask.value
        }
        
        let task = Task<String, Error> {
            // defer delay
            defer { refreshTask = nil }
            
            let request = try await createRequest(
                method: .POST,
                endpoint: .refreshToken,
                bodyModel: nil,
                parameters: [
                    "refresh": UserDefaults.standard.string(forKey: AppConstants.refreshToken) ?? ""
                ],
                queryItems: nil
            )
            
            let response: LoginModel = try await executeRequest(request)
            
            // Save new tokens
            UserDefaults.standard.set(response.access, forKey: AppConstants.token)
            UserDefaults.standard.set(response.refresh, forKey: AppConstants.refreshToken)
            
            return response.access
        }
        
        refreshTask = task
        return try await task.value
    }
    
    // MARK: - Error Handling
    private func handleUnauthorizedResponse<T: Codable>(request: URLRequest) async throws -> T {
        do {
            // Try to refresh token
            let newToken = try await refreshToken()
            
            // Retry original request with new token
            var newRequest = request
            newRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
            
            return try await executeRequest(newRequest)
        } catch {
            // Token refresh failed, clear user data and show login
            await MainActor.run {
                UserDefaults.standard.removeObject(forKey: AppConstants.token)
                UserDefaults.standard.removeObject(forKey: AppConstants.refreshToken)
                
                if let sceneDelegate = UIApplication.shared.connectedScenes
                        .first?.delegate as? SceneDelegate {
                    sceneDelegate.changeRootViewController(to: LoginVC())
                }

            }
            throw NetworkError.tokenRefreshFailed
        }
    }
    
    
    // MARK: - Utilities
    private func defaultHeaders() -> HTTPHeaders {
        let lang = LanguageManager.shared.getCurrentLanguage().rawValue
        
        return [
            "Content-Type": "application/json",
            "Authorize": "4ee0d884634c0b04360c5d26060eb0dac61209c0db21d84aa9b315f1599e9a41",
            "Auth": "6213cbd30b40d782b27bcaf41f354fb8aa2353a9e59c66fba790febe9ab4cf44",
            "lang": lang
        ]
        
    }
    
    private func logResponse(request: URLRequest, data: Data, modelName: String) async {
        
        let urlString = request.url?.absoluteString ?? "Unknown URL"
        let headers = request.allHTTPHeaderFields ?? [:]
        let body = request.httpBody.flatMap { String(data: $0, encoding: .utf8) } ?? "None"
        let responseString = String(data: data, encoding: .utf8) ?? "Invalid response data"
        
        let logMessage = """
        \n\n
        ✅---> API Request -------------------
        URL: \(urlString)
        Headers: \(headers)
        Body: \(body)
        ✅---> Response --> Prepare model codable: \(modelName)
        \(responseString)
        """
        
        print(logMessage)
        
    }
    
    private func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) else {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return isReachable && !needsConnection
    }
    
}
