import SwiftUI
import Combine

public enum PixelSpriteType: String, CaseIterable, Sendable {
    case cat
    case ghost
    case star
}

struct PixelSpriteFrame: Sendable {
    let rows: [String]
}

struct PixelSpriteDefinition: Sendable {
    let frame1: PixelSpriteFrame
    let frame2: PixelSpriteFrame
}

struct PixelSpriteView: View {
    let spriteType: PixelSpriteType
    @State private var useFrame2 = false
    
    private let timer = Timer.publish(every: 0.6, on: .main, in: .common).autoconnect()
    
    var body: some View {
        let definition = spriteDefinitions[spriteType] ?? spriteDefinitions[.cat]!
        let activeFrame = useFrame2 ? definition.frame2 : definition.frame1
        
        VStack(spacing: 1.5) {
            ForEach(0..<activeFrame.rows.count, id: \.self) { rowIndex in
                let row = activeFrame.rows[rowIndex]
                HStack(spacing: 1.5) {
                    ForEach(0..<row.count, id: \.self) { colIndex in
                        let char = row[row.index(row.startIndex, offsetBy: colIndex)]
                        pixelColor(for: char)
                            .frame(width: 1.8, height: 1.8)
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            useFrame2.toggle()
        }
    }
    
    private func pixelColor(for char: Character) -> Color {
        switch char {
        case "w": // White outline/body
            return Color.white
        case "k": // Charcoal/Dark outline
            return Color(white: 0.2)
        case "e": // Eye blue
            return Color(red: 0.25, green: 0.65, blue: 1.0)
        case "g": // Ghost purple/pink
            return Color(red: 0.95, green: 0.42, blue: 0.72)
        case "y": // Star yellow
            return Color(red: 1.0, green: 0.88, blue: 0.3)
        case "o": // Cat orange
            return Color(red: 0.98, green: 0.62, blue: 0.26)
        case "p": // Pink cheeks/details
            return Color(red: 1.0, green: 0.65, blue: 0.72)
        default:
            return Color.clear
        }
    }
}

// 12x12 Pixel Sprite Definitions
private let spriteDefinitions: [PixelSpriteType: PixelSpriteDefinition] = [
    .cat: PixelSpriteDefinition(
        frame1: PixelSpriteFrame(rows: [
            "  w     w   ",
            " www   www  ",
            " w w   w w  ",
            "wwwwwwwwwwww",
            "w o e o e o ",
            "wwwwwwwwwwww",
            " wwwwwwww p ",
            "  wwwwww p  ",
            "  wwwwwww   ",
            " w wwwwww w ",
            "ww wwwww ww ",
            "ww       ww "
        ]),
        frame2: PixelSpriteFrame(rows: [
            "  w     w   ",
            " www   www  ",
            " w w   w w  ",
            "wwwwwwwwwwww",
            "w o e o   o ", // winking
            "wwwwwwwwwwww",
            " wwwwwwww p ",
            "  wwwwww p  ",
            "  wwwwwww w ", // tail up
            " w wwwww ww ",
            "ww wwwww w  ",
            "ww       w  "
        ])
    ),
    .ghost: PixelSpriteDefinition(
        frame1: PixelSpriteFrame(rows: [
            "    wwww    ",
            "  gggggggg  ",
            " gggggggggg ",
            "ggeggggegggg",
            "ggkggggkgggg",
            "gggggggggggg",
            "gggggggggggg",
            "gggggggggggg",
            "gggggggggggg",
            "gggggggggggg",
            "g g g g g g ",
            "  k   k   k "
        ]),
        frame2: PixelSpriteFrame(rows: [
            "    wwww    ",
            "  gggggggg  ",
            " gggggggggg ",
            "ggeggggegggg",
            "ggkggggkgggg",
            "gggggggggggg",
            "gggggggggggg",
            "gggggggggggg",
            "gggggggggggg",
            "gggggggggggg",
            " g g g g g  ",
            " k   k   k  "
        ])
    ),
    .star: PixelSpriteDefinition(
        frame1: PixelSpriteFrame(rows: [
            "     yy     ",
            "    yyyy    ",
            "    yyyy    ",
            " yyyyyyyyyy ",
            "  yyyyyyyy  ",
            "   yyyyyy   ",
            "  yyyyyyyy  ",
            " yyyyyyyyyy ",
            " yy      yy ",
            " y        y ",
            "            ",
            "            "
        ]),
        frame2: PixelSpriteFrame(rows: [
            "            ",
            "     yy     ",
            "    yyyy    ",
            "   yyyyyy   ",
            " yyyyyyyyyy ",
            "  yyyyyyyy  ",
            "   yyyyyy   ",
            "  yyyyyyyy  ",
            " yyyyyyyyyy ",
            "   yyyyyy   ",
            "    yyyy    ",
            "     yy     "
        ])
    )
]
