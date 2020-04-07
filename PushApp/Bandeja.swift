//
//  Bandeja.swift
//  PushApp
//
//  Created by Latinus Programador on 7/15/19.
//  Copyright © 2019 Latinus. All rights reserved.
//
import Foundation
import UIKit

class Bandeja{
    
    var id : Int
    var image : UIImage
    var titulo : String
    var fecha : String
    var contenido : String
    var data : String
    var urlimagen : String
    var url : String
    
    
    init(id : Int,image : UIImage, titulo : String,fecha : String, contenido: String, data: String, urlimagen : String, url  : String){
        self.id=id
        self.image=image
        self.titulo=titulo
        self.fecha=fecha
        self.contenido=contenido
        self.data=data
        self.urlimagen=urlimagen
        self.url=url
        
    }
}
