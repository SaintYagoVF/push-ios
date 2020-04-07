//
//  RegistroController.swift
//  PushApp
//
//  Created by Latinus Programador on 7/15/19.
//  Copyright © 2019 Latinus. All rights reserved.
//

import UIKit
import OneSignal
import AVFoundation
import QRCodeReader
import CoreLocation
import Alamofire
import SQLite

class RegistroController: UIViewController, QRCodeReaderViewControllerDelegate {
    
    //PickerView  UIPickerViewDataSource, UIPickerViewDelegate,
    
    var tokenInterno2 = ""
    var idEmpresa2 = 0
    var nombreEmpresa2 = ""
    
    let headers3: HTTPHeaders = [
        "Content-Type": "application/json",
        "Authorization": "Basic MzA3NjEwYjUtZWZlYy00Njc5LWE2Y2UtYzQ5YjMwNDRhNTVj"
        
    ]
    
    
    let activityindicatorView2 = UIActivityIndicatorView(style: .whiteLarge)
    
     var pushtoken : String = ""
    
    //SQL
    
    var database: Connection!
    
    let empresaTable = Table("empresa")
    let id_empresa = Expression<Int>("id_empresa")
    let id_tabla_empresa = Expression<Int>("id_tabla_empresa")
    let nombre_empresa = Expression<String>("nombre_empresa")
    let logo_empresa = Expression<String>("logo_empresa")
    
    
 
    // Create a global instance of NSUserDefaults class
    let defaults = UserDefaults.standard
    
    
 
    
    
    private var datePicker: UIDatePicker?
    

    
    //QRCode
    
    
    lazy var reader: QRCodeReader = QRCodeReader()
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader                  = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showTorchButton         = true
            $0.preferredStatusBarStyle = .lightContent
            $0.showOverlayView         = true
            $0.rectOfInterest          = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
            
            $0.reader.stopScanningWhenCodeIsFound = false
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //token interno
        
        tokenInterno2 = defaults.object(forKey: "tokenInterno") as? String ?? ""
      
        //OneSignal
        
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        
        let pushTokenOneSignal = status.subscriptionStatus.userId
        
        
        
        print("pushTokenOneSignal = \(pushTokenOneSignal)")
        
        pushtoken = pushTokenOneSignal ?? " "
        
        
        // SQL Empresa
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("empresa").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        
        
        //SQL Empresa
        
        let createTable = self.empresaTable.create { (table) in
            table.column(self.id_empresa, primaryKey: true)
            table.column(self.id_tabla_empresa)
            table.column(self.nombre_empresa)
            table.column(self.logo_empresa)
            
            
        }
        
