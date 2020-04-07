//
//  DetalleGuardadoController.swift
//  PushApp
//
//  Created by Latinus Programador on 7/17/19.
//  Copyright © 2019 Latinus. All rights reserved.
//

import UIKit

class DetalleGuardadoController: UIViewController {
    
    
    @IBOutlet weak var labelFecha: UILabel!
    
    
    @IBOutlet weak var labelTitulo: UILabel!
    
    @IBOutlet weak var imagenGuardado: UIImageView!
    
    
    @IBOutlet weak var labelContenido: UILabel!
    
    @IBOutlet weak var labelData: UILabel!
    
    
    @IBOutlet weak var labelUrl: UILabel!
    
    var fecha = " "
    
    var imagenurl = " "
    
    var titulo = " "
    
    var contenido = " "
    
    var data = " "
    
    var url = " "
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        labelFecha.text = fecha
        
        labelTitulo.text = titulo
        
        labelContenido.text = contenido
        
        labelData.text = data
        
        labelUrl.text = url
        
        let url2 = URL(string: imagenurl)!
        
        
        downloadImage(from: url2)
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
                self.imagenGuardado.image = UIImage(data: data)
            }
        }
    }
  

}
