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
                
                switch vm.viewState {
                case .idle,
                .preparing,
                .importing,
                .loading:
                    
                    VStack(spacing: 20) {
                        
                        Image(systemName: vm.viewState.symbol)
                            .font(.system(size: 40))
                        
                        if vm.viewState.showsProgressView {
                            ProgressView()
                        }
                        
                        Text(vm.viewState.title)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    
                case .loaded:
                    
                    if vm.results.isEmpty {
                        
                        ContentUnavailableView.search(text: vm.search)
                        
                    } else {
                        
                        List(vm.results) { code in
                            
                            VStack(alignment: .leading, spacing: 2) {
                                
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
                    
                case .error(let message):
                    
                    ContentUnavailableView {
                        Label(
                            "Erro",
                            systemImage: vm.viewState.symbol
                        )
                    } description: {
                        Text(message)
                    }
                    
                }
            }
        }
        .searchableIf(
            vm.viewState.allowsSearching,
            text:  $vm.search,
            prompt: "Pesquisa um código postal"
        )
        .autocorrectionDisabled()
        .animation(.default, value: vm.search)
        .onChange(of: vm.search) {
            
            guard vm.viewState.allowsSearching
            else {
                return
            }

            
            do {
                try vm.searchFromDatabase()
            } catch {
                print("Erro na pesquisa")
                print(error)
            }
        }
        .task {
            
            vm.configure(context: context)
            
            await vm.importFromDatabase()
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
