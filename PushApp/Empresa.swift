//
//  Empresa.swift
//  PushApp
//
//  Created by Latinus Programador on 8/2/19.
//  Copyright © 2019 Latinus. All rights reserved.
//

import Foundation
import UIKit

class Empresa{
    var id : Int
    var id_externo : Int
    var nombre : String
    var logo : String
  
    
    
    init(id : Int, id_ext : Int, nombre : String,logo : String){
        self.id=id
        self.id_externo=id_ext
        self.nombre=nombre
        self.logo=logo
     
    }
}
