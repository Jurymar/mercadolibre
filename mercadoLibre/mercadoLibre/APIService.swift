//
//  APIService.swift
//  mercadoLibre
//
//  Created by Jurymar Colmenares on 7/11/24.
//

import UIKit

class APIService {
    // Función para realizar la búsqueda de productos
    func searchProducts(term: String, completion: @escaping (Result<[Item], Error>) -> Void) {
        // Codificar el término de búsqueda para URL y construir la URL de búsqueda
        guard let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.mercadolibre.com/sites/MLC/search?q=\(encodedTerm)") else {
            completion(.failure(NSError(domain: "URL Error", code: 0, userInfo: nil)))
            return
        }
        
        // Realizar la solicitud de búsqueda
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error)) // Manejar el error de solicitud
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "Data Error", code: 0, userInfo: nil)))
                return
            }
            
            do {
                // Decodificar el resultado de la búsqueda en un objeto SearchResult
                let result = try JSONDecoder().decode(SearchResult.self, from: data)
                completion(.success(result.results)) // Enviar los resultados a través del closure
            } catch {
                completion(.failure(error)) // Manejar errores de decodificación
            }
        }.resume() // Iniciar la tarea de búsqueda
    }
}
