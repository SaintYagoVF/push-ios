//
//  GuardadoCell.swift
//  PushApp
//
//  Created by Latinus Programador on 7/17/19.
//  Copyright © 2019 Latinus. All rights reserved.
//

import UIKit

class GuardadoCell: UITableViewCell {
    
    
    @IBOutlet weak var guardadoImagenLabel: UIImageView!
    
    @IBOutlet weak var guardadoTituloLabel: UILabel!
    
    @IBOutlet weak var guardadoContenidoLabel: UILabel!
    
    @IBOutlet weak var guardadoFechaLabel: UILabel!
    
    
    func setGuardado(guardado : Guardado){
        
        guardadoImagenLabel.image = guardado.image
        guardadoTituloLabel.text = guardado.titulo
        guardadoFechaLabel.text = guardado.fecha
        guardadoContenidoLabel.text = guardado.contenido
    }
    
}
