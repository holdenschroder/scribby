import UIKit
struct KeyboardButtonInfo {
    let widthMultiplier: CGFloat
    let alignment: NSTextAlignment
    let buttonType: KeyboardButtonType
    let backgroundColor: UIColor

    init(buttonType: KeyboardButtonType, widthMultiplier: CGFloat = 1, backgroundColor: UIColor? = nil, alignment: NSTextAlignment = .center) {
        self.buttonType = buttonType
        self.widthMultiplier = widthMultiplier
        self.alignment = alignment
        self.backgroundColor = backgroundColor ?? UIColor(hue: 0.1, saturation: 0.07, brightness: 1, alpha: 1)
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
    static let grayBackground = UIColor(white: 0.8, alpha: 1)

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
        let functionButtonWidthMultiplier: CGFloat = 1.35
        var result = [KeyboardButtonInfo(buttonType: shiftKeyType, widthMultiplier: functionButtonWidthMultiplier, backgroundColor: KeyboardType.grayBackground)]
        let multiplier: CGFloat = (10 - functionButtonWidthMultiplier * 2) / characters.count

        for c in characters {
            result.append(KeyboardButtonInfo(buttonType: .character(c), widthMultiplier: multiplier))
        }

        result.append(KeyboardButtonInfo(buttonType: .backspace, widthMultiplier: functionButtonWidthMultiplier, backgroundColor: KeyboardType.grayBackground))
        return result
    }

    private func buttonInfosForFourthRow() -> [KeyboardButtonInfo] {
        return [
            KeyboardButtonInfo(buttonType: switchKeyType, widthMultiplier: 1.3, backgroundColor: KeyboardType.grayBackground),
            KeyboardButtonInfo(buttonType: .nextKeyboard, widthMultiplier: 1.0),
            KeyboardButtonInfo(buttonType: .space, widthMultiplier: 5.1),
            KeyboardButtonInfo(buttonType: .returnOrDone("return"), widthMultiplier: 2.6, backgroundColor: KeyboardType.grayBackground)
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
