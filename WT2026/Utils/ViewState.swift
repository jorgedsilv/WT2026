//
//  ViewState.swift
//  WT2026
//
//  Created by Jorge Silva on 08/07/2026.
//

import Foundation

enum ViewState: Equatable {
    
    case idle            // acabou de criar o ViewModel
    
    case preparing       // verifica SwiftData
    
    case importing       // download + importação CSV
    
    case loading         // carregar resultados para a lista
    
    case loaded          // interface pronta

    
    case error(String)
}

extension ViewState {
    
    var title: String {
        
        switch self {
            
        case .idle:
            return "A iniciar..."
            
        case .preparing:
            return "A preparar a base de dados..."
            
        case .importing:
            return "A importar códigos postais..."
            
        case .loading:
            return "A carregar códigos postais..."
            
        case .loaded:
            return ""
            
        case .error(let message):
            return message
        }
    }
}


extension ViewState {
    
    var symbol: String {
        
        switch self {
            
        case .idle:
            return "clock"
            
        case .preparing:
            return "internaldrive"
            
        case .importing:
            return "square.and.arrow.down"
            
        case .loading:
            return "tray.full"
            
        case .loaded:
            return "checkmark.circle"
            
        case .error:
            return "xmark.circle"
        }
    }
}


