//
//  EnumeratedSequence+Sorted.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 02/08/2020.
//

import Foundation

extension EnumeratedSequence {
    func sorted<T: Comparable>(keyPath: KeyPath<Base.Element, T>, comparator: (T, T) -> Bool) -> [EnumeratedSequence<Base>.Element] {
        sorted(by: { lhs, rhs in
            comparator(lhs.element[keyPath: keyPath], rhs.element[keyPath: keyPath])
        })
    }
}
