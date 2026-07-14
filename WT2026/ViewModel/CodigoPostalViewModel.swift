//
//  CodigoPostalViewModel.swift
//  WT2026
//
//  Created by Jorge Silva on 07/07/2026.
//

import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class CodigoPostalViewModel {
    
    private var repository: CodigoPostalRepository!
    
    // MARK: - Properties -
    
    /// Texto da pesquisa
    var search = ""
    
    /// Resultados apresentados na List
    var results: [CodigoPostal] = []
    
    /// Estado da View
    var viewState: ViewState = .idle
    
    // MARK: - Repository -
    
    func configure(context: ModelContext) -> Bool {
        
        guard repository == nil
        else {
            return false
        }
        
        repository = CodigoPostalRepository(context: context)
        
        return true
    }

    
    // MARK: - Import -
    
    func importFromDatabase() async {
        
        do {
            viewState = .preparing
            
            // deixa o SwiftUI desenhar este estado
            await Task.yield()
            
            viewState = .importing
            
            try await repository.importIfNeeded()
            
            try loadInitialData()
            
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Initial Load -
    
    private func loadInitialData() throws {
        
        viewState = .loading
        
        results = try repository.search(text: "")
        
        viewState = .loaded
    }
    
    // MARK: - Search -
    
    func searchFromDatabase() throws {
        
        guard repository != nil
        else {
            return
        }
        
        results = try repository.search(text: search)
    }
}
