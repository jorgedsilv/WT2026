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
    
    func configure(context: ModelContext) {
        
        guard repository == nil
        else {
            return
        }
        
        repository = CodigoPostalRepository(context: context)
    }

    
    // MARK: - Import -
    
    func importFromDatabase() async {
        
        viewState = .preparing
        
        do {
            
            viewState = .importing
            
            try await repository.importIfNeeded()
            
            viewState = .loading
            
            await Task.yield()
            
            try searchFromDatabase()
            
            viewState = .loaded
            
        } catch {
            
            viewState = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Search -
    
    func searchFromDatabase() throws {
        
        guard repository != nil
        else {
            return
        }
        
        if viewState != .loading {
            viewState = .loading
        }
        
        results = try repository.search(text: search)
        
        viewState = .loaded
    }
}
