// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct PagingScrollView<T, Content: View>: View {
    private let items: [T]
    @Binding private var selection: Int
    private let content: (T) -> Content
    
    @State private var offset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    
    // 初始化：接收数据列表、当前索引绑定和内容生成闭包
    public init(
        items: [T],
        selection: Binding<Int>,
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.items = items
        self._selection = selection
        self.content = content
    }
    
    // 动画配置
    private let animation = Animation.spring(response: 0.5, dampingFraction: 0.825, blendDuration: 0)
    
    public var body: some View {
        GeometryReader {
            let width = $0.size.width
            
            HStack(spacing: 0) {
                ForEach(0..<items.count, id: \.self) { index in
                    content(items[index])
                        .frame(width: width)
                        .frame(maxHeight: .infinity)
                        .contentShape(.rect)
                }
            }
            .offset(x: offset + dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let dragDistance = value.translation.width
                        
                        // 阻尼效果：处理边界时的滑动
                        if (selection == 0 && dragDistance > 0) ||
                            (selection == items.count - 1 && dragDistance < 0) {
                            dragOffset = dragDistance * 0.5
                        } else {
                            dragOffset = dragDistance
                        }
                    }
                    .onEnded { value in
                        let threshold = width / 8
                        
                        withAnimation(animation) {
                            if value.translation.width < -threshold && selection < items.count - 1 {
                                selection += 1
                            } else if value.translation.width > threshold && selection > 0 {
                                selection -= 1
                            }
                            offset = -CGFloat(selection) * width
                            dragOffset = 0
                        }
                    }
            )
        }
    }
}
