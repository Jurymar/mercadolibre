//
//  ProductCell.swift
//  mercadoLibre
//
//  Created by Jurymar Colmenares on 7/11/24.
//
import UIKit

// Celda personalizada para mostrar los productos
class ProductCell: UITableViewCell {
    let productImageView = UIImageView() // Imagen del producto
    let titleLabel = UILabel()           // Etiqueta para el título del producto
    let priceLabel = UILabel()           // Etiqueta para el precio del producto
    let errorLabel = UILabel()           // Etiqueta para mostrar errores si la imagen no se carga correctamente
    
    // Inicializador de la celda
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews() // Llama a la función que configura la disposición de los elementos en la celda
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // Método requerido, no implementado aquí
    }
    
    // Configurar la disposición de los elementos en la celda
    private func setupViews() {
        // Configurar la imagen del producto
        productImageView.contentMode = .scaleAspectFit // Ajustar la imagen dentro de los límites de la vista
        productImageView.translatesAutoresizingMaskIntoConstraints = false // Permitir restricciones personalizadas
        contentView.addSubview(productImageView) // Agregar la vista de imagen a la celda
        
        // Configurar la etiqueta del título
        titleLabel.numberOfLines = 2 // Permitir hasta 2 líneas de texto
        titleLabel.font = UIFont.systemFont(ofSize: 14) // Establecer la fuente del texto
        titleLabel.translatesAutoresizingMaskIntoConstraints = false // Permitir restricciones personalizadas
        contentView.addSubview(titleLabel) // Agregar la etiqueta de título a la celda
        
        // Configurar la etiqueta del precio
        priceLabel.font = UIFont.boldSystemFont(ofSize: 14) // Fuente en negrita para el precio
        priceLabel.translatesAutoresizingMaskIntoConstraints = false // Permitir restricciones personalizadas
        contentView.addSubview(priceLabel) // Agregar la etiqueta del precio a la celda
        
        // Configurar la etiqueta de error
        errorLabel.font = UIFont.systemFont(ofSize: 12) // Fuente normal para el texto del error
        errorLabel.textColor = .red // El texto de error será de color rojo
        errorLabel.textAlignment = .center // El texto estará centrado
        errorLabel.isHidden = true // Ocultar la etiqueta de error por defecto
        errorLabel.translatesAutoresizingMaskIntoConstraints = false // Permitir restricciones personalizadas
        contentView.addSubview(errorLabel) // Agregar la etiqueta de error a la celda
        
        // Establecer las restricciones de diseño para los elementos de la celda
        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            productImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 60),
            productImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            priceLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            
            errorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 5),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    // Configurar la celda con los datos del item
    func configure(with item: Item) {
        // 1. Asigna el título del producto a la etiqueta correspondiente
        titleLabel.text = item.title
        
        // 2. Formatea y asigna el precio a la etiqueta de precio
        priceLabel.text = String(format: "$%.2f", item.price)
        
        // 3. Oculta el mensaje de error por defecto
        errorLabel.isHidden = true
        
        // 4. Resetea la imagen del producto (limpia cualquier imagen anterior)
        productImageView.image = nil
        
        // 5. Verifica que item.thumbnail no sea nil y crea un objeto URL a partir del thumbnail
        guard let thumbnail = item.thumbnail, let url = URL(string: thumbnail) else {
            return // Si thumbnail es nil o la URL no es válida, termina la función.
        }
        
        // 6. Descarga la imagen de forma asíncrona desde la URL
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            // 7. Maneja el error si ocurre durante la descarga
            if let error = error {
                DispatchQueue.main.async {
                    // Muestra el mensaje de error en la interfaz
                    self?.errorLabel.text = "Ocurrió un error, intentar nuevamente"
                    self?.errorLabel.isHidden = false
                }
                print("Error loading image: \(error)")
                return
            }
            
            // 8. Intenta convertir los datos descargados en una UIImage
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    // 9. Actualiza la interfaz: muestra la imagen y oculta el error
                    self?.productImageView.image = image
                    self?.errorLabel.isHidden = true
                }
            }
        }.resume() // 10. Inicia la tarea de descarga
    }
}
