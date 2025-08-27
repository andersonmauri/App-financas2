// CSVExportManager.swift
import Foundation

struct CSVExportManager {
    static func gerarCSV(gastos: [GastoEntity]) -> String {
        var csvString = "Categoria,SubCategoria,Pessoa,Valor,FormaPagamento,Data\n"
        for gasto in gastos {
            let dataFormatada = DateFormatter.localizedString(from: gasto.data ?? Date(), dateStyle: .short, timeStyle: .none)
            let linha = "\(gasto.categoria ?? ""),\(gasto.subCategoria ?? ""),\(gasto.pessoa ?? ""),\(gasto.valor),\(gasto.formaPagamento ?? ""),\(dataFormatada)\n"
            csvString.append(linha)
        }
        return csvString
    }
    
    static func salvarCSV(nomeArquivo: String, csvString: String) -> URL? {
        guard let diretorioDocumentos = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let urlArquivo = diretorioDocumentos.appendingPathComponent(nomeArquivo).appendingPathExtension("csv")
        
        do {
            try csvString.write(to: urlArquivo, atomically: true, encoding: .utf8)
            return urlArquivo
        } catch {
            print("Erro ao salvar arquivo CSV: \(error.localizedDescription)")
            return nil
        }
    }
}
