//
//  MyPageView.swift
//  NotiPet
//
//  Created by 정근호 on 11/15/23.
//

import SwiftUI

struct MyPageView: View {
    @State var isPresented: Bool = false
    
    var body: some View {
        VStack {
            Text("MyPageView")
            Button(action: {
                isPresented.toggle()
            }) {
                Image(systemName: "gearshape.fill")
                    .imageScale(.large)
                    .foregroundColor(.blue)
            }
            .fullScreenCover(isPresented: $isPresented, content: {
                PetInfoView(isPresented: $isPresented)
            })
        }
        
    }
}

#Preview {
    MyPageView()
}
