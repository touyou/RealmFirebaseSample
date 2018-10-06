//
//  Post.swift
//  RealmFirebaseSample
//
//  Created by 藤井陽介 on 2018/10/06.
//  Copyright © 2018 touyou. All rights reserved.
//

import Foundation
import RealmSwift

/// Realm用にクラスを１つつくる
/// はるふさん（OB）のQiita記事を参考にすると結構使いやすい
/// https://qiita.com/_ha1f/items/593ca4f9c97ae697fc75
class Post: Object {
    /// PrimaryKey用 ... 投稿一つ一つを区別するために用いる値
    @objc dynamic var id = 0
    /// 投稿の本文
    @objc dynamic var text = ""
    /// 投稿者の名前
    @objc dynamic var name = ""
    /// 投稿された日付
    @objc dynamic var date = Date()
    /// 添付された画像
    @objc dynamic var imageData: Data?

    /// 日付を文字列で取得したいときに使う
    var dateString: String {

        get {

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: date)
        }
    }

    /// PrimaryKey
    override static func primaryKey() -> String? {
        return "id"
    }

    // MARK: 便利メソッド集
    // 使っても使わなくてもよい

    /// 新しい投稿を作る
    static func create() -> Post {
        // インスタンス化
        let post = Post()
        // lastId()を使ってidを設定
        post.id = lastId()
        return post
    }

    /// 最後のIDを取ってくる
    static func lastId() -> Int {
        let realm = try! Realm()
        // 投稿のうち最新のもののidを取ってくる
        if let latestPost = realm.objects(Post.self).last {
            return latestPost.id + 1
        } else {
            return 1
        }
    }

    /// すべての投稿を取ってくる
    static func loadAll() -> [Post] {
        let realm = try! Realm()
        // 投稿をidでソートして取得する
        let posts = realm.objects(Post.self).sorted(byKeyPath: "id", ascending: false)
        // 簡単のため配列に変換して返している（場合による）
        return posts.map { $0 }
    }

    /// 自分自身を保存する
    func save() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(self)
        }
    }

    /// 更新の場合
    func update(_ method: () -> Void) {
        let realm = try! Realm()
        try! realm.write {
            method()
        }
    }
}

/// データの読み込み用
/// structを使うとイニシャライザを自分で書かなくてよくなり少し便利
struct PostData {
    var text: String
    var name: String
    var imagePath: URL?
    var dateString: String
    var userId: String
}
