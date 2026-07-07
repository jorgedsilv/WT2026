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
    
    private let repository = CodigoPostalRepository()
    
    //var state: State = .idle
    
    /* search text */
    var search = ""
    
    /* results to present in List */
    var results: [CodigoPostal] = []
    
    /* loading */
    var isImporting = false

    
    // MARK: - Import -
    
    func importFromDatabase(
        context: ModelContext
    ) async {
        
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
            
            try await repository.importIfNeeded(
                context: context
            )
            
            try searchFromDatabase(context: context)
            
        } catch {
            
            print(error)
        }
    }
    
    // MARK: - Search -
    
    func searchFromDatabase(
        context: ModelContext
    ) throws {
        
        results = try repository.search(
            text: search,
            context: context
        )
    }
}

/*enum State {
    case idle
    case importing
    case loaded
    case error(Error)
}*/
