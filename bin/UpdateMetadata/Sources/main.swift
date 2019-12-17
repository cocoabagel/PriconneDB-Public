//
//  main.swift
//  UpdateMetadata
//
//  ユニットメタデータをFirestoreに更新するスクリプト
//
//  使用方法:
//    cd bin/UpdateMetadata
//    swift run UpdateMetadata [--delete-all] [--dry-run]
//
//  オプション:
//    --delete-all  既存のユニットデータを全削除してから追加
//    --dry-run     実際には書き込まず、処理内容を表示のみ
//

import FirebaseCore
import FirebaseFirestore
import Foundation

// MARK: - Configuration

struct Config {
    let deleteAll: Bool
    let dryRun: Bool

    init(arguments: [String]) {
        deleteAll = arguments.contains("--delete-all")
        dryRun = arguments.contains("--dry-run")
    }
}

// MARK: - Main

@main
struct UpdateMetadata {
    static func main() async {
        let config = Config(arguments: CommandLine.arguments)

        print("========================================")
        print("  PriconneDB Unit Metadata Updater")
        print("========================================")
        print("")

        if config.dryRun {
            print("[DRY RUN MODE] 実際の書き込みは行いません")
            print("")
        }

        // Firebase初期化
        // GoogleService-Info.plistがカレントディレクトリまたはプロジェクトルートにある必要があります
        guard initializeFirebase() else {
            print("Error: Firebase初期化に失敗しました")
            print("GoogleService-Info.plistが正しく配置されているか確認してください")
            exit(1)
        }

        let db = Firestore.firestore()

        // 既存データ削除
        if config.deleteAll {
            print("既存ユニットデータを削除中...")
            if !config.dryRun {
                await deleteAllUnits(db: db)
            }
            print("削除完了")
            print("")
        }

        // ユニットデータ追加
        print("ユニットデータを追加中...")
        print("対象ユニット数: \(UnitData.units.count)")
        print("")

        if !config.dryRun {
            await createUnits(db: db, units: UnitData.units)
        } else {
            for unit in UnitData.units {
                print("  [DRY RUN] 追加: \(unit.name) (position: \(unit.position))")
            }
        }

        print("")
        print("========================================")
        print("  完了!")
        print("========================================")
    }

    static func initializeFirebase() -> Bool {
        // 環境変数からplistパスを取得
        if let envPath = ProcessInfo.processInfo.environment["GOOGLE_SERVICE_INFO_PLIST"] {
            if FileManager.default.fileExists(atPath: envPath) {
                guard let options = FirebaseOptions(contentsOfFile: envPath) else {
                    print("Error: GoogleService-Info.plistの読み込みに失敗しました: \(envPath)")
                    return false
                }
                FirebaseApp.configure(options: options)
                print("Firebase初期化完了: \(envPath)")
                return true
            } else {
                print("Error: 指定されたplistが見つかりません: \(envPath)")
                return false
            }
        }

        // フォールバック: 相対パスを探す
        let possiblePaths = [
            "./GoogleService-Info.plist",
            "../../GoogleService-Info.plist",
            "../../../PriconneDB/GoogleService-Info.plist"
        ]

        for path in possiblePaths {
            let url = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: url.path) {
                guard let options = FirebaseOptions(contentsOfFile: url.path) else {
                    continue
                }
                FirebaseApp.configure(options: options)
                print("Firebase初期化完了: \(url.path)")
                return true
            }
        }

        // デフォルト初期化を試みる
        if let defaultPlistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let options = FirebaseOptions(contentsOfFile: defaultPlistPath)
        {
            FirebaseApp.configure(options: options)
            print("Firebase初期化完了 (Bundle)")
            return true
        }

        return false
    }

    static func deleteAllUnits(db: Firestore) async {
        do {
            let snapshot = try await db.collection("units").getDocuments()
            print("  削除対象: \(snapshot.documents.count)件")

            for document in snapshot.documents {
                try await db.collection("units").document(document.documentID).delete()
                print("  削除: \(document.documentID)")
            }
        } catch {
            print("Error: 削除中にエラーが発生しました: \(error)")
        }
    }

    static func createUnits(db: Firestore, units: [Unit]) async {
        var successCount = 0
        var errorCount = 0

        for unit in units {
            do {
                _ = try await db.collection("units").addDocument(data: unit.toAnyObject)
                print("  追加: \(unit.name)")
                successCount += 1
            } catch {
                print("  Error: \(unit.name) の追加に失敗: \(error)")
                errorCount += 1
            }
        }

        print("")
        print("結果: 成功 \(successCount)件, 失敗 \(errorCount)件")
    }
}
