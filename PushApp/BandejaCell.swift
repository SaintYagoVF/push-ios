//
//  BandejaCell.swift
//  PushApp
//
//  Created by Latinus Programador on 7/15/19.
//  Copyright © 2019 Latinus. All rights reserved.
//

import UIKit

class BandejaCell: UITableViewCell {

    @IBOutlet weak var bandejaImagenLabel: UIImageView!
    

    @IBOutlet weak var bandejaTituloLabel: UILabel!
    
    
    @IBOutlet weak var bandejaFechaLabel: UILabel!
    
    
    @IBOutlet weak var bandejaContenidoLabel: UILabel!
    
    func setBandeja(bandeja : Bandeja){
        
        bandejaImagenLabel.image = bandeja.image
        bandejaTituloLabel.text = bandeja.titulo
        bandejaFechaLabel.text = bandeja.fecha
        bandejaContenidoLabel.text = bandeja.contenido
    }
    
}
