func calculateGrade(score: Int) -> String {
    if score >= 0 && score <= 100 {
        if score >= 90 {
            return "A"
        } else if score >= 80 {
            return "B"
        } else if score >= 70 {
            return "C"
        } else if score >= 60 {
            return "D"
        } else {
            return "F"
        }
    } else {
        return "Invalid score"
    }
}

// 解消例

//func calculateGrade(score: Int) -> String {
//    guard score >= 0 && score <= 100 else {
//        return "Invalid score"
//    }
//
//    switch score {
//    case 90...100: return "A"
//    case 80..<90:  return "B"
//    case 70..<80:  return "C"
//    case 60..<70:  return "D"
//    default:       return "F"
//    }
//}
