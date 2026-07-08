//
//  String+Search.swift
//  WT2026
//
//  Created by Jorge Silva on 08/07/2026.
//

import Foundation

extension String {
    
    var textSearch: String {
        
        self
            .folding(
                options: [.diacriticInsensitive, .caseInsensitive],
                locale: .current
            )
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
