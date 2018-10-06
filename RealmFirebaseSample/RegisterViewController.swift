//
//  RegisterViewController.swift
//  RealmFirebaseSample
//
//  Created by 藤井陽介 on 2018/10/06.
//  Copyright © 2018 touyou. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repasswordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func touchUpInsideRegisterButton(_ sender: Any) {

        // guard letはメンバー向けには教えないがこういう場合によく使われる
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
        guard let repass = repasswordTextField.text, repass == password else {

            let alertController = UIAlertController(title: "登録エラー", message: "パスワードが一致しません。", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }

        Auth.auth().createUser(withEmail: mail, password: password, completion: { [weak self] user, error in

            guard let self = self else { return }

            if let error = error {

                // localizedDescriptionは完結なエラー文をデバイスの言語で提供してくれる
                // 自分で確認するだけであればerrorをそのままprintするほうが詳しいエラーが見れる
                let alertController = UIAlertController(title: "登録エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {

                // 登録が終わったらログインして元の画面へ
                // 今回はメールのバリデーションは省略
                Auth.auth().signIn(withEmail: mail, password: password, completion: { user, error in

                    if let error = error {

                        let alertController = UIAlertController(title: "ログインエラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    } else {

                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        })
    }

    @IBAction func touchUpInsideLoginButton(_ sender: Any) {
        performSegue(withIdentifier: "toLogin", sender: nil)
    }
}
