//
//  ViewState.swift
//  WT2026
//
//  Created by Jorge Silva on 08/07/2026.
//

import Foundation

enum ViewState: Equatable {
    
    /// O ViewModel acabou de ser criado.
    case idle
    
    /// A verificar o estado da base de dados.
    case preparing
    
    /// A importar o CSV para SwiftData.
    case importing
    
    /// A carregar os dados para apresentação.
    case loading
    
    /// Interface pronta.
    case loaded
    
    /// Ocorreu um erro.
    case error(String)
}

// MARK: - Computed Properties -

extension ViewState {
    
    /// Texto apresentado ao utilizador.
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
    
    /// Símbolo SF Symbol associado ao estado.
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
    
    /// Indica se deve ser apresentado um ProgressView.
    var showsProgressView: Bool {
        
        switch self {
            
        case .preparing,
                .importing,
                .loading:
            return true
            
        case .idle,
                .loaded,
                .error:
            return false
        }
    }
    
    /// Indica se a interface permite pesquisa.
    var allowsSearching: Bool {
        self == .loaded
    }
}

