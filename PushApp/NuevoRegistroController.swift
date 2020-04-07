//
//  NuevoRegistroController.swift
//  PushApp
//
//  Created by Latinus Programador on 7/25/19.
//  Copyright © 2019 Latinus. All rights reserved.
//

import UIKit
import Alamofire
import OneSignal
import AVFoundation
import QRCodeReader
import CoreLocation
import SQLite



class NuevoRegistroController: UIViewController, QRCodeReaderViewControllerDelegate,   CLLocationManagerDelegate {
    
    //Variables
    let activityindicatorView = UIActivityIndicatorView(style: .whiteLarge)
    
    var usuarioRegistro = ""
    var fechaRegistro = ""
    var emailRegistro = ""
    var claveRegistro = ""
    var tokenInterno = ""
    var idEmpresa = 0
    var nombreEmpresa = ""

       var iconClick = true

    //SQL
    
    var database: Connection!
    
    let empresaTable = Table("empresa")
    let id_empresa = Expression<Int>("id_empresa")
    let id_tabla_empresa = Expression<Int>("id_tabla_empresa")
    let nombre_empresa = Expression<String>("nombre_empresa")
    let logo_empresa = Expression<String>("logo_empresa")
    
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
    
    //GPS
    
    
    var latitud : Double = 1
    
    var longitud : Double = 1
    
    let locMan : CLLocationManager = CLLocationManager()
    
    

    @IBOutlet weak var txtUsarioRegistro: UITextField!
    
    
    @IBOutlet weak var txtEmailRegistro: UITextField!
    
    
    @IBOutlet weak var txtFechaRegistro: UITextField!
    
    
    @IBOutlet weak var txtClaveRegistro: UITextField!
    
    
    @IBOutlet weak var imagenVision: UIImageView!
    
    
    
    
    private var datePicker: UIDatePicker?
    
    
    let headers3: HTTPHeaders = [
        "Content-Type": "application/json",
        "Authorization": "Basic MzA3NjEwYjUtZWZlYy00Njc5LWE2Y2UtYzQ5YjMwNDRhNTVj"
        
    ]
    
    let headers2: HTTPHeaders = [
        "Content-Type": "application/json",
        "Accept": "application/json"
        
    ]
    
    
    var pushtoken : String = ""

    
    // Create a global instance of NSUserDefaults class
    let defaults = UserDefaults.standard
   
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
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
        
        //DatePicker
        
