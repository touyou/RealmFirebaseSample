//
//  PostViewController.swift
//  RealmFirebaseSample
//
//  Created by 藤井陽介 on 2018/10/06.
//  Copyright © 2018 touyou. All rights reserved.
//

import UIKit
import Firebase

class PostViewController: UIViewController {

    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func touchUpInsideAddButton(_ sender: Any) {

        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        // 今回はフォトライブラリオンリーに
        // 実用的にはUIAlertControllerを使ってどちらにするか選択させるなどもよく行われる
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func touchUpInsidePostButton(_ sender: Any) {

        if postTextView.text == "" && imageView.image == nil {

            // アラートを出す
            let alertController = UIAlertController(title: "投稿エラー", message: "投稿内容がありません。", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            // 途中で処理を終了したいときはその場でreturn
            return
        }

        // Realmに保存
        let post = Post.create()
        post.name = "自分"
        post.date = Date()
        post.text = postTextView.text
        // if let文は繋げられる
        if let image = imageView.image {
            // jpgの形式にしてサイズをなるべく小さくしたものを保存（16MB以上だとRealmに保存できないため）
            post.imageData = image.jpegData(compressionQuality: 0.2)
        }
        post.save()

        // Firebaseに保存
        /// RealtimeDatabaseの大元
        let databaseRoot = Database.database().reference()
        /// Storageの大元
        let storageRoot = Storage.storage().reference()

        if let data = post.imageData {

            // 画像名を決定するためにまずデータを保存する場所を予め作っておく
            let postPlace = databaseRoot.child((Auth.auth().currentUser?.uid)!).childByAutoId()
            let imageName = postPlace.key! + ".png"
            storageRoot.child("images").child(imageName).putData(data, metadata: nil, completion: { [weak self] metadata, error in

                guard let self = self else { return }

                if let error = error {

                    let alertController = UIAlertController(title: "アップロードエラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    return
                }

                storageRoot.child("images").child(imageName).downloadURL(completion: { url, error in

                    databaseRoot.child((Auth.auth().currentUser?.uid)!).childByAutoId().setValue([
                        "user": (Auth.auth().currentUser?.uid)!,
                        "text": post.text,
                        "date": post.dateString,
                        "imagePath": url?.absoluteString ?? ""
                        ])
                    self.dismiss(animated: true, completion: nil)
                })
            })
        } else {

            // なければそのまま画像以外を保存する
            // ユーザーごとの場所に投稿が保存されていくかたちにする
            // ログインされていない場合投稿されるのはおかしいのでわざと強制アンラップにする
            databaseRoot.child((Auth.auth().currentUser?.uid)!).childByAutoId().setValue([
                "user": (Auth.auth().currentUser?.uid)!,
                "text": post.text,
                "date": post.dateString,
                "imagePath": ""
                ])
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func touchUpInsideCancelButton(_ sender: Any) {

        // 編集されていた場合（UXの工場のため）
        if postTextView.text != "" || imageView.image != nil {

            // アラートを出す
            let alertController = UIAlertController(title: "変更内容の破棄", message: "変更内容を破棄しますか?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in

                // 循環参照というものを防ぐためなるべく行う [weak self]とセットの処理
                // （メンバーにはやらせなくてもいい）
                guard let self = self else { return }

                // この中身はPostViewControllerの外側なので必ずselfが必要
                self.dismiss(animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        } else {

            dismiss(animated: true, completion: nil)
        }
    }
}

// Delegateなどはextensionにまとめると綺麗
// （メンバーには実力に応じてインプットする事項）
extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let image = info[.originalImage] as? UIImage {

            imageView.image = image
            // タイトルを空っぽにする
            // （今回は一度設定したら必ずその画像の投稿になる想定）
            addButton.setTitle("", for: .normal)
        }
        // UIImagePickerControllerを閉じる処理
        dismiss(animated: true, completion: nil)
    }
}
