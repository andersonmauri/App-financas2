// PDFExportManager.swift
import SwiftUI
import UIKit // Importe o UIKit para usar UIGraphicsPDFRenderer

struct PDFExportManager {
    static func gerarPDF(from view: some View, nomeArquivo: String, onCompletion: ((URL?) -> Void)) {
        // Envolve a view SwiftUI em um UIHostingController
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 612, height: 792) // Tamanho de uma página A4
        
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: hostingController.view.bounds)
        
        let data = pdfRenderer.pdfData { context in
            context.beginPage()
            hostingController.view.layer.render(in: context.cgContext)
        }
        
        guard let diretorioDocumentos = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Diretório de documentos não encontrado.")
            onCompletion(nil)
            return
        }
        
        let urlArquivo = diretorioDocumentos.appendingPathComponent(nomeArquivo).appendingPathExtension("pdf")
        
        do {
            try data.write(to: urlArquivo, options: .atomic)
            print("PDF salvo com sucesso em: \(urlArquivo)")
            onCompletion(urlArquivo)
        } catch {
            print("Erro ao salvar PDF: \(error.localizedDescription)")
            onCompletion(nil)
            return
        }
    }
}
