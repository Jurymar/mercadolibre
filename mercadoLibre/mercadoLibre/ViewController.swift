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
        initialMessageLabel.text = "Realiza una búsqueda para ver los productos 👆" // Mensaje inicial
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
        // Paso 1: Comprobar si el nuevo término de búsqueda es igual al último término usado
        guard searchText != lastSearchTerm else {
            return // Si son iguales, no hacer nada para evitar búsquedas repetidas
        }
        
        // Paso 2: Actualizar el término de búsqueda más reciente
        lastSearchTerm = searchText
        
        // Paso 3: Verificar si el texto ingresado está vacío
        if searchText.isEmpty {
            // Caso 3.1: Si el texto está vacío, limpiar los resultados de búsqueda
            items = [] // Vaciar la lista de productos
            tableView.reloadData() // Recargar la tabla para reflejar los datos vacíos
            
            // Paso 3.2: Mostrar un mensaje inicial al usuario
            initialMessageLabel.text = "Realiza una búsqueda para ver los productos 👆" // Texto informativo
            initialMessageLabel.isHidden = false // Asegurarse de que el mensaje esté visible
            
            // Paso 3.3: Ocultar la tabla de resultados porque no hay datos que mostrar
            tableView.isHidden = true
        } else {
            // Caso 3.4: Si hay texto en la barra de búsqueda, realizar la búsqueda de productos
            
            // Paso 4.1: Iniciar la búsqueda llamando a la función `searchProducts`
            searchProducts(term: searchText)
            
            // Paso 4.2: Ocultar el mensaje inicial porque ahora se mostrarán los resultados
            initialMessageLabel.isHidden = true
            
            // Paso 4.3: Mostrar la tabla de resultados con los datos obtenidos
            tableView.isHidden = false
        }
    }
    
    // Llamar a APIService para realizar la búsqueda de productos
    func searchProducts(term: String) {
        // Paso 1: Mostrar un indicador de carga en la interfaz de usuario
        activityIndicator.startAnimating() // Esto informa al usuario que se está procesando la búsqueda.
        
        // Paso 2: Llamar al método `searchProducts` del servicio de API
        // Aquí se pasa un closure como argumento para manejar el resultado asíncrono de la búsqueda.
        apiService.searchProducts(term: term, completion: { [weak self] result in
            // Paso 3: Asegurarse de ejecutar el manejo de resultados en el hilo principal.
            // Todas las operaciones que actualizan la interfaz de usuario deben realizarse en el hilo principal.
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating() // Detener el indicador de carga.
            }
            
            // Paso 4: Manejar el resultado devuelto por la API.
            switch result {
            case .success(let products): // Si la solicitud fue exitosa y devolvió productos:
                DispatchQueue.main.async {
                    if products.isEmpty {
                        // Caso 4.1: Si no se encontraron productos, mostrar un mensaje.
                        self?.initialMessageLabel.text = "No se encontraron productos "
                        self?.initialMessageLabel.isHidden = false // Mostrar el mensaje.
                        self?.tableView.isHidden = true // Ocultar la tabla.
                    } else {
                        // Caso 4.2: Si se encontraron productos, actualizarlos en la tabla.
                        self?.items = products // Almacenar los productos en la propiedad `items`.
                        self?.tableView.reloadData() // Recargar la tabla con los nuevos datos.
                    }
                }
                
            case .failure: // Si hubo un error en la solicitud:
                DispatchQueue.main.async {
                    // Mostrar un mensaje de error al usuario.
                    self?.initialMessageLabel.text = "Ocurrió un error, intentar nuevamente"
                    self?.initialMessageLabel.isHidden = false // Mostrar el mensaje.
                    self?.tableView.isHidden = true // Ocultar la tabla de resultados.
                }
            }
        })
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
