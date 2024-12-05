//
//  DetailViewController.swift
//  mercadoLibre
//
//  Created by Jurymar Colmenares on 4/12/24.
//
import UIKit

class DetailViewController: UIViewController {
    
    // 1. Propiedad que contiene el elemento seleccionado de la lista.
    var item: Item
    
    // 2. Elementos visuales: etiquetas para el título, la imagen y el precio.
    let titleLabel = UILabel()
    let imageView = UIImageView()
    let priceLabel = UILabel()
    
    // 3. Inicialización personalizada que recibe un objeto `Item`.
    init(item: Item) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    // 4. Método requerido cuando se usa Storyboard (aquí no lo usamos, así que lanzamos un error).
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 5. Método que se llama cuando la vista ha cargado en memoria.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // Configura la interfaz visual.
        configureView() // Configura los datos que se mostrarán.
    }
    
    // 6. Configura la interfaz visual.
    private func setupUI() {
        view.backgroundColor = .white // Fondo blanco.
        
        // Configuración del `titleLabel` (etiqueta del título).
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center // Centrado horizontal del texto.
        titleLabel.numberOfLines = 0 
        
        // Configuración del `imageView` (vista de la imagen).
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit // La imagen se adapta manteniendo la proporción.
        
        // Configuración del `priceLabel` (etiqueta del precio).
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.textAlignment = .center // Centrado horizontal del texto.
        
        // 7. Añade los elementos a la vista principal.
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(priceLabel)
        
        // 8. Establece restricciones para el posicionamiento y tamaño de los elementos.
        NSLayoutConstraint.activate([
            // Restricciones para `imageView`.
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            
            // Restricciones para `titleLabel`.
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Restricciones para `priceLabel`.
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            priceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // 9. Configura el contenido visual a partir del `item`.
    private func configureView() {
        title = "Detalle" // Título en la barra de navegación.
        titleLabel.text = item.title // Asigna el título del producto.
        priceLabel.text = "Precio: $\(item.price)" // Asigna el precio del producto.
        
        //10. Descarga la imagen del producto de manera asíncrona.
        guard let imageUrl = URL(string: item.thumbnail ?? "") else { return }
        
        URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, _ in
            guard let self = self, let data = data else { return }
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data) // Muestra la imagen descargada.
            }
        }.resume() // Inicia la descarga.
    }
}
