//
//  ListDDetailPage.swift
//  CombinePOC
//
//  Created by Quin Design on 02/08/2023.
//

import SwiftUI

struct ListDetailPage: View {
    @Environment (\.dismiss) private var dismiss
    @GestureState private var dragOffset = CGSize.zero

    var user: User?
    var body: some View {
        VStack{
            if let data = user {
                ZStack{
                    AsyncImage(url: URL(string: data.image )) { image in
                        image
                            .resizable()
                            .frame(width: UIScreen.main.bounds.size.width/2,height: UIScreen.main.bounds.size.height/2.5)
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                }.frame(width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height/2)
                
                VStack(alignment: .leading,spacing: 10){
                    (Text("Name: ")+Text(data.firstName)+Text(" ")+Text(
                        (data.lastName)))
                    (Text("DOB: ")+Text(data.birthDate))
                    (Text("BG: ")+Text(data.bloodGroup))
                    (Text("Gender: ")+Text(data.gender.rawValue))
                    (Text("Mac Address: ")+Text(data.macAddress))
                    (Text("University: ")+Text(data.university)).multilineTextAlignment(.leading)
                    (Text("City: ")+Text(data.address.city ?? ""))
                    (Text("PostalCode: ")+Text(data.address.postalCode))
                    (Text("Phone: ")+Text(data.phone))
                    Spacer()
                }.foregroundColor(.white)
                    .padding()
                    .bold()
                    .frame(width: UIScreen.main.bounds.size.width/1.15,alignment: .leading)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .offset(y: -50)
            } else {
                Text("NO DATA")
            }
        }.background(Gradient(colors: [SwiftUI.Color.red,SwiftUI.Color.white,SwiftUI.Color.green]))
//            .gesture(DragGesture().updating($dragOffset, body: { (value, state, transaction) in
//
//                        if(value.startLocation.x < 20 && value.translation.width > 100) {
//                            withAnimation {
//                                dismiss()
//                            }
//
//                        }
//
//                    }))
//
//         .navigationBarBackButtonHidden(true)
//                       .navigationBarItems(leading: Button(action : {
//                         dismiss()
//                       }){
//                           Image(systemName: "arrow.left")
//                       })
    }
}

