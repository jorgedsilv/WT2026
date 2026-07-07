//
//  CSVImporter.swift
//  WT2026
//
//  Created by Jorge Silva on 07/07/2026.
//

import Foundation

struct CSVImporter {
    
    private let url = URL(
        string: "https://raw.githubusercontent.com/centraldedados/codigos_postais/refs/heads/master/data/codigos_postais.csv"
    )!
    
    func download() async throws -> [CodigoPostalDTO] {
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        print("CSVImporter :: downloading...")
        
        guard let csv = String(data: data, encoding: .utf8) else {
            print("CSVImporter :: download :: url error")
            throw URLError(.cannotDecodeContentData)
        }
        
        print("CSVImporter :: download prefix 500: \(csv.prefix(500)) --//")
        return parse(csv)
    }
    
    private func parse(_ csv: String) -> [CodigoPostalDTO] {
        
        var resultado: [CodigoPostalDTO] = []
        
        let rows = csv.split(whereSeparator: \.isNewline)
        
        guard rows.count > 1 else {
            print("CSVImporter:: parse --> CSV is empty")
            return []
        }
        
        print("CSVImporter :: parseing...")
        
        for row in rows.dropFirst() {
            
            let columns = row.split(
                separator: ",",
                maxSplits: .max,
                omittingEmptySubsequences: false
            )
            
            print("CSVImporter :: test parseing :: \(columns.count): ")
            print(columns)
            print("CSVImporter :: test parseing :: ----")
            
            // Apenas ignorar linhas completamente inválidas
            guard columns.count >= 3 else {
                continue
            }
            
            let dto = CodigoPostalDTO(
                numCodPostal: String(columns[columns.count - 3]),
                extCodPostal: String(columns[columns.count - 2]),
                desigPostal: String(columns[columns.count - 1])
            )
            
            resultado.append(dto)        }
        
        print("CSVImporter :: parsing :: complete --> (size: \(resultado.count) elements)")
        return resultado
    }
}
