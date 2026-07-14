//
//  CodigoPostalRepository.swift
//  WT2026
//
//  Created by Jorge Silva on 07/07/2026.
//

import Foundation
import SwiftData

@MainActor
final class CodigoPostalRepository {
    
    private let context: ModelContext
    private var cache: [CodigoPostal] = []
    
    private let importer = CSVImporter()
    private let importedKey = "CSVImported"
    
    // MARK: - Sorts -
    
    private let defaultSort: [SortDescriptor<CodigoPostal>] = [
        SortDescriptor(\.numCodPostal),
        SortDescriptor(\.extCodPostal)
    ]
    
    private let localSort: [SortDescriptor<CodigoPostal>] = [
        SortDescriptor(\.desigPostal),
        SortDescriptor(\.numCodPostal),
        SortDescriptor(\.extCodPostal)
    ]
    
    init(context: ModelContext) {
        self.context = context
    }
    
    // MARK: - Import -
    
    func importIfNeeded() async throws {
        
        guard !UserDefaults.standard.bool(forKey: importedKey)
        else {
            try loadCache()
            return
        }
        
        let dto = try await importer.download()
        
        //print("importIfNeeded :: importing \(dto.count) codes...")
        
        for codigo in dto {
            
            context.insert(
                CodigoPostal(
                    numCodPostal: codigo.numCodPostal,
                    extCodPostal: codigo.extCodPostal,
                    desigPostal: codigo.desigPostal
                )
            )
        }
        
        try context.save()
        
        UserDefaults.standard.set(true, forKey: importedKey)
        
        //print("importIfNeeded :: import complete")
        
        try loadCache()
    }
    
    private func loadCache() throws {
        
        guard cache.isEmpty
        else {
            return
        }
        
        let descriptor = FetchDescriptor<CodigoPostal>(
            sortBy: [
                SortDescriptor(\.numCodPostal),
                SortDescriptor(\.extCodPostal)
            ]
        )
        
        cache = try context.fetch(descriptor)
        
        print("loadCache: \(cache.count) codes")
    }
    
    // MARK: - Search -
    
    func search(text: String) throws -> [CodigoPostal] {
        
        switch SearchType.analyze(text) {
        case .empty:
            
            return cache
            
        case .code(let codeSearch):
            
            return try searchByCode(codeSearch)
            
        case .local(let localSearch):
            
            return try searchByLocal(localSearch)
            
        case .composed(let searchTerms):

            return try searchByComposed(searchTerms)
            
        }
        
    }
    
    private func searchByCode(_ searchText: String) throws -> [CodigoPostal] {
        
        let searchCode = searchText.textSearch
        
        return cache.filter {
            
            $0.numCodPostal.hasPrefix(searchCode)
            ||
            $0.extCodPostal.hasPrefix(searchCode)
            ||
            $0.codNoSeparator.hasPrefix(searchCode)
        }
    }
    
    private func searchByLocal(_ searchText: String) throws -> [CodigoPostal] {
        
        let searchCode = searchText.textSearch
        
        return cache.filter {
            $0.desigPostal.textSearch.contains(searchCode)
        }
    }
    
    private func searchByComposed(_ searchArray: [String]) throws -> [CodigoPostal] {
        
        return cache.filter { item in
            
            let complete = item.codNoSeparator.textSearch
            let local = item.desigPostal.textSearch
            
            return searchArray.allSatisfy { t in
                
                let searchTerm = t.textSearch
                
                if searchTerm.first?.isNumber == true {
                    return complete.contains(searchTerm)
                } else {
                    return local.contains(searchTerm)
                }
                
            }
        }
    }
}
