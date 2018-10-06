//
//  LoginViewController.swift
//  RealmFirebaseSample
//
//  Created by 藤井陽介 on 2018/10/06.
//  Copyright © 2018 touyou. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func touchUpInsideLoginButton(_ sender: Any) {

        guard let mail = mailTextField.text, mail != "" else {

            let alertController = UIAlertController(title: "登録エラー", message: "メールアドレスが入力されていません。", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }
        
        guard let password = passwordTextField.text, password != "" else {

            let alertController = UIAlertController(title: "登録エラー", message: "パスワードが入力されていません。", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }

        // ログインして元の画面へ
        Auth.auth().signIn(withEmail: mail, password: password, completion: { [weak self] user, error in

            guard let self = self else { return }

            if let error = error {

                let alertController = UIAlertController(title: "ログインエラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {

                self.dismiss(animated: true, completion: nil)
            }
        })
    }
}
