import CoreGraphics

@main
struct FlowLayoutCheck {
    static func main() {
        let arrangement = FlowLayout.arrange(
            sizes: [
                CGSize(width: 60, height: 20),
                CGSize(width: 35, height: 30),
                CGSize(width: 40, height: 10),
            ],
            width: 110,
            spacing: 8
        )

        assert(arrangement.origins == [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 68, y: 0),
            CGPoint(x: 0, y: 38),
        ])
        assert(arrangement.size == CGSize(width: 103, height: 48))
    }
}
