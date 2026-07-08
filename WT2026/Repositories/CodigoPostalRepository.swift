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
        
        guard !UserDefaults.standard.bool(forKey: importedKey) else {
            return
        }
        
        let dto = try await importer.download()
        
        print("importIfNeeded :: importing \(dto.count) codes...")
        
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
        
        print("importIfNeeded :: import complete")
    }
    
    // MARK: - Search -
    
    func search(text: String) throws -> [CodigoPostal] {
        
        switch SearchType.analyze(text) {
        case .empty:
            
            return try fetchAll()
            
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
        
        let all = try fetchAll()
        
        return all.filter { item in
            
            let complete = item.codNoSeparator
            
            return
                item.numCodPostal.hasPrefix(searchCode)
                ||
                item.extCodPostal.hasPrefix(searchCode)
                ||
                complete.hasPrefix(searchCode)
        }
    }
    
    private func searchByLocal(_ searchText: String) throws -> [CodigoPostal] {
        
        return try fetch(
            predicate: #Predicate<CodigoPostal> {
                $0.desigPostal.localizedStandardContains(searchText)
            },
            sort: localSort
        )
    }
    
    private func searchByComposed(_ searchArray: [String]) throws -> [CodigoPostal] {
        
        let all = try fetchAll()
        
        return all.filter { item in
            
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
    
    // MARK: - Fetch -
    
    private func fetch(
        predicate: Predicate<CodigoPostal>? = nil,
        sort: [SortDescriptor<CodigoPostal>]? = nil
    ) throws -> [CodigoPostal] {
        
        let descriptor = FetchDescriptor<CodigoPostal>(
            predicate: predicate,
            sortBy: sort ?? defaultSort
        )
        
        return try context.fetch(descriptor)
    }
    
    private func fetchAll() throws -> [CodigoPostal] {
        try fetch()
    }
}
