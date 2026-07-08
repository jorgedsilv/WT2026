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
    
    private let importer = CSVImporter()
    private let importedKey = "CSVImported"
    
    // MARK: - Import -
    
    func importIfNeeded(context: ModelContext) async throws {
        
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
    
    func search(
        text: String,
        context: ModelContext
    ) throws -> [CodigoPostal] {
        
        let searchText = text.textSearch
        
        guard !searchText.isEmpty else {
            
            let descriptor = FetchDescriptor<CodigoPostal>(
                sortBy: [
                    SortDescriptor(\.numCodPostal),
                    SortDescriptor(\.extCodPostal)
                ]
            )
            
            return try context.fetch(descriptor)
        }
        
        if searchText.first?.isNumber == true {
            
            return try searchByCode(searchText, context: context)
            
        }
        
        return try searchByLocal(
            searchText,
            context: context
        )
    }
    
    private func searchByCode(
        _ searchText: String,
        context: ModelContext
    ) throws -> [CodigoPostal] {
        
        let searchCode = searchText.textSearch
        
        let descriptor = FetchDescriptor<CodigoPostal>(
            sortBy: [
                SortDescriptor(\.numCodPostal),
                SortDescriptor(\.extCodPostal)
            ]
        )
        
        let all = try context.fetch(descriptor)
        
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
    
    private func searchByLocal(
        _ searchText: String,
        context: ModelContext
    ) throws -> [CodigoPostal] {
        
        let descriptor = FetchDescriptor<CodigoPostal>(
            predicate: #Predicate {
                
                $0.desigPostal.localizedStandardContains(searchText)
                
            },
            sortBy: [
                SortDescriptor(\.desigPostal),
                SortDescriptor(\.numCodPostal)
            ]
        )
        
        return try context.fetch(descriptor)
    }
}
