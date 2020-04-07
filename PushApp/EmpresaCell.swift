//
//  EmpresaCell.swift
//  PushApp
//
//  Created by Latinus Programador on 8/2/19.
//  Copyright © 2019 Latinus. All rights reserved.
//

import UIKit

class EmpresaCell: UITableViewCell {

    
    @IBOutlet weak var tituloEmpresaLabel: UILabel!
    

    func setEmpresa(empresa : Empresa){
        
        
        tituloEmpresaLabel.text = empresa.nombre
    }
    
}
