//
//  CodigoPostalSearchType.swift
//  WT2026
//
//  Created by Jorge Silva on 08/07/2026.
//

import Foundation

enum SearchType {
    
    case empty
    case code(String)
    case local(String)
    case composed([String])
    
    static func analyze(_ searchText: String) -> SearchType {
        
        let searchText = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !searchText.isEmpty else {
            return .empty
        }
        
        let searchTerms = searchText
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)
        
        /* single term */
        if searchTerms.count == 1 {
            
            let term = searchTerms[0]
            
            let code = term.replacingOccurrences(of: "-", with: "")
            
            if code.allSatisfy(\.isNumber) {
                return .code(code)
            }
            
            return .local(term)
        }
        
        /* full term */
        let noSeparator = searchText
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        // Ex.: 3810-205
        // Ex.: 3810 205
        if noSeparator.allSatisfy(\.isNumber) {
            
            return .code(noSeparator)
        }
        
        return .composed(searchTerms)
    }
}