        do {
            try self.database.run(createTable)
            print("Tabla Empresa Creada")
        } catch {
            print("Error al crear la tabla")
            print(error)
        }
        
        
        
        
       
    }
    
   
    
    
    
    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController
            
            switch error.code {
            case -11852:
                alert = UIAlertController(title: "Error", message: "Se necesita permiso de acceder a la cámara.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                               UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                        }
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            default:
                alert = UIAlertController(title: "Error", message: "Lector QR no es soportado por este dispositivo", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            
            present(alert, animated: true, completion: nil)
            
            return false
        }
    }
    
    
    
    // MARK: - QRCodeReader Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
        
        print("Resultado del Scan: \(result.value)")
        
        
        
        
        /*if let endOfSentence = result.value.firstIndex(of: ";"){
         
         print("end of sentence: \(endOfSentence)")
         
         let id_Empresa = result.value.index(result.value.startIndex, offsetBy: 10)..<result.value.index(endOfSentence, offsetBy: 0);
         let firstSentence = result.value[id_Empresa]
         
         print("Id Empresa: \(firstSentence)")
         */
        let fullNameArr = result.value.split(separator: ";")
        
        
        print("Arreglo Total \(fullNameArr)")
        
        if(fullNameArr.count != 5){
            activityindicatorView2.stopAnimating()
            
            let alert = UIAlertController(title: "Error", message: "Código de QR incorrecto", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
        }else{
            let r1 = fullNameArr[0].index(fullNameArr[0].startIndex, offsetBy: 10)..<fullNameArr[0].endIndex
            
            idEmpresa2 = Int(String(fullNameArr[0][r1])) ?? 0
            
            print("id_Empresa: \(idEmpresa2)")
            
            let r2 = fullNameArr[2].index(fullNameArr[2].startIndex, offsetBy: 7)..<fullNameArr[2].endIndex
            
            nombreEmpresa2 = String(fullNameArr[2][r2])
            
            print("Nombre Empresa: \(nombreEmpresa2)")
            
        
            
            agregarempresaAPI()
            
        }
        
        
        
        
        
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        print("Switching capture to: \(newCaptureDevice.device.localizedName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        activityindicatorView2.stopAnimating()
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func btnScan(_ sender: Any) {
        
        activityindicatorView2.color = UIColor.orange
        self.view.addSubview(activityindicatorView2)
        activityindicatorView2.frame = self.view.frame
        activityindicatorView2.center = self.view.center
        activityindicatorView2.startAnimating()
        
        guard checkScanPermissions() else { return }
        
        readerVC.modalPresentationStyle = .formSheet
        readerVC.delegate               = self
        
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            if let result = result {
                
                
                
            }
        }
        
        present(readerVC, animated: true, completion: nil)
        
    }
    
    
    
    
    func agregarempresaAPI(){
        
        // Alamofire.request("https://onesignal.com/api/v1/notifications", headers: headers)
        
        
        let parameters: Parameters = [
            
            "authHeader":tokenInterno2,
            
            "idEmpresaVincular": idEmpresa2
        ]
        
        let headers: HTTPHeaders = [
            
            "Authorization": "Bearer "+tokenInterno2,
            "Content-Type": "application/json"
            
        ]
        
        /*"baz": ["a", 1],
         "qux": [
         "x": 1,
         "y": 2,
         "z": 3
         ]
         */
        
        AF.request("http://192.168.0.241:8080/api/movil/subscribirEmpresa",method: .post,  parameters: parameters, encoding: JSONEncoding.default,headers: headers).responseJSON { response in
            //print("Request: \(String(describing: response.request))")   // original url request
            //print("Response: \(String(describing: response.response))") // http url response
            //print("Result: \(response.result)")
            
            
            
            switch response.result {
            case let .success(value):
                let json = value as AnyObject
                
                
                print("JSon respuesta: ",json)
                
                guard let valor = json["respuesta"] as? String else { return }
                //print("respuesta 2:",valor)
                
                if(valor == "true"){
                    print("Registro:","Empresa suscrita")
                    
                    guard let nombreEmpr = json["nombre"] as? String else { return }
                    guard let logoEmpr = json["imagen"] as? String else { return }
                    
                    let insertUser = self.empresaTable.insert(self.id_tabla_empresa <- self.idEmpresa2, self.nombre_empresa <- nombreEmpr,self.logo_empresa <- logoEmpr)
                    
                    
                    do {
                        try self.database.run(insertUser)
                        print("Empresa almacenada")
                    } catch {
                        print(error)
                    }
                    
                    
                    self.pushBienvenida()
                }
                else{
                    print("Registro:","Empresa no suscrita")
                    self.activityindicatorView2.stopAnimating()
                    
                    let alert = UIAlertController(title: "Registro Incorrecto", message: "Ya se ha registrado en esta empresa con anterioridad", preferredStyle: .alert)
                    
                    
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
                
            case let .failure(error):
                
                let alert = UIAlertController(title: "Registro Fallido", message: "Asegúrese de tener acceso a internet", preferredStyle: .alert)
                
                
                alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                
                self.activityindicatorView2.stopAnimating()
                break
            }
            
            
        }
        
    }
    
    func pushBienvenida(){
        
        // Alamofire.request("https://onesignal.com/api/v1/notifications", headers: headers)
        
        let textoPush = ["en": "Te has registrado correctamente"]
        let tituloPush = ["en": "Biendenido a nuestra App"]
        let imagenPush = ["id3": "https://img.imagenescool.com/ic/bienvenidos/bienvenidos_002.jpg"]
        let parameters: Parameters = [
            "app_id": "1bfb9336-dcbb-4154-b0c3-ca2de049c1cf",
            "include_player_ids":[pushtoken],
            "ios_attachments":imagenPush,
            "contents": textoPush,
            "headings": tituloPush
        ]
        
        /*"baz": ["a", 1],
         "qux": [
         "x": 1,
         "y": 2,
         "z": 3
         ]
         */
        
        AF.request("https://onesignal.com/api/v1/notifications",method: .post,  parameters: parameters, encoding: JSONEncoding.default,headers: headers3).responseJSON { response in
            // print("Request: \(String(describing: response.request))")   // original url request
            //print("Response: \(String(describing: response.response))") // http url response
            //print("Result: \(response.result)")                         // response serialization result
            
            
        
            switch response.result {
            case let .success(value):
                
                self.activityindicatorView2.stopAnimating()
                
                let alert = UIAlertController(title: "Empresa Agregada", message: "Se ha registrado la empresa correctamente", preferredStyle: .alert)
                
                
                alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                self.present(alert, animated: true)
               
                
            case let .failure(error):
                
               
                break
            }
            
        }
        
        
        
    }
    
    
}
