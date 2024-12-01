func categorizeValue(value: Int) -> String {
    if value < 0 {
        return "Negative"
    } else if value == 0 {
        return "Zero"
    } else {
        switch value {
        case 1...10:
            return "Small"
        case 11...100:
            return "Medium"
        default:
            for i in 0..<value {
                if i % 2 == 0 && i % 3 == 0 {
                    return "Special"
                }
            }
            return "Large"
        }
    }
}

// 解消例

//func categorizeValue(_ value: Int) -> String {
//    guard value >= 0 else { return "Negative" }
//    if value == 0 { return "Zero" }
//    return sizeCategory(for: value)
//}
//
//func sizeCategory(for value: Int) -> String {
//    switch value {
//    case 1...10: return "Small"
//    case 11...100: return "Medium"
//    default: return isSpecial(value) ? "Special" : "Large"
//    }
//}
//
//func isSpecial(_ value: Int) -> Bool {
//    for i in 0..<value where i % 2 == 0 && i % 3 == 0 {
//        return true
//    }
//    return false
//}
