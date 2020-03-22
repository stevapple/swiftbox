import Foundation
#if os(Linux)
func hello() -> String {
    return "Hello world! "
}
#endif
print(hello())
