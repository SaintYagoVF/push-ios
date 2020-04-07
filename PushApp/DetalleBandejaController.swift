//
//  DetalleBandejaController.swift
//  PushApp
//
//  Created by Latinus Programador on 7/16/19.
//  Copyright © 2019 Latinus. All rights reserved.
//

import UIKit
import SQLite

class DetalleBandejaController: UIViewController {

    @IBOutlet weak var labelFcha: UILabel!
    
    
    @IBOutlet weak var labelTitulo: UILabel!
    
    
    @IBOutlet weak var imagen: UIImageView!
    
    @IBOutlet weak var labelContenido: UILabel!
    
    
    @IBOutlet weak var labelData: UILabel!
    
    
    @IBOutlet weak var labelUrl: UILabel!
    
    
    var fecha = " "
    
    var imagenurl = " "
    
    var titulo = " "
    
    var contenido = " "
    
    var data = " "
    
    var url = " "
    
    
    
    // SQL Guardado
    
    var database: Connection!
    
    let guardadoTable = Table("guardado")
    let id_guardado = Expression<Int>("id_guardado")
    let titulo_guardado = Expression<String>("titulo_guardado")
    let contenido_guardado = Expression<String>("contenido_guardado")
    let fecha_guardado = Expression<String>("fecha_guardado")
    let data_guardado = Expression<String>("data_guardado")
    let imagen_guardado = Expression<String>("imagen_guardado")
    let url_guardado = Expression<String>("url_guardado")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        labelFcha.text = fecha
        
        labelTitulo.text = titulo
        
        labelContenido.text = contenido
        
        labelData.text = data
        
        labelUrl.text = url
        
        let url2 = URL(string: imagenurl)!
        
        
        downloadImage(from: url2)
        
        
        
        // SQL Guardado
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("guardado").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        
        
        //SQL Guardado
        
        let createTable = self.guardadoTable.create { (table) in
            table.column(self.id_guardado, primaryKey: true)
            table.column(self.titulo_guardado)
            table.column(self.contenido_guardado)
            table.column(self.fecha_guardado)
            table.column(self.data_guardado)
            table.column(self.imagen_guardado)
            table.column(self.url_guardado)
            
            
            
            
        }
        
        do {
            try self.database.run(createTable)
            print("Tabla Guardado Creada")
        } catch {
            print("Error al crear la tabla")
            print(error)
        }
        
        
        
    }
    

    @IBAction func onClickGuardar(_ sender: Any) {
        
        
        let insertUser = self.guardadoTable.insert(self.titulo_guardado <- titulo, self.contenido_guardado <- contenido, self.fecha_guardado <- fecha, self.data_guardado <- data,self.imagen_guardado <- imagenurl,self.url_guardado <- url)
        
        //,self.imagen <- payload.attachments[0] as! String,
        do {
            try self.database.run(insertUser)
            print("Notificación Guardada creada")
        } catch {
            print(error)
        }
        
       // dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
        

        
    }
    
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.imagen.image = UIImage(data: data)
            }
        }
    }
    
}
