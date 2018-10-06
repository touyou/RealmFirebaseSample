//
//  OfflineViewController.swift
//  RealmFirebaseSample
//
//  Created by 藤井陽介 on 2018/10/06.
//  Copyright © 2018 touyou. All rights reserved.
//

import UIKit
import Realm

class OfflineViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {

        didSet {

            tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
        }
    }

    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        posts = Post.loadAll()
        tableView.reloadData()
    }
}

extension OfflineViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PostTableViewCell

        cell.contentLabel.text = posts[indexPath.row].text
        cell.nameLabel.text = posts[indexPath.row].name
        cell.dateLabel.text = posts[indexPath.row].dateString
        if let data = posts[indexPath.row].imageData {
            cell.postImageView.image = UIImage(data: data)
        }
        
        return cell
    }
}
