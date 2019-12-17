#!/usr/bin/env swift

import Foundation

// コマンドライン引数の解析
func parseArguments() -> String? {
    let arguments: [String] = CommandLine.arguments

    guard let pathIndex = arguments.firstIndex(of: "--path"),
        pathIndex + 1 < arguments.count else {
        print("Usage: auto-add-mark.swift --path FILE_PATH")
        return nil
    }

    return arguments[pathIndex + 1]
}

// ファイルにMARKコメントを追加
func addMarkComments(to filePath: String) throws {
    let fileURL = URL(fileURLWithPath: filePath)

    // ファイルを読み込む
    let contents = try String(contentsOf: fileURL, encoding: .utf8)

    // 既にMARKコメントが存在するかチェック
    let markPattern = #"\n\/\/ MARK.*\n"#
    let markRegex = try NSRegularExpression(pattern: markPattern)
    let range = NSRange(contents.startIndex..<contents.endIndex, in: contents)

    if markRegex.firstMatch(in: contents, range: range) != nil {
        // 既にMARKコメントが存在する場合は何もしない
        return
    }

    // extension宣言にMARKコメントを追加
    let extensionPattern = #"\nextension ([^:]+): ([^{]+) \{"#
    let extensionRegex = try NSRegularExpression(pattern: extensionPattern)

    let editedContents = extensionRegex.stringByReplacingMatches(
        in: contents,
        range: range,
        withTemplate: "\n// MARK: - $2\nextension $1: $2 {"
    )

    // ファイルに書き込む
    try editedContents.write(to: fileURL, atomically: true, encoding: .utf8)
}

// メイン処理
guard let filePath = parseArguments() else {
    exit(1)
}

do {
    try addMarkComments(to: filePath)
} catch {
    print("Error: \(error.localizedDescription)")
    exit(1)
}

