//
//  ContentView.swift
//  WT2026
//
//  Created by Jorge Silva on 07/07/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext)
    private var context
    
    @State
    private var vm = CodigoPostalViewModel()

    
    var body: some View {
        
        NavigationStack {
            
            Group {
                
                if vm.isImporting {
                    ProgressView("A importar códigos postais...")
                } else if vm.results.isEmpty {
                    
                    ContentUnavailableView {
                        Label("Sem códigos postais", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text("Ainda não existem códigos postais disponíveis.")
                    }
                    
                } else {
                    
                    List(vm.results) { code in
                        
                    
                        VStack(alignment: .leading) {
                            
                            HStack {
                                Text(code.codComplete)
                                    .font(.headline)
                                
                                Text(code.desigPostal)
                                    .foregroundStyle(.secondary)

                            }
                            
                        }
                    }
                    .safeAreaInset(edge: .top) {
                        
                        HStack {
                            
                            if vm.search.isEmpty {
                                Text("\(vm.results.count) códigos postais")
                            } else {
                                Text("\(vm.results.count) resultados")
                            }
                            
                        }
                        .font(.footnote)
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                        
                    }
                }
                
            }
            
        }
        .searchable(text: $vm.search, prompt: "Pesquisa um código postal")
        .autocorrectionDisabled()
        .animation(.default, value: vm.search)
        .onChange(of: vm.search) {
            
            do {
                try vm.searchFromDatabase(context: context)
            } catch {
                print("Erro na pesquisa")
                print(error)
            }
        }
        .task {
            await vm.importFromDatabase(context: context)
        }
    }
}

#Preview {
    do {
        
        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: true
        )
        
        let container = try ModelContainer(
            for: CodigoPostal.self,
            configurations: configuration
        )
        
        let context = container.mainContext
        
        context.insert(
            CodigoPostal(
                numCodPostal: "1000",
                extCodPostal: "001",
                desigPostal: "Lisboa"
            )
        )
        
        context.insert(
            CodigoPostal(
                numCodPostal: "4000",
                extCodPostal: "100",
                desigPostal: "Porto"
            )
        )
        
        return ContentView()
            .modelContainer(container)
        
    } catch {
        
        fatalError(error.localizedDescription)
    }
}
