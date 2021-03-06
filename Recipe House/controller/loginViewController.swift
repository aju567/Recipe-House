//
//  loginViewController.swift
//  Recipe House
//
//  Created by Ajay Vandra on 2/19/20.
//  Copyright © 2020 Ajay Vandra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class loginViewController: UIViewController {
    //MARK: - variable
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    let userDefault = UserDefaults.standard
    var check: Int?
    var alertMessage : String?
    //MARK: - outlet
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginBtnLabel: UIButton!
    @IBOutlet weak var guestBtnLabel: UIButton!
    
    //MARK: - viewdidiload function
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonLayout()
    }
    //MARK: - viewdidappear function
    override func viewDidAppear(_ animated: Bool) {
        emailTextField.text = ""
        passwordTextField.text = ""
        if userDefault.bool(forKey: "user_authtokenkey") == true{
            performSegue(withIdentifier: "tab", sender: self)
        }
        return
    }
    //MARK: - Login Button
    @IBAction func loginButton(_ sender: UIButton) {
        if login(){
            if Connection.isConnectedToInternet(){
                loginApi()
            }
        }else{
            alert(alertTitle: "INVALID EMAIL OR PASSWORD", alertMessage: "", actionTitle: "RE-ENTER DATA")
        }
    }
    //MARK: - Login validation function
    func isValidEmail(emailID:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailID)
    }
    func isValidPassword(pass:String) -> Bool {
        let passRegEx = "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", passRegEx)
        return emailTest.evaluate(with: pass)
    }
    //MARK: - alert function
    func alert(alertTitle : String,alertMessage : String,actionTitle : String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .cancel) { (alert) in
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    //MARK: - Login validation check function
    func login()->Bool{
        if emailTextField.text!.isEmpty{
            alert(alertTitle: "Enter email", alertMessage: "nil", actionTitle: "enter email")
            return false
        }
        else if passwordTextField.text!.isEmpty{
            alert(alertTitle: "Enter password", alertMessage: "nil", actionTitle: "enter password")
            return false
        }
        else{
            if !isValidEmail(emailID: emailTextField.text!){
                return false
            }
            else if !isValidPassword(pass: passwordTextField.text!){
                return false
            }
            else{
                return true
            }
        }
    }
  //MARK: - forget button pressed
    @IBAction func forgetButton(_ sender: UIButton) {
        performSegue(withIdentifier: "forget", sender: self)
    }
    //MARK: - registration button pressed
    @IBAction func registrationButton(_ sender: UIButton) {
        performSegue(withIdentifier: "reg", sender: self)
    }
    //MARK: - guest button pressed
    @IBAction func guestButton(_ sender: UIButton) {
        authtoken = ""
        performSegue(withIdentifier: "tab", sender: self)
    }
     //MARK: - Button layout
    func buttonLayout(){
        loginBtnLabel.layer.cornerRadius = loginBtnLabel.frame.size.height/2
        guestBtnLabel.layer.cornerRadius = guestBtnLabel.frame.size.height/2
    }
    //MARK: - Login API
    func loginApi(){
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        let url = URL(string: "http://127.0.0.1:3000/user/login")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["user_email":emailTextField.text!,"user_password":passwordTextField.text!]
        request.httpBody = parameters.percentEncoded()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                    print("error", error ?? "Unknown error")
                    return
            }
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            let json = try! JSON(data: data)
            let responseString = String(data: data, encoding: .utf8)
            if responseString != nil{
                DispatchQueue.main.async(){
                    self.activityIndicator.stopAnimating()
                    let message = json["message"].stringValue
                    let status = json["status"].stringValue
                    if status == "OK"{
                        let authtoken1 = json["user_authtoken"].string
                        let email1 = json["user_email"].string
                        authtoken = authtoken1!
                        email = email1!
                        self.check = 1
                        self.performSegue(withIdentifier: "tab", sender: self)
                        self.userDefault.set(true, forKey: "user_authtokenkey")
                        self.userDefault.set(authtoken, forKey: "user_authtoken")
                        self.userDefault.set(email, forKey: "email")
                    }
                    else{
                        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
                        let action = UIAlertAction(title: "Enter again", style: .cancel) { (action) in }
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        task.resume()
    }
}
//MARK: - extension
extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}
extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
