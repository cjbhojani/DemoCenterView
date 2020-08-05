//
//  ContentView.swift
//  SwiftUIIndicator
//
//  Created by Chirag Bhojani on 8/5/20.
//  Copyright © 2020 Chirag Bhojani. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CenterView()
    }
}

struct CenteredLoadingView<rootView: View>: View {
    private let rootViewController: rootView
    @Binding var isActive: Bool

    init(rootView: rootView, isActive: Binding<Bool>) {
        self.rootViewController = rootView
        self._isActive = isActive
    }

    var body: some View {
        rootViewController
            .background(Activator(isLoading: $isActive))
    }

    struct Activator: UIViewRepresentable {
        @Binding var isLoading: Bool
        @State private var currentWindow: UIWindow? = nil

        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            DispatchQueue.main.async {
                self.currentWindow = view.window
            }
            return view
        }

        func updateUIView(_ uiView: UIView, context: Context) {
            guard let holder = currentWindow?.rootViewController?.view else { return }

            if isLoading && context.coordinator.controller == nil {
                context.coordinator.controller = UIHostingController(rootView: loadingView)

                let view = context.coordinator.controller!.view
                view?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                view?.translatesAutoresizingMaskIntoConstraints = false
                holder.addSubview(view!)
                holder.isUserInteractionEnabled = false

                view?.leadingAnchor.constraint(equalTo: holder.leadingAnchor).isActive = true
                view?.trailingAnchor.constraint(equalTo: holder.trailingAnchor).isActive = true
                view?.topAnchor.constraint(equalTo: holder.topAnchor).isActive = true
                view?.bottomAnchor.constraint(equalTo: holder.bottomAnchor).isActive = true
            } else if !isLoading {
                context.coordinator.controller?.view.removeFromSuperview()
                context.coordinator.controller = nil
                holder.isUserInteractionEnabled = true
            }
        }

        func makeCoordinator() -> Coordinator {
            Coordinator()
        }

        class Coordinator {
            var controller: UIViewController? = nil
        }

        private var loadingView: some View {
            VStack {
                Color.white
                    .frame(width: 48, height: 72)
                Text("Loading")
                    .foregroundColor(.white)
            }
                .frame(width: 142, height: 142)
                .background(Color.primary.opacity(0.7))
                .cornerRadius(10)
        }
    }
}

struct CenterView: View {
    @State private var isLoading = false
    var body: some View {
        return VStack {
            Color.gray
            HStack {
                CenteredLoadingView(rootView: list, isActive: $isLoading)
                otherList
            }
            Button("Demo", action: load)
        }
        .onAppear(perform: load)
    }

    func load() {
        self.isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
        }
    }

    var list: some View {
        List {
            ForEach(1..<6) {
                Text($0.description)
            }
        }
    }

    var otherList: some View {
        List {
            ForEach(6..<11) {
                Text($0.description)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
