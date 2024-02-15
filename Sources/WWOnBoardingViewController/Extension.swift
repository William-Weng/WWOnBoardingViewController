//
//  Extension.swift
//  WWOnBoardingViewController
//
//  Created by William.Weng on 2023/12/27.
//

import UIKit

// MARK: - Collection (override function)
extension Collection {

    /// [為Array加上安全取值特性 => nil](https://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings)
    subscript(safe index: Index) -> Element? { return indices.contains(index) ? self[index] : nil }
}

// MARK: - Collection (function)
extension Collection {
    
    /// 計算Index / Count - 1
    /// - Returns: Int
    func _index() -> Int { return count - 1 }
}
