//
//  View+Searchable.swift
//  WT2026
//
//  Created by Jorge Silva on 14/07/2026.
//

import Foundation
import SwiftUI

extension View {
    
    @ViewBuilder
    func searchableIf(
        _ condition: Bool,
        text: Binding<String>,
        prompt: String
    ) -> some View {
        
        if condition {
            
            self.searchable(
                text: text,
                prompt: prompt
            )
            
        } else {
            
            self
        }
    }
}
