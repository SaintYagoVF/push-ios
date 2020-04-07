//
//  ConfiguracionController.swift
//  PushApp
//
//  Created by Latinus Programador on 7/15/19.
//  Copyright © 2019 Latinus. All rights reserved.
//

import UIKit

class ConfiguracionController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    var valores = ["50","100"]
    
    var picker = UIPickerView()
    
  
    
    @IBOutlet weak var txtAbiertos: UITextField!
    
  
    @IBOutlet weak var txtGuardados: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        picker.delegate = self
        picker.dataSource = self
        txtGuardados.inputView = picker
        txtAbiertos.inputView = picker
        
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return valores.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return valores[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        txtGuardados.text = valores[row]
        txtAbiertos.text = valores[row]
        
        self.view.endEditing(false)
    }

}
