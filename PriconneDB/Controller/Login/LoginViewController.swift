//
//  LoginViewController.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/28.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

protocol LoginViewControllerDelegate: class {
    func loginViewControllerDidLogin(_ vc: LoginViewController)
}

class LoginViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
        
    weak var delegate: LoginViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener { _, user in
            if user != nil {
                self.dismiss(animated: true, completion: nil)
                self.textFieldLoginEmail.text = nil
                self.textFieldLoginPassword.text = nil
                self.delegate?.loginViewControllerDidLogin(self)
            }
        }
    }
    
    // MARK: Actions
    @IBAction func loginTapped(_ sender: UIButton) {
        guard
            let email = textFieldLoginEmail.text,
            let password = textFieldLoginPassword.text,
            email.count > 0,
            password.count > 0
            else {
                return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let error = error, user == nil {
                let alert = UIAlertController(title: "ログイン失敗",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "登録", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "保存", style: .default) { _ in
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            
            Auth.auth().createUser(withEmail: emailField.text!,
                                   password: passwordField.text!) { _, error in
                if error == nil {
                    Auth.auth().signIn(withEmail: self.textFieldLoginEmail.text!,
                                       password: self.textFieldLoginPassword.text!)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        alert.addTextField { textEmail in
            textEmail.placeholder = "email入力"
        }
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "passwordを入力"
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldLoginEmail {
            textFieldLoginPassword.becomeFirstResponder()
        }
        if textField == textFieldLoginPassword {
            textField.resignFirstResponder()
        }
        return true
    }
}
