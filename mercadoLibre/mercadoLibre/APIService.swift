//
//  APIService.swift
//  mercadoLibre
//
//  Created by Jurymar Colmenares on 7/11/24.
//

import UIKit

class APIService {
    // Método para buscar productos en la API de MercadoLibre.
    // Recibe:
    // - `term`: el término de búsqueda introducido por el usuario.
    // - `completion`: un closure que devuelve un resultado:
    //      - `.success` con un array de productos ([Item]).
    //      - `.failure` con un error (Error).
    //Result es un enum y utilizo un switch para usar sus 2 casos -> case .success y case .failure
    func searchProducts(term: String, completion: @escaping (Result<[Item], Error>) -> Void) {
        // Paso 1: Codificar el término para usarlo en la URL.
        // `addingPercentEncoding` asegura que el término sea seguro para incluir en una URL.
        guard let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              // Construir la URL de la solicitud usando el término codificado.
              let url = URL(string: "https://api.mercadolibre.com/sites/MLC/search?q=\(encodedTerm)") else {
            // Si ocurre un error al codificar o construir la URL, invocar el closure con un error.
            completion(.failure(NSError(domain: "URL Error", code: 0, userInfo: nil)))
            return
        }
        
        // Paso 2: Crear una solicitud de red usando URLSession.
        URLSession.shared.dataTask(with: url) { data, _, error in
            // Este bloque de código es un *closure* que se ejecuta cuando la tarea de red finaliza.
            
            // Paso 3: Manejar posibles errores de la solicitud de red.
            if let error = error {
                // Si ocurre un error de conexión, invocar el closure con el error.
                completion(.failure(error))
                return
            }
            
            // Paso 4: Verificar que se haya recibido data válida.
            guard let data = data else {
                // Si no hay datos, invocar el closure con un error de datos.
                completion(.failure(NSError(domain: "Data Error", code: 0, userInfo: nil)))
                return
            }
            
            // Paso 5: Intentar decodificar los datos recibidos en un objeto `SearchResult`.
            do {
                let result = try JSONDecoder().decode(SearchResult.self, from: data)
                // Si la decodificación es exitosa, extraer los resultados y pasarlos al closure.
                completion(.success(result.results))
            } catch {
                // Si ocurre un error durante la decodificación, invocar el closure con el error.
                completion(.failure(error))
            }
        }.resume() // Paso 6: Iniciar la tarea de red.
    }
}
