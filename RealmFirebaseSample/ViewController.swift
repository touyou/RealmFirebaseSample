//
//  ViewController.swift
//  RealmFirebaseSample
//
//  Created by 藤井陽介 on 2018/10/06.
//  Copyright © 2018 touyou. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {

        // 上級者向け。でもなぜかtableViewのDataSourceが反映されないとかいう場合はここに書いておくと確実
        didSet {

            tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
            tableView.dataSource = self
            // 余分な線を消してくれる
            tableView.tableFooterView = UIView()
        }
    }

    var posts = [PostData]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let databaseRoot = Database.database().reference()

        if Auth.auth().currentUser == nil {

            performSegue(withIdentifier: "toRegister", sender: nil)
        } else {

            databaseRoot.observe(.value, with: { [weak self] snapshots in

                guard let self = self else { return }
                self.posts.removeAll()

                // 二階層になっているのでこの時点ではユーザーごとのデータ
                for users in snapshots.children {

                    let userSnapshot = users as! DataSnapshot

                    // ここで投稿のデータが取れる（databaseRootをobserveしているため）
                    for content in userSnapshot.children {

                        let contentSnapshot = content as! DataSnapshot
                        // 最後はvalueで取ってこれる
                        let value = contentSnapshot.value as! [String: Any]

                        let userId = value["user"] as! String
                        let text = value["text"] as! String
                        let dateString = value["date"] as! String
                        let imagePath = value["imagePath"] as! String

                        let post = PostData(
                            text: text,
                            name: userId == (Auth.auth().currentUser?.uid)! ? "自分" : "他の人",
                            imagePath: imagePath == "" ? nil : URL(string: imagePath),
                            dateString: dateString,
                            userId: userId)
                        self.posts.append(post)
                    }
                }
                self.posts.reverse()
                self.tableView.reloadData()
            })
        }
    }


    @IBAction func pushLogoutButton(_ sender: Any) {

        do {

            try Auth.auth().signOut()
            posts.removeAll()
            tableView.reloadData()
        } catch let error {

            print(error)
        }
    }
}

extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PostTableViewCell

        cell.nameLabel.text = posts[indexPath.row].name
        cell.contentLabel.text = posts[indexPath.row].text
        cell.dateLabel.text = posts[indexPath.row].dateString
        // ネットにある画像はダウンロードに時間がかかるのでこのように非同期画像表示ライブラリを使うと楽だしUX的にもよくなる
        cell.postImageView.kf.setImage(with: posts[indexPath.row].imagePath)

        return cell
    }
}
