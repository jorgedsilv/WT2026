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
    
    /// Cache otimizada para pesquisa
    private var cachedSearch: [CachedCodigoPostal] = []
    
    private let importer = CSVImporter()
    private let importedKey = "CSVImported"
    
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
        
        cachedSearch = cache.map { item in
            
            let code = item.codNoSeparator.textSearch
            let local = item.desigPostal.textSearch
            
            return CachedCodigoPostal(
                model: item,
                baseCode: item.numCodPostal,
                searchableCode: code,
                searchableLocal: local,
                searchableText: "\(code) \(local)"
            )
        }
        
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
        
        return cachedSearch.filter {
            $0.baseCode.hasPrefix(searchCode)
            ||
            $0.model.extCodPostal.hasPrefix(searchCode)
            ||
            $0.searchableCode.hasPrefix(searchCode)
        }
        .map(\.model)
    }
    
    private func searchByLocal(_ searchText: String) throws -> [CodigoPostal] {
        
        let searchCode = searchText.textSearch
        
        return cachedSearch.filter {
            $0.searchableLocal.contains(searchCode)
        }.map(\.model)
    }
    
    private func searchByComposed(_ searchArray: [String]) throws -> [CodigoPostal] {
        
        return cachedSearch.filter { item in
            
            return searchArray.allSatisfy { term in
                
                let searchTerm = term.textSearch
                
                if searchTerm.first?.isNumber == true {
                    
                    return item.searchableCode.contains(searchTerm)
                    
                } else {
                    
                    return item.searchableLocal.contains(searchTerm)
                }
            }
        }
        .map(\.model)
    }
}
