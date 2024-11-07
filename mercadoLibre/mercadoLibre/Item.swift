//
//  Item.swift
//  mercadoLibre
//
//  Created by Jurymar Colmenares on 7/11/24.
//


import UIKit

// Estructura para representar cada item de producto
struct Item: Codable {
    let title: String    // Título del producto
    let price: Double    // Precio del producto
    let thumbnail: String? // URL de la imagen en miniatura del producto (opcional)
}
