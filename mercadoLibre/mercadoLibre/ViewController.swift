//
//  ViewController.swift
//  mercadoLibre
//
//  Created by Jurymar Colmenares on 24/10/24.
//

import UIKit

// Estructura para decodificar el resultado de la búsqueda
struct SearchResult: Codable {
    let results: [Item] // Lista de productos obtenidos en la búsqueda
}

// Estructura para representar cada item de producto
struct Item: Codable {
    let title: String    // Título del producto
    let price: Double    // Precio del producto
    let thumbnail: String? // URL de la imagen en miniatura del producto (opcional)
}

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
        titleLabel.text = item.title // Asigna el título del producto a la etiqueta correspondiente
        priceLabel.text = String(format: "$%.2f", item.price) // Muestra el precio formateado en la etiqueta de precio
        errorLabel.isHidden = true // Oculta el mensaje de error por defecto
        productImageView.image = nil // Resetea la imagen del producto
        
        // Desempaquetar item.thumbnail si no es nil, y crear una URL a partir del valor
        guard let thumbnail = item.thumbnail, let url = URL(string: thumbnail) else {
            return // Si el thumbnail es nil o la URL no es válida, salir de la función
        }
        
        // Descarga la imagen de forma asíncrona
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                // Si hay un error al descargar la imagen, mostrar un mensaje de error en la interfaz de usuario
                DispatchQueue.main.async {
                    self?.errorLabel.text = "Ocurrió un error, intentar nuevamente"
                    self?.errorLabel.isHidden = false
                }
                print("Error loading image: \(error)")
                return
            }
            
            // Si la descarga de la imagen es exitosa, convierte los datos en una UIImage
            if let data = data, let image = UIImage(data: data) {
                // Actualiza la interfaz de usuario en el hilo principal
                DispatchQueue.main.async {
                    self?.productImageView.image = image // Muestra la imagen en el ImageView
                    self?.errorLabel.isHidden = true // Oculta el mensaje de error
                }
            }
        }.resume() // Inicia la tarea de descarga
    }
}

// Controlador principal que maneja la barra de búsqueda y la tabla
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    let searchBar = UISearchBar() // Barra de búsqueda para realizar consultas de productos
    let tableView = UITableView() // Tabla para mostrar los resultados
    var items: [Item] = [] // Array para almacenar los productos obtenidos
    let initialMessageLabel = UILabel() // Etiqueta para mostrar mensajes iniciales o errores
    let activityIndicator = UIActivityIndicatorView(style: .medium) // Indicador de carga
    var lastSearchTerm: String? // Almacena el último término de búsqueda para evitar búsquedas repetidas
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // Configura la interfaz de usuario cuando la vista se carga
    }
    
    // Configurar la interfaz de usuario
    func setupUI() {
        view.backgroundColor = .white // Fondo blanco para la vista principal
        
        // Configurar la barra de búsqueda
        searchBar.placeholder = "Buscar en MercadoLibre" // Texto de ayuda en la barra de búsqueda
        searchBar.delegate = self // Asignar el controlador como delegado de la barra de búsqueda
        view.addSubview(searchBar) // Agregar la barra de búsqueda a la vista principal
        searchBar.translatesAutoresizingMaskIntoConstraints = false // Permitir restricciones personalizadas
        
        // Configurar la tabla
        tableView.dataSource = self // Asignar el controlador como fuente de datos para la tabla
        tableView.delegate = self // Asignar el controlador como delegado de la tabla
        tableView.register(ProductCell.self, forCellReuseIdentifier: "ProductCell") // Registrar la celda personalizada
        view.addSubview(tableView) // Agregar la tabla a la vista principal
        tableView.translatesAutoresizingMaskIntoConstraints = false // Permitir restricciones personalizadas
        
        // Configurar la etiqueta del mensaje inicial
        initialMessageLabel.text = "Realiza una búsqueda para ver los productos" // Mensaje inicial
        initialMessageLabel.textAlignment = .center // Centrar el texto
        initialMessageLabel.numberOfLines = 0 // Permitir múltiples líneas de texto
        view.addSubview(initialMessageLabel) // Agregar la etiqueta a la vista principal
        initialMessageLabel.translatesAutoresizingMaskIntoConstraints = false // Permitir restricciones personalizadas
        
        // Configurar el indicador de actividad
        activityIndicator.center = view.center // Ubicar el indicador de carga en el centro
        view.addSubview(activityIndicator) // Agregar el indicador de carga a la vista
        
        // Establecer las restricciones de diseño para los elementos de la vista
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            initialMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initialMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            initialMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            initialMessageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // Manejar cambios en el texto de la barra de búsqueda
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText != lastSearchTerm else {
            return // Evitar búsquedas repetidas con el mismo término
        }
        lastSearchTerm = searchText // Almacenar el nuevo término de búsqueda
        
        if searchText.isEmpty {
            // Si el texto de búsqueda está vacío, limpiar resultados y mostrar mensaje inicial
            items = []
            tableView.reloadData() // Recargar la tabla con los datos vacíos
            initialMessageLabel.text = "Realiza una búsqueda para ver los productos" // Mostrar el mensaje inicial
            initialMessageLabel.isHidden = false // Asegurarse de que el mensaje esté visible
            tableView.isHidden = true // Ocultar la tabla de resultados
        } else {
            // Si hay texto en la búsqueda, realizar la búsqueda de productos
            searchProducts(term: searchText)
            initialMessageLabel.isHidden = true // Ocultar el mensaje inicial
            tableView.isHidden = false // Mostrar la tabla de resultados
        }
    }
    
    // Realizar la búsqueda de productos
    func searchProducts(term: String) {
        activityIndicator.startAnimating() // Mostrar el indicador de carga
        
        // Codificar el término de búsqueda para URL y construir la URL de búsqueda
        guard let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.mercadolibre.com/sites/MLC/search?q=\(encodedTerm)") else {
            return
        }
        
        // Realizar la solicitud de búsqueda
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating() // Ocultar el indicador de carga
            }
            if let error = error {
                // Mostrar un mensaje de error si la búsqueda falla
                DispatchQueue.main.async {
                    self?.initialMessageLabel.text = "Ocurrió un error, intentar nuevamente"
                    self?.initialMessageLabel.isHidden = false
                    self?.tableView.isHidden = true
                }
                print("Error searching products: \(error)")
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                // Decodificar el resultado de la búsqueda en un objeto SearchResult
                let result = try JSONDecoder().decode(SearchResult.self, from: data)
                DispatchQueue.main.async {
                    if result.results.isEmpty {
                        // Si no se encontraron productos, mostrar un mensaje
                        self?.initialMessageLabel.text = "No se encontraron productos"
                        self?.initialMessageLabel.isHidden = false
                        self?.tableView.isHidden = true
                    } else {
                        // Si se encontraron productos, actualizar la lista y recargar la tabla
                        self?.items = result.results
                        self?.tableView.reloadData()
                    }
                }
            } catch {
                print("Error decoding: \(error)") // Manejar errores de decodificación
            }
        }.resume() // Iniciar la tarea de búsqueda
    }
    
    // Número de filas en la tabla
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count // Devolver el número de productos en la lista
    }
    
    // Configurar cada celda de la tabla
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductCell else {
            return UITableViewCell() // Devolver una celda vacía si no se puede reutilizar
        }
        let item = items[indexPath.row] // Obtener el producto en la posición actual
        cell.configure(with: item) // Configurar la celda con los datos del producto
        return cell // Devolver la celda configurada
    }
    
    // Altura de cada celda
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // Devolver la altura de la celda (80 puntos)
    }
}


