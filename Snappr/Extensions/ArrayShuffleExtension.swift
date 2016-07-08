//
//  ArrayShuffleExtension.swift
//  Snappr
//
//  Created by shootr on 8/7/16.
//  Copyright © 2016 Snapr. All rights reserved.
//

import Foundation

extension Array {
    mutating func shuffle() {
        let count = UInt32(self.count)
        for i in 0...count {
            let nElement = count - i
            let n = arc4random_uniform(nElement) + i
            if i != n {
                swap(&self[Int(i)], &self[Int(n)])
            }
        }
    }
}