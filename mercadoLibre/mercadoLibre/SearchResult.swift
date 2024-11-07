//
//  SearchResult.swift
//  mercadoLibre
//
//  Created by Jurymar Colmenares on 7/11/24.
//


import UIKit

// Estructura para decodificar el resultado de la búsqueda
struct SearchResult: Codable {
    let results: [Item] // Lista de productos obtenidos en la búsqueda
}
