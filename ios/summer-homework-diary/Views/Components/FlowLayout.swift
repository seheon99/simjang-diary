import SwiftUI

struct FlowLayout: Layout {
    struct Arrangement {
        let origins: [CGPoint]
        let size: CGSize
    }

    let spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        arrangement(for: subviews, width: proposal.width ?? .infinity).size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let arrangement = Self.arrange(
            sizes: sizes,
            width: bounds.width,
            spacing: spacing
        )

        for index in subviews.indices {
            let origin = arrangement.origins[index]
            let size = sizes[index]
            subviews[index].place(
                at: CGPoint(
                    x: bounds.minX + origin.x,
                    y: bounds.minY + origin.y
                ),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
        }
    }

    static func arrange(
        sizes: [CGSize],
        width: CGFloat,
        spacing: CGFloat
    ) -> Arrangement {
        var origins: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var usedWidth: CGFloat = 0
        var rowIsEmpty = true

        for size in sizes {
            if !rowIsEmpty, x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
                rowIsEmpty = true
            }

            origins.append(CGPoint(x: x, y: y))
            usedWidth = max(usedWidth, x + size.width)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            rowIsEmpty = false
        }

        return Arrangement(
            origins: origins,
            size: CGSize(
                width: usedWidth,
                height: sizes.isEmpty ? 0 : y + rowHeight
            )
        )
    }

    private func arrangement(for subviews: Subviews, width: CGFloat) -> Arrangement {
        Self.arrange(
            sizes: subviews.map { $0.sizeThatFits(.unspecified) },
            width: width,
            spacing: spacing
        )
    }
}
