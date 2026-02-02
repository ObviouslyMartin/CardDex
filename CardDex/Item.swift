//
//  Item.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
