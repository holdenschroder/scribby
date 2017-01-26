import UIKit
struct KeyboardButtonInfo {
    let widthMultiplier: CGFloat
    let alignment: NSTextAlignment
    let buttonType: KeyboardButtonType

    init(buttonType: KeyboardButtonType, widthMultiplier: CGFloat = 1, alignment: NSTextAlignment = .center) {
        self.buttonType = buttonType
        self.widthMultiplier = widthMultiplier
        self.alignment = alignment
    }
}

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

    private var _characters: [[String]] {
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

    private func buttonInfosForTopOrSecondRow(characters: [String]) -> [KeyboardButtonInfo] {
        var result = [KeyboardButtonInfo]()
        if characters.count < 10 {
            let topIndex = characters.count - 1
            result.append(KeyboardButtonInfo(buttonType: .character(characters[0]), widthMultiplier: 1.5, alignment: .right))
            for i in 1..<topIndex {
                result.append(KeyboardButtonInfo(buttonType: .character(characters[i])))
            }
            result.append(KeyboardButtonInfo(buttonType: .character(characters[topIndex]), widthMultiplier: 1.5, alignment: .left))
        } else {
            result = characters.map {
                return KeyboardButtonInfo(buttonType: .character($0))
            }
        }
        return result
    }

    private func buttonInfosForThirdRow(characters: [String]) -> [KeyboardButtonInfo] {
        var result = [KeyboardButtonInfo(buttonType: shiftKeyType, widthMultiplier: 1.5)]
        let multiplier: CGFloat = 7.0 / characters.count

        for c in characters {
            result.append(KeyboardButtonInfo(buttonType: .character(c), widthMultiplier: multiplier))
        }

        result.append(KeyboardButtonInfo(buttonType: .backspace, widthMultiplier: 1.5))
        return result
    }

    private func buttonInfosForFourthRow() -> [KeyboardButtonInfo] {
        return [
            KeyboardButtonInfo(buttonType: switchKeyType, widthMultiplier: 1.5),
            KeyboardButtonInfo(buttonType: .nextKeyboard, widthMultiplier: 1.5),
            KeyboardButtonInfo(buttonType: .space, widthMultiplier: 4.0),
            KeyboardButtonInfo(buttonType: .returnOrDone("return"), widthMultiplier: 3.0)
        ]
    }

    var buttonInfos: [[KeyboardButtonInfo]] {
        let characters = _characters
        return [
            buttonInfosForTopOrSecondRow(characters: characters[0]),
            buttonInfosForTopOrSecondRow(characters: characters[1]),
            buttonInfosForThirdRow(characters: characters[2]),
            buttonInfosForFourthRow()
        ]
    }
}
