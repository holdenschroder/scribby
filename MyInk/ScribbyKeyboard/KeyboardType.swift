enum KeyboardType {
    case lower
    case shifted
    case capsLock
    case numeric
    case symbols

    var shiftKeyType: KeyboardButtonType {
        switch self {
        case .lower:
            return .switchToKeyboardTypes([.shifted, .capsLock], "⇧")
        case .shifted:
            return .switchToKeyboardTypes([.lower, .capsLock], "⬆")
        case .capsLock:
            return .switchToKeyboardTypes([.lower], "⇪")
        case .numeric:
            return .switchToKeyboardTypes([.symbols], "#+=")
        case .symbols:
            return .switchToKeyboardTypes([.numeric], "123")
        }
    }

    var switchKeyType: KeyboardButtonType {
        switch self {
        case .numeric, .symbols:
            return .switchToKeyboardTypes([.lower], "ABC")
        default:
            return .switchToKeyboardTypes([.numeric], "123")
        }
    }

    private var characters: [[String]] {
        var result: [[String]]
        switch self {
        case .lower:
            result = KeyboardType.alphaCharacters(shifted: false)
        case .shifted, .capsLock:
            result = KeyboardType.alphaCharacters(shifted: true)
        case .numeric:
            result = [
                ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
                ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
                [".", ",", "?", "!", "'"]
            ]
        case .symbols:
            result = [
                ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
                ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"],
                [".", ",", "?", "!", "'"]
            ]
        }
        return result
    }

    static let spaceString = "space"

    private static func alphaCharacters(shifted: Bool) -> [[String]] {
        let letters = [
            ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
            ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
            ["Z", "X", "C", "V", "B", "N", "M"]
        ]
        if shifted { return letters }
        return letters.map { row in
            return row.map { letter in
                return letter.lowercased()
            }
        }
    }

    var buttonTypes: [[KeyboardButtonType]] {
        var result: [[KeyboardButtonType]] = characters.map { row in
            return row.map { c in
                return .character(c)
            }
        }
        result[2] = [shiftKeyType] + result[2] + [.backspace]
        result.append([switchKeyType, .nextKeyboard, .space, .returnOrDone("return")])
        return result
    }
}
