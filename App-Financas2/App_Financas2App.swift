// App-Financas2App.swift
import SwiftUI

@main
struct App_Financas2App: App {
    let persistenceController = PersistenceController.shared
    
    // Crie o GastoController aqui no nível da aplicação
    // Ele será um @StateObject para garantir que persista durante a vida da app
    @StateObject var gastoController: GastoController

    init() {
        // Correção para o erro "Escaping autoclosure captures mutating 'self' parameter"
        // Capturamos o valor de 'persistenceController.container.viewContext' em uma constante local
        // antes de passá-lo para a closure do StateObject.
        let context = persistenceController.container.viewContext
        _gastoController = StateObject(wrappedValue: GastoController(context: context))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(controller: gastoController)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
