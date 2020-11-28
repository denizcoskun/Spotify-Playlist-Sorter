//
//  Collection+Extensions.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 18/07/2020.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    public subscript(safe index: Index) -> Iterator.Element? {
        return (startIndex <= index && index < endIndex) ? self[index] : nil
    }

    func sorted<T: Comparable>(keyPath: KeyPath<Element, T>, comparator: (T, T) -> Bool) -> [Element] {
        sorted(by: { lhs, rhs in
            comparator(lhs[keyPath: keyPath], rhs[keyPath: keyPath])
        })
    }
}
