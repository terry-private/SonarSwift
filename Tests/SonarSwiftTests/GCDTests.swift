import Testing
@testable import SonarSwift

struct GCDTests {
    struct NormalCase {
        @Test("2つの正の整数")
        func withPositiveNumbers() {
            #expect(gcd(48, 18) == 6)
            #expect(gcd(25, 100) == 25)
        }

        @Test("2つの負の正数")
        func withNegativeNumbers() {
            #expect(gcd(-48, -18) == 6)
            #expect(gcd(-25, -100) == 25)
        }

        @Test("正負混合")
        func withMixedNumbers() {
            #expect(gcd(48, -18) == 6)
            #expect(gcd(-48, 18) == 6)
            #expect(gcd(-25, 100) == 25)
            #expect(gcd(25, -100) == 25)
        }

        @Test("1を含む")
        func withOne() {
            #expect(gcd(1, 10) == 1)
            #expect(gcd(1, -10) == 1)
            #expect(gcd(10, 1) == 1)
            #expect(gcd(10, -1) == 1)
        }
    }

    struct EdgeCase {
        @Test("0を含む")
        func withZero() {
            // 全ての正数 * 0 = 0となるので0の約数は0以外すべての整数と考える
            #expect(gcd(0, 10) == 10)
            #expect(gcd(0, -10) == 10)
            #expect(gcd(10, 0) == 10)
            #expect(gcd(10, -0) == 10)
        }

        @Test("max & min")
        func withMaxAndMin() {
            #expect(gcd(Int.max, Int.max) == Int.max)
            #expect(gcd(Int.max, -Int.max) == Int.max)
            #expect(gcd(-Int.max, Int.max) == Int.max)
            // Int.minは絶対値がIntの範囲を超えるのでクラッシュします
//            #expect(gcd(Int.min, -Int.min) == Int.min) // Arithmetic operation '0 - -9223372036854775808' (on signed 64-bit integer type) results in an overflow
        }

        @Test("Intの範囲内での最大再帰回数: 92")
        func maxRecursion() {
            // Intの範囲内でフィボナッチ数の最大n, n-1の組み合わせが最大再起回数となる
            let fib91: Int = 4660046610375530309
            let fib92: Int = 7540113804746346429
            #expect(gcd(fib91, fib92) == 1)
        }
    }
}
