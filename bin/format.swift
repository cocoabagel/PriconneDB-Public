#!/usr/bin/env swift

/* fdのインストールが必要 brew install fd */
import Foundation

@discardableResult
func shell(_ command: String) -> Int32 {
    let args = command.components(separatedBy: " ")

    let process = Process()
    process.launchPath = "/usr/bin/env"
    process.arguments = args
    process.launch()
    process.waitUntilExit()

    return process.terminationStatus
}

var filePath: String?

var swiftLintConfig = ".swiftlint.autocorrect.yml"
var swiftFormatConfig = ".swiftformat"
var swiftVersion = ProcessInfo.processInfo.environment["PROJECT_SWIFT_VERSION"] ?? "5.10"

var shouldRunSwiftlint = true
var shouldRunSwiftFormat = true

let args = ProcessInfo.processInfo.arguments
let _ = args.enumerated().forEach { index, arg in
    switch arg {
    case "--path", "-p":
        filePath = args[index + 1]

    case "--swiftlint-config", "-slc":
        swiftLintConfig = args[index + 1]

    case "--swiftformat-config", "-sfc":
        swiftFormatConfig = args[index + 1]

    case "--swiftversion":
        swiftVersion = args[index + 1]

    case "--swiftlint-only", "-sl":
        shouldRunSwiftFormat = false

    case "--swiftformat-only", "-sf":
        shouldRunSwiftlint = false

    default:
        break
    }
}

guard let filePath else {
    print("Missing --path/-p flag"); exit(1)
}

if shouldRunSwiftFormat {
    let swiftformat = "swiftformat"
    shell("\(swiftformat) \(filePath) --config \(swiftFormatConfig) --swiftversion \(swiftVersion)")
}

guard shouldRunSwiftlint else { exit(0) }

print("Running Swiftlint Autocorrect")

let swiftlint = "swiftlint"
let isSingleFile = filePath.hasSuffix(".swift")

if isSingleFile {
    shell("\(swiftlint) --fix --format --config \(swiftLintConfig) \(filePath)")
} else {
    shell("fd . --full-path \(filePath) -e swift -x \(swiftlint) --fix --format --config \(swiftLintConfig) {}")
}
