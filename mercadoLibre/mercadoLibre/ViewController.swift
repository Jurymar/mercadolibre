//
//  ViewController.swift
//  mercadoLibre
//
//  Created by Jurymar Colmenares on 24/10/24.
//

import UIKit

// Controlador principal que maneja la barra de búsqueda y la tabla
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    let searchBar = UISearchBar() // Barra de búsqueda para realizar consultas de productos
    let tableView = UITableView() // Tabla para mostrar los resultados
    var items: [Item] = [] // Array para almacenar los productos obtenidos
    let initialMessageLabel = UILabel() // Etiqueta para mostrar mensajes iniciales o errores
    let activityIndicator = UIActivityIndicatorView(style: .medium) // Indicador de carga
    var lastSearchTerm: String? // Almacena el último término de búsqueda para evitar búsquedas repetidas
    let apiService = APIService() // Instancia de APIService para manejar la búsqueda
    
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
    
    // Llamar a APIService para realizar la búsqueda de productos
    func searchProducts(term: String) {
        activityIndicator.startAnimating() // Mostrar el indicador de carga
        
        // Usar la instancia de APIService para realizar la búsqueda
        apiService.searchProducts(term: term) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating() // Ocultar el indicador de carga
            }
            switch result {
            case .success(let products):
                DispatchQueue.main.async {
                    if products.isEmpty {
                        // Si no se encontraron productos, mostrar un mensaje
                        self?.initialMessageLabel.text = "No se encontraron productos"
                        self?.initialMessageLabel.isHidden = false
                        self?.tableView.isHidden = true
                    } else {
                        // Si se encontraron productos, actualizar la lista y recargar la tabla
                        self?.items = products
                        self?.tableView.reloadData()
                    }
                }
            case .failure:
                DispatchQueue.main.async {
                    self?.initialMessageLabel.text = "Ocurrió un error, intentar nuevamente"
                    self?.initialMessageLabel.isHidden = false
                    self?.tableView.isHidden = true
                }
            }
        }
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
