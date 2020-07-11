//
//  UINavigationController+Extension.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 11/07/2020.
//

import Foundation
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
