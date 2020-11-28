//
//  CGPoint+Extensions.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 18/07/2020.
//

import Foundation

extension CGPoint {
    static func + (_ point: CGPoint, _ point2: CGPoint) -> CGPoint {
        return CGPoint(x: point.x + point2.x, y: point.y + point2.y)
    }

    static func - (_ point: CGPoint, _ point2: CGPoint) -> CGPoint {
        return CGPoint(x: point.x - point2.x, y: point.y - point2.y)
    }
}

extension CGPoint {
    func scale(by magnitude: CGFloat) -> CGPoint {
        return CGPoint(x: x * magnitude, y: y * magnitude)
    }

    init(from angle: CGFloat) {
        self.init(x: cos(angle), y: sin(angle))
    }

    public func magnitude() -> CGFloat {
        return sqrt(x * x + y * y)
    }
}
