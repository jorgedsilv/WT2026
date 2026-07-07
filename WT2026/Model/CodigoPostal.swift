//
//  CodigoPostal.swift
//  WT2026
//
//  Created by Jorge Silva on 07/07/2026.
//

import Foundation
import SwiftData

@Model
final class CodigoPostal {
    
    @Attribute(.unique)
    var id: String
    
    var numCodPostal: String
    var extCodPostal: String
    var desigPostal: String
    
    var codigoCompleto: String {
        "\(numCodPostal)-\(extCodPostal)"
    }
    
    init(
        numCodPostal: String,
        extCodPostal: String,
        desigPostal: String
    ) {
        self.id = "\(numCodPostal)-\(extCodPostal)"
        self.numCodPostal = numCodPostal
        self.extCodPostal = extCodPostal
        self.desigPostal = desigPostal
    }
}
