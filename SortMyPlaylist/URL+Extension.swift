//
//  URL+Extension.swift
//  Sortify
//
//  Created by Coskun Deniz on 13/12/2020.
//

import Foundation
extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}
