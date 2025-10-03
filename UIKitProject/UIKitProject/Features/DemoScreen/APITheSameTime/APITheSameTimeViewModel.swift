//
//  APITheSameTimeViewModel.swift
//  UIKitProject
//
//  Created by Rath! on 19/7/25.
//

import Foundation



@MainActor
class APITheSameTimeViewModel {
    
    var productList1: ProductListResponse1?
    var productList2: ProductListResponse2?
    var productList3: ProductListResponse?
    
    var onDataUpdated: (() -> Void)?
    
    func fetchApiTheSameTime() {
        Task {
            await fetchAllProducts()
        }
    }
    
    private func fetchAllProducts() async {
        await withTaskGroup(of: (Int, Any?).self) { group in
            
            group.addTask {
                let result: ProductListResponse1? = await self.fetch(endpoint: .products1)
                return (1, result)
            }
            
            group.addTask {
                let result: ProductListResponse2? = await self.fetch(endpoint: .products2)
                return (2, result)
            }
            
            group.addTask {
                let result: ProductListResponse? = await self.fetch(endpoint: .products3)
                return (3, result)
            }
            
            for await (index, result) in group {
                switch index {
                case 1: self.productList1 = result as? ProductListResponse1
                    
                    print("Handle response here.")
                case 2: self.productList2 = result as? ProductListResponse2
                    
                    print("Handle response here.")
                case 3: self.productList3 = result as? ProductListResponse
                    
                    print("Handle response here.")
                default: break
                }
            }
        }
        
        self.onDataUpdated?()
    }
    
    
    private func fetch<T: Codable>(endpoint: EndpointEnum) async -> T? {
        await withCheckedContinuation { continuation in
            ApiManager.shared.apiConnection(url: endpoint) { (res: T) in
                continuation.resume(returning: res)
            }
            
        }
    }
}


//@MainActor
class SingleCallApiViewModel {
    var productList1: ProductListResponse?
    var onDataUpdated: (() -> Void)?
    
    func fetchProduct() {
        Task {
            let result: ProductListResponse? = await fetch(endpoint: .products1)
            self.productList1 = result
            self.onDataUpdated?()
        }
    }
    
    private func fetch<T: Codable>(endpoint: EndpointEnum) async -> T? {
        await withCheckedContinuation { continuation in
            ApiManager.shared.apiConnection(url: endpoint) { (res: T) in
                continuation.resume(returning: res)
            }
        }
    }
}


struct PostModel: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

struct PostModel1: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}



@MainActor
class ViewModel: ObservableObject {
    
    // MARK: - Published properties
    var posts: [PostModel]?
    var comments: [PostModel]? // Example: second API
    var onDataUpdated: (() -> Void)? // Closure to notify UI when data updates
    
    // MARK: - Concurrent requests using async let
    func asyncCall() {
        Task {
            do {
                // Start multiple requests concurrently.
                // Both requests start immediately and run in parallel
                async let postsRequest: [PostModel] = ApiManagerAsyncAwait.shared.request(method: .GET,
                                                                                          endpoint: .apiFreePosts,
                                                                                          bodyModel: nil)
                
                async let commentsRequest: [PostModel] = ApiManagerAsyncAwait.shared.request(method: .GET,
                                                                                             endpoint: .apiFreePosts,
                                                                                             bodyModel: nil)
                
                // Await both results together
                let (postsResult, commentsResult) = try await (postsRequest, commentsRequest)
                
                // Assign results to properties
                self.posts = postsResult
                self.comments = commentsResult
                
                // Notify the UI after both are done
                onDataUpdated?()
                
            } catch {
                // Handle errors from either request
                print("❌ Unexpected Error:", error.localizedDescription)
            }
        }
    }
    
    // MARK: - Sequential requests (one after another)
    func syncCall() {
        Task {
            do {
                // First request (posts)
                let postsResult: [PostModel]? = try await ApiManagerAsyncAwait.shared.request(method: .GET,
                                                                                              endpoint: .apiFreePosts,
                                                                                              bodyModel: nil)
                
                // Second request (comments) starts after the first finishes
                let commentsResult: [PostModel]? = try await ApiManagerAsyncAwait.shared.request(method: .GET,
                                                                                                 endpoint: .apiFreePosts,
                                                                                                 bodyModel: nil,
                                                                                                 parameters: [
                                                                                                    "abc": "abc"
                                                                                                 ]
                )
                   
                
                // Assign to properties
                self.posts = postsResult
                self.comments = commentsResult
                
                // Notify UI
                onDataUpdated?()
                
            } catch {
                // Handle errors individually
                print("❌ Unexpected Error:", error.localizedDescription)
            }
        }
    }
    
    // MARK: - Fetch with TaskGroup (concurrent + flexible handling)
    func fetchWithTaskGroup() {
        Task {
            do {
                try await withThrowingTaskGroup(of: (String, Any).self) { group in
                    
                    // Add first API request
                    group.addTask {
                        let posts: [PostModel] = try await ApiManagerAsyncAwait.shared.request(method: .GET,
                                                                                               endpoint: .apiFreePosts,
                                                                                               bodyModel: nil)
                        return ("posts", posts)
                    }
                    
                    // Add second API request
                    group.addTask {
                        let comments: [PostModel1] = try await ApiManagerAsyncAwait.shared.request(method: .GET,
                                                                                                  endpoint: .apiFreePosts,
                                                                                                  bodyModel: nil)
                        return ("comments", comments)
                    }
                    
                    // Temporary storage for results
                    var tempPosts: [PostModel]?
                    var tempComments: [PostModel]?
                    
                    // Collect results as they finish
                    for try await (key, result) in group {
                        switch key {
                        case "posts":
                            tempPosts = result as? [PostModel]
                            print("===> tempPosts received")
                        case "comments":
                            tempComments = result as? [PostModel]
                            print("===> tempComments received")
                        default:
                            break
                        }
                    }
                    
                    // Assign final results
                    self.posts = tempPosts
                    self.comments = tempComments
                    
                    // Notify UI after all tasks complete
                    onDataUpdated?()
                }
            } catch {
                // Handle errors from any task in the group
                print("❌ Unexpected Error:", error.localizedDescription)
            }
        }
    }
}
