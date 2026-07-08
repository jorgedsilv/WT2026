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
    
    //var state: State = .idle
    
    /* search text */
    var search = ""
    
    /* results to present in List */
    var results: [CodigoPostal] = []
    
    /* loading */
    var isImporting = false

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
        
        guard !isImporting
        else {
            return
        }
        
        isImporting = true
        //state = .importing
        
        defer {
            isImporting = false
            //state = .loaded
        }
        
        do {
            
            try await repository.importIfNeeded()
            
            try searchFromDatabase()
            
        } catch {
            
            print(error)
        }
    }
    
    // MARK: - Search -
    
    func searchFromDatabase() throws {
        results = try repository.search(text: search)
    }
}

/*enum State {
    case idle
    case importing
    case loaded
    case error(Error)
}*/
