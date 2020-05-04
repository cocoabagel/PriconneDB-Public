# PriconneDB

プリンセスコネクトのアリーナ編成共有アプリ

## 概要

プリンセスコネクトRe:Dive 内のゲーム内コンテンツである
バトルアリーナをもっと楽に毎日楽しくするのための編成記録管理アプリです

現在、リン（レンジャー）までのデータに対応しています

## スクショ

![](images/app.png)

## 技術的な話

データは Firebase Cloud Firestore を使用しクラウドのDBで管理します、検索処理のためにアプリ同期後 In Memory で動作させている Realm にインポートさせています。

作成・更新時に Realm を更新し Firebae Firestore にも反映されます。

Firestoreへメタデータ投入のスクリプトをpythonで書きました。

自前の環境を立ち上げる際は参考にしてください。

## 利用方法

1. Xcode 11.3 インストール

2. cocoapodsのインストール(オプション)
   
   ```
   $ sudo gem install cocoapods
   ```

3. ライブラリのインストール(オプション)
   
   ```
   $ pod install
   ```

4. ビルド & 実行

## 自前環境構築

1. Firebaseに新規プロジェクトを作成

2. `GoogleService-Info.plist`を自前の環境に置き換え

3. サービスアカウントの秘密鍵を発行し、`script/`に配置

4. metadata.py の`priconnedb-public-firebase-adminsdk-irxy5-587932f0e0.json`部分を3で配置したものに変更

5. メタデータ投入Pythonスクリプトを実行する(ここではpython3として実行)
   
   ```
   $ cd script/
   $ python3 metadata.py
   ```