        datePicker = UIDatePicker()
        let loc = Locale(identifier: "es")
        datePicker?.locale = loc
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(NuevoRegistroController.dateChanged(datePicker:)), for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NuevoRegistroController.viewTapped(gestureRecognizer:)))
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(LoginController.imageTapped(gestureRecognizer:)))
        imagenVision.isUserInteractionEnabled = true
        imagenVision.addGestureRecognizer(tapGesture2)
        
        view.addGestureRecognizer(tapGesture)
        txtFechaRegistro.inputView = datePicker
        
        
        //OneSignal
        
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        
        let pushTokenOneSignal = status.subscriptionStatus.userId
        
        
        
        print("pushTokenOneSignal = \(pushTokenOneSignal)")
        
        pushtoken = pushTokenOneSignal ?? " "
        
        
        //GPS
        
        locMan.delegate = self 
        
        locMan.requestWhenInUseAuthorization()
        
        locMan.startUpdatingLocation()
        
    }
    
  
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        
        view.endEditing(true)
    }
    
    @objc func imageTapped(gestureRecognizer: UITapGestureRecognizer){
        if(iconClick == true) {
            txtClaveRegistro.isSecureTextEntry = false
        } else {
            txtClaveRegistro.isSecureTextEntry = true
        }
        
        iconClick = !iconClick
    }
    
    
    
    
    @objc func dateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-dd-MM"
        txtFechaRegistro.text = dateFormatter.string(from: datePicker.date)
        // view.endEditing(true)
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
            activityindicatorView.stopAnimating()
            
            let alert = UIAlertController(title: "Error", message: "Código de QR incorrecto", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
        }else{
            let r1 = fullNameArr[0].index(fullNameArr[0].startIndex, offsetBy: 10)..<fullNameArr[0].endIndex
            
            idEmpresa = Int(String(fullNameArr[0][r1])) ?? 0
            
            print("id_Empresa: \(idEmpresa)")
            
            let r2 = fullNameArr[2].index(fullNameArr[2].startIndex, offsetBy: 7)..<fullNameArr[2].endIndex
            
            nombreEmpresa = String(fullNameArr[2][r2])
            
            print("Nombre Empresa: \(nombreEmpresa)")
            
            
            self.locMan.stopUpdatingLocation()
            
            registrarAPI()
            
        }
        
       
        
        
        
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        print("Switching capture to: \(newCaptureDevice.device.localizedName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        activityindicatorView.stopAnimating()
        dismiss(animated: true, completion: nil)
    }
    
    
    //GPS
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        for currentLocation in locations{
            
            latitud = currentLocation.coordinate.latitude
            
            longitud = currentLocation.coordinate.longitude
            
            print("Latitud:" + String(latitud))
            
            print("Longitud:" + String(longitud))
            
        }
    }
    
    
    
    
    @IBAction func btnRegistro(_ sender: Any) {
        
    
        usuarioRegistro = txtUsarioRegistro.text ?? ""
        fechaRegistro = txtFechaRegistro.text ?? ""
        claveRegistro = txtClaveRegistro.text ?? ""
        emailRegistro = txtEmailRegistro.text ?? ""
        
        
       
        
        if(usuarioRegistro.count < 3 || fechaRegistro.isEmpty || emailRegistro.isEmpty || claveRegistro.count < 6){
            
            let alert = UIAlertController(title: "Campos Obligatorios", message: "Llene todos los campos, la clave debe ser de almenos 6 dígitos, el email almenos 3", preferredStyle: .alert)
            
          
            alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
        }
        else{
            
            //OneSignal
            
            let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
            
            let pushTokenOneSignal = status.subscriptionStatus.userId
            
            
            pushtoken = pushTokenOneSignal ?? " "
            
            activityindicatorView.color = UIColor.orange
            self.view.addSubview(activityindicatorView)
            activityindicatorView.frame = self.view.frame
            activityindicatorView.center = self.view.center
            activityindicatorView.startAnimating()
            
            guard checkScanPermissions() else { return }
            
            readerVC.modalPresentationStyle = .formSheet
            readerVC.delegate               = self
            
            readerVC.completionBlock = { (result: QRCodeReaderResult?) in
                if let result = result {
                    
                    
                    
                }
            }
            
            present(readerVC, animated: true, completion: nil)
            
            
            
            
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
         
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
                
                self.activityindicatorView.stopAnimating()
                
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "ContainerVC") as! ContainerVC
                self.present(viewController, animated: true, completion: nil)

                
            
            }else{
                self.activityindicatorView.stopAnimating()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "ContainerVC") as! ContainerVC
                self.present(viewController, animated: true, completion: nil)
            }
            
           
        }
        
  
        
    }
    
    func registrarAPI(){
        
        // Alamofire.request("https://onesignal.com/api/v1/notifications", headers: headers)
        
 
        let parameters: Parameters = [
            "name": usuarioRegistro,
            "email":emailRegistro,
            "username":emailRegistro,
            "fechaNacimiento": fechaRegistro,
            "role": ["ROLE_MOVIL_PUSH"],
            "password": claveRegistro
        ]
        
        /*"baz": ["a", 1],
         "qux": [
         "x": 1,
         "y": 2,
         "z": 3
         ]
         */
        
        AF.request("http://192.168.0.241:8080/api/auth/registrar",method: .post,  parameters: parameters, encoding: JSONEncoding.default,headers: headers2).responseJSON { response in
            // print("Request: \(String(describing: response.request))")   // original url request
            //print("Response: \(String(describing: response.response))") // http url response
            //print("Result: \(response.result)")
            
    
            
            switch response.result {
            case let .success(value):
                let json = value as AnyObject
              
                print("JSon respuesta: ",json)
                
                guard let valor = json["respuesta"] as? Bool else { return }
                //print("respuesta 2:",valor)
                
                if(valor == true){
                print("Registro:","Usuario Registrado")
                    
                    self.loginAPI()
                }
                else{
                    print("Registro:","El Usuario ya existe")
                    self.activityindicatorView.stopAnimating()
                    
                    let alert = UIAlertController(title: "Registro Incorrecto", message: "El correo electrónico ya se encuentra registrado.", preferredStyle: .alert)
                    
                    
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
              
            case let .failure(error):
                let alert = UIAlertController(title: "Registro Fallido", message: "Asegúrese de tener acceso a internet", preferredStyle: .alert)
                
                
                alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                self.activityindicatorView.stopAnimating()
                break
            }
            
            
        }
        
        
    
        
    }
    
    
    func loginAPI(){
        
        // Alamofire.request("https://onesignal.com/api/v1/notifications", headers: headers)
        
        
        let parameters: Parameters = [
         
            "username":emailRegistro,
        
            "password": claveRegistro
        ]
        
        /*"baz": ["a", 1],
         "qux": [
         "x": 1,
         "y": 2,
         "z": 3
         ]
         */
        
        AF.request("http://192.168.0.241:8080/api/auth/login",method: .post,  parameters: parameters, encoding: JSONEncoding.default,headers: headers2).responseJSON { response in
            // print("Request: \(String(describing: response.request))")   // original url request
            //print("Response: \(String(describing: response.response))") // http url response
            //print("Result: \(response.result)")
            
            
            
            switch response.result {
            case let .success(value):
                let json = value as AnyObject
                
                print("Login respuesta: ",json)
                
                guard let valor = json["message"] as? String else { return }
                //print("respuesta 2:",valor)
                
                if(valor == "true"){
                    print("Login:","Login Exitoso")
                    
                     guard let valorToken = json["accessToken"] as? String else { return }
                    print("Token Interno:",valorToken)
                    
                    self.tokenInterno = valorToken
                    
                    self.defaults.set(valorToken, forKey: "tokenInterno")
                    
                 
                    
                    self.registrotokenAPI()
                
                }
                else{
                    print("Login:","Usuario o contraseña inválidos")
                    let alert = UIAlertController(title: "Registro Fallido", message: "Asegúrese de tener acceso a internet.", preferredStyle: .alert)
                    self.activityindicatorView.stopAnimating()
                    
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
                
            case let .failure(error):
                let alert = UIAlertController(title: "Registro Fallido", message: "Asegúrese de tener acceso a internet", preferredStyle: .alert)
                
                
                alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                self.activityindicatorView.stopAnimating()
                
                break
            }
            
            
        }
        
        

        
    }
    
    
    
    func registrotokenAPI(){
        
        // Alamofire.request("https://onesignal.com/api/v1/notifications", headers: headers)
        
        
        let parameters: Parameters = [
            
            "authHeader":tokenInterno,
            
            "tokenOneSignal": pushtoken
        ]
        
        let headers: HTTPHeaders = [
            
            "Authorization": "Bearer "+tokenInterno,
            "Content-Type": "application/json"
            
        ]
        
        /*"baz": ["a", 1],
         "qux": [
         "x": 1,
         "y": 2,
         "z": 3
         ]
         */
        
        AF.request("http://192.168.0.241:8080/api/movil/actualizarTokenOneSignal",method: .post,  parameters: parameters, encoding: JSONEncoding.default,headers: headers).responseJSON { response in
            // print("Request: \(String(describing: response.request))")   // original url request
            //print("Response: \(String(describing: response.response))") // http url response
            //print("Result: \(response.result)")
            
            
            
            switch response.result {
            case let .success(value):
                let json = value as AnyObject
                
                
                print("JSon respuesta: ",json)
                
                guard let valor = json["respuesta"] as? String else { return }
                //print("respuesta 2:",valor)
                
                if(valor == "true"){
                    print("Registro:","Token Ingresado")
                    
                    self.agregarubicacionAPI()
                }
                else{
                    print("Registro:","Token no se pudo ingresar")
                    self.activityindicatorView.stopAnimating()
                    
                    let alert = UIAlertController(title: "Registro Incorrecto", message: "Asegúrese de tener acceso a internet.", preferredStyle: .alert)
                    
                    
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
                
            case let .failure(error):
                
                let alert = UIAlertController(title: "Registro Fallido", message: "Asegúrese de tener acceso a internet", preferredStyle: .alert)
                
                
                alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                
                self.activityindicatorView.stopAnimating()
                break
            }
            
            
        }
        
    }
    
    
    func agregarubicacionAPI(){
        
        // Alamofire.request("https://onesignal.com/api/v1/notifications", headers: headers)
        
        
        let parameters: Parameters = [
            
            "authHeader":tokenInterno,
            
            "latitud": latitud,
            
            "longitud": longitud
        ]
        
        let headers: HTTPHeaders = [
            
            "Authorization": "Bearer "+tokenInterno,
            "Content-Type": "application/json"
            
        ]
        
        /*"baz": ["a", 1],
         "qux": [
         "x": 1,
         "y": 2,
         "z": 3
         ]
         */
        
        AF.request("http://192.168.0.241:8080/api/movil/agregarUbicacionMovil",method: .post,  parameters: parameters, encoding: JSONEncoding.default,headers: headers).responseJSON { response in
            // print("Request: \(String(describing: response.request))")   // original url request
            //print("Response: \(String(describing: response.response))") // http url response
            //print("Result: \(response.result)")
            
            
            
            switch response.result {
            case let .success(value):
                let json = value as AnyObject
                
                
                print("JSon respuesta: ",json)
                
                guard let valor = json["respuesta"] as? String else { return }
                //print("respuesta 2:",valor)
                
                if(valor == "true"){
                    print("Registro:","Ubicacion Agregada")
                    
                    self.agregarempresaAPI()
                }
                else{
                    print("Registro:","Ubicacion no agregada")
                    self.activityindicatorView.stopAnimating()
                    
                    let alert = UIAlertController(title: "Registro Incorrecto", message: "Asegúrese de tener acceso a internet.", preferredStyle: .alert)
                    
                    
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
                
            case let .failure(error):
                
                let alert = UIAlertController(title: "Registro Fallido", message: "Asegúrese de tener acceso a internet", preferredStyle: .alert)
                
                
                alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                
                self.activityindicatorView.stopAnimating()
                break
            }
            
            
        }
        
    }
    
    
    func agregarempresaAPI(){
        
        // Alamofire.request("https://onesignal.com/api/v1/notifications", headers: headers)
        
        
        let parameters: Parameters = [
            
            "authHeader":tokenInterno,
            
            "idEmpresaVincular": idEmpresa
        ]
        
        let headers: HTTPHeaders = [
            
            "Authorization": "Bearer "+tokenInterno,
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
                    
                    let insertUser = self.empresaTable.insert(self.id_tabla_empresa <- self.idEmpresa, self.nombre_empresa <- nombreEmpr,self.logo_empresa <- logoEmpr)
                    
                   
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
                    self.activityindicatorView.stopAnimating()
                    
                    let alert = UIAlertController(title: "Registro Incorrecto", message: "Ya se ha registrado en esta empresa con anterioridad", preferredStyle: .alert)
                    
                    
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
                
            case let .failure(error):
                
                let alert = UIAlertController(title: "Registro Fallido", message: "Asegúrese de tener acceso a internet", preferredStyle: .alert)
                
                
                alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                
                self.activityindicatorView.stopAnimating()
                break
            }
            
            
        }
        
    }

}
