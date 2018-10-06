# RealmFirebaseSample

RealmとFirebaseを使った出来る限りシンプルにしたサンプルです。

- コメントで解説を一部付けています
- 想定としては画像つきの簡易SNSです。ベースは[この記事](https://qiita.com/ShinokiRyosei/items/f71c73ab8b0de145c5bc)です
- 適宜コメントと記事を確認しながら必要な部分を参考にするかたちで使用しましょう。

## Firebaseの設定情報

- FirebaseのAuthはEmail認証にしました
- Databaseのルールは以下ようしてあります。

```
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

Storageは以下です。

```
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

これらは認証をしたユーザーのみがアクセスできるようになっています。

その他、画像はStorageに、その他のデータはRealtime Databaseを利用するように書きました。

### Database

key=userID
|- key=childByAutoID
    |- date ... 日付
    |- imagePath ... 画像のダウンロードリンク
    |- text ... 本文
    |- user ... userID

### Storage

images直下に(投稿のkey).pngとい名前で保存
