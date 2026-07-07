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
        
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if text.isEmpty {
            
            let descriptor = FetchDescriptor<CodigoPostal>(
                sortBy: [
                    SortDescriptor(\.numCodPostal)
                ]
            )
            
            return try context.fetch(descriptor)
        }
        
        let predicate = #Predicate<CodigoPostal> {
            
            $0.numCodPostal.localizedStandardContains(text)
            ||
            $0.desigPostal.localizedStandardContains(text)
        }
        
        let descriptor = FetchDescriptor<CodigoPostal>(
            predicate: predicate,
            sortBy: [
                SortDescriptor(\.numCodPostal)
            ]
        )
        
        return try context.fetch(descriptor)
    }
}
