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
    
    /* search text */
    var search = ""
    
    /* results to present in List */
    var results: [CodigoPostal] = []
    
    /* view state */
    var viewState: ViewState = .idle

    // MARK: - Repository -
    
    func configure(
        context: ModelContext
    ) {
        
        if repository == nil {
            repository = CodigoPostalRepository(context: context)
        }
    }
    
    // MARK: - Import -
    
    func importFromDatabase() async {
        
        viewState = .preparing
        
        do {
            
            viewState = .importing
            
            try await repository.importIfNeeded()
            
            viewState = .loading
            
            try searchFromDatabase()
            
            viewState = .loaded
            
        } catch {
            
            viewState = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Search -
    
    func searchFromDatabase() throws {
        results = try repository.search(text: search)
    }
}
