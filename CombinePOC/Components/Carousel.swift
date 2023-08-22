//
//  Carousel.swift
//  CombinePOC
//
//  Created by Quin Design on 09/08/2023.
//

import SwiftUI
import AVFoundation

struct Carousel: View {
    @State private var currentIndex:Int = 0
    @GestureState private var dragOffset: CGFloat = 0
    @State private var colors:[SwiftUI.Color] = [.red,.green,.yellow,.brown,.cyan]
    @State private var isLoading:Bool = true
    
    var body: some View {
        VStack{
            ZStack{
                ForEach(0..<colors.count,id: \.self){ i in
                    
                    RoundedRectangle(cornerRadius: 25)
                        .fill(colors[i])
                        .frame(width: 250, height: 320)
                        .opacity(currentIndex == i ? 1.0 : 0.25)
                        .scaleEffect(currentIndex == i ? 1.1 : 0.8)
                        .offset(x: CGFloat(i - currentIndex) * 250 + dragOffset,y : 0)
                        .padding()
                    Image("ghostPhantom")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .opacity(currentIndex == i ? 1.0 : 0.25)
                        .scaleEffect(currentIndex == i ? 1.0 : 0.4)
                        .offset(x: CGFloat(i - currentIndex) * 200 + dragOffset,y : 0)
                        .padding()
                        .redacted(reason: isLoading ? .placeholder : [])
                       ////.animatePlaceholder(isLoading: $isLoading)
                }
                
            }
            .gesture(
                DragGesture()
                    .onEnded({ val in
                        AudioServicesPlaySystemSoundWithCompletion(1157,nil)
                        let threshold: CGFloat = 50
                        if val.translation.width > threshold {
                            withAnimation {
                                    currentIndex = max(0,currentIndex - 1)
                                    print("ci==\(currentIndex)==\(val.translation.width)")
                            }
                        }else if val.translation.width < -threshold {
                            withAnimation {
                                if currentIndex != colors.count - 1 {
                                    currentIndex = min(colors.count,currentIndex + 1)
                                    print("ci==1\(currentIndex)==\(val.translation.width)")
                                }
                            }
                        }
                    })
            )
        }
        //.animatePlaceholder(isLoading: $isLoading)
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now()+2.5){
                    isLoading = false
                }
            }
            .toast(message: "Please wait, Loading...",
                        isShowing: $isLoading,
                        duration: Toast.long)
    }
}

struct Carousel_Previews: PreviewProvider {
    static var previews: some View {
        Carousel()
    }
}


struct AnimatePlaceholderModifier: AnimatableModifier {
    @Binding var isLoading: Bool

    @State private var isAnim: Bool = false
    private var center = (UIScreen.main.bounds.width / 2) + 110
    private let animation: Animation = .linear(duration: 1.5)

    init(isLoading: Binding<Bool>) {
        self._isLoading = isLoading
    }

    func body(content: Content) -> some View {
        content.overlay(animView.mask(content))
    }

    var animView: some View {
        ZStack {
            SwiftUI.Color.black.opacity(isLoading ? 0.09 : 0.0)
            SwiftUI.Color.white.mask(
                Rectangle()
                    .fill(
                        LinearGradient(gradient: .init(colors: [.clear, .white.opacity(0.48), .clear]), startPoint: .top , endPoint: .bottom)
                    )
                    .scaleEffect(1.5)
                    .rotationEffect(.init(degrees: 70.0))
                    .offset(x: isAnim ? center : -center)
            )
        }
        .animation(isLoading ? animation.repeatForever(autoreverses: false) : nil, value: isAnim)
        .onAppear {
            guard isLoading else { return }
            isAnim.toggle()
        }
        .onChange(of: isLoading) { _ in
            isAnim.toggle()
        }
    }
}
extension View {
    func animatePlaceholder(isLoading: Binding<Bool>) -> some View {
        self.modifier(AnimatePlaceholderModifier(isLoading: isLoading))
    }
}
