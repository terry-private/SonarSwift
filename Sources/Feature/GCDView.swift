import SwiftUI
import SonarSwift

struct GCDView: View {
    @State private var leftText: String = ""
    @State private var rightText: String = ""
    private var result: Int? {
        guard let left = Int(leftText), let right = Int(rightText) else {
            return nil
        }
        return gcd(left, right)
    }
    init() {}
    var body: some View {
        VStack {
            HStack {
                input($leftText)
                input($rightText)
            }
            .padding()
            if let result {
                Text("最大公約数は \(result) です")
            }

        }
        .navigationTitle("GCD")
    }
    func input(_ text: Binding<String>) -> some View {
        VStack {
            TextField("数値", text: text)
                .textFieldStyle(.roundedBorder)
            let isInvalid = !text.wrappedValue.isEmpty && Int(text.wrappedValue) == nil
            Text("数値を記入してください")
                .lineLimit(1)
                .font(.caption)
                .minimumScaleFactor(0.1)
                .foregroundStyle(isInvalid ? .red : .clear)
        }
        .padding()
        .background()
    }
}

#Preview {
    GCDView()
}
