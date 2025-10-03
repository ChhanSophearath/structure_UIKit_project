//
//  TitleValueModel.swift
//  UIKitProject
//
//  Created by Rath! on 24/8/24.
//

import Foundation

struct MainModel{
    let name: String
    let detail: String
}

// Sample Fruit model
struct Fruit: Codable, Equatable {
    let name: String
    let price: Double
    let isSpecial: Bool
}
