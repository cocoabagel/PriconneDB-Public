import ArgumentParser
import Foundation

@main
struct CheckUnusedCode: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "check-unused-code",
        abstract: "Peripheryを使用して未使用コードをチェックします",
        discussion: """
            PriconneDBプロジェクトの未使用なclass, struct, protocol, method, property等を検出します。
            """
    )

    @Option(name: .shortAndLong, help: "出力フォーマット (xcode, json, csv, checkstyle)")
    var format: OutputFormat = .xcode

    @Option(name: .shortAndLong, help: "対象スキーム")
    var scheme: String = "PriconneDB"

    @Flag(name: .long, help: "静かなモード（結果のみ出力）")
    var quiet: Bool = false

    @Flag(name: .long, help: "警告を厳格モードで扱う")
    var strict: Bool = false

    @Flag(name: .long, help: "冗長な出力")
    var verbose: Bool = false

    enum OutputFormat: String, ExpressibleByArgument, CaseIterable {
        case xcode
        case json
        case csv
        case checkstyle
    }

    func run() throws {
        let projectRoot = findProjectRoot()

        if !quiet {
            print("🔍 未使用コードをチェック中...")
            print("   プロジェクト: \(projectRoot)")
            print("   スキーム: \(scheme)")
            print("")
        }

        let result = try runPeriphery(projectRoot: projectRoot)

        if result.exitCode != 0 {
            throw ExitCode(result.exitCode)
        }

        if !quiet, result.unusedCount == 0 {
            print("✅ 未使用コードは見つかりませんでした")
        }
    }

    private func findProjectRoot() -> String {
        let fileManager = FileManager.default
        var currentPath = fileManager.currentDirectoryPath

        while currentPath != "/" {
            let xcodeproj = (currentPath as NSString).appendingPathComponent("PriconneDB.xcodeproj")
            if fileManager.fileExists(atPath: xcodeproj) {
                return currentPath
            }
            currentPath = (currentPath as NSString).deletingLastPathComponent
        }

        // 見つからない場合はカレントディレクトリを返す
        return fileManager.currentDirectoryPath
    }

    private func runPeriphery(projectRoot: String) throws -> PeripheryResult {
        var arguments = [
            "periphery", "scan",
            "--project", "\(projectRoot)/PriconneDB.xcodeproj",
            "--schemes", scheme,
            "--format", format.rawValue,
            "--retain-swift-ui-previews"
        ]

        // インデックスから除外するパス
        let indexExcludes = [
            "**/Mocks/Sources/Generated/**",
            "**/bin/**",
            "**/.build/**"
        ]
        for pattern in indexExcludes {
            arguments.append(contentsOf: ["--index-exclude", pattern])
        }

        // レポートから除外するパス（テストファイル、スタブ等）
        let reportExcludes = [
            "**/*Tests.swift",
            "**/*+Stub.swift",
            "**/*Mock.swift",
            "**/Mocks/**"
        ]
        for pattern in reportExcludes {
            arguments.append(contentsOf: ["--report-exclude", pattern])
        }

        if strict {
            arguments.append("--strict")
        }

        if verbose {
            arguments.append("--verbose")
        }

        if quiet {
            arguments.append("--quiet")
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = arguments
        process.currentDirectoryURL = URL(fileURLWithPath: projectRoot)

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""

        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

        if !output.isEmpty {
            print(output)
        }

        if !errorOutput.isEmpty, !quiet {
            FileHandle.standardError.write(errorData)
        }

        // 未使用コードの数をカウント（xcode形式の場合）
        let unusedCount = output.components(separatedBy: "\n")
            .filter { $0.contains(" is unused") || $0.contains(" is never") }
            .count

        return PeripheryResult(
            exitCode: process.terminationStatus,
            output: output,
            unusedCount: unusedCount
        )
    }
}

struct PeripheryResult {
    let exitCode: Int32
    let output: String
    let unusedCount: Int
}
