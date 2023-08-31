//
//  ContentView.swift
//  CombinePOC
//
//  Created by Quin Design on 25/07/2023.
//

import SwiftUI
import Combine
import AVKit

struct ContentView: View {
    @State var dataUser: UserData? = nil
    @ObservedObject private var userViewModel = UserViewModel()
    var systemSoundID : SystemSoundID = 1013
    
    var body: some View {
        VStack {
            Spacer()
            ScrollView{
                if let data = userViewModel.userData?.users,data.count > 0 {
                    
                    ForEach(0..<(data.count),id:\.self) { datum in
                        NavigationLink(destination: ListDetailPage(user: data[datum])){
                            UserCard(user: data[datum])
                        }
                        Divider()
                    }
                } else {
                    Spacer()
                    Text("NO DATA FOUND").bold()
                    Spacer()
                }
            }
        }
        .padding()
        .onAppear{
            self.userViewModel.getUsers()
        }
        
    }
}

//struct ContentView_Previews: PreviewProvider {
//static var previews: some View {
//    ContentView()
//}
//}




class ViewModel: ObservableObject {
    @Published var count = 0
    @Published var countDec = 0
}

struct ContentViews: View {
    @StateObject private var viewModel = ViewModel()
    @State private var cancellables = Set<AnyCancellable>()
    
    
    var body: some View {
        VStack {
            Text("Count: \(viewModel.count)")
            Text("Count: \(viewModel.countDec)")
            Button("Increment") {
                viewModel.count += 1
                viewModel.countDec -= 1
            }
        }
        .onAppear {
            viewModel.$countDec
                .sink { newValue in
                    print("New count: \(newValue)")
                }
                .store(in: &cancellables)
        }
    }
}

protocol PersonProtocol {
    
    var firstName: String {get set}
    var lastName: String {get set}
    func getFullName() -> String
}

struct SomeStruct: PersonProtocol {
    var firstName: String
    var lastName: String
    
    func getFullName() -> String {
        
        return firstName + " " + lastName
    }
}

struct SomeView: View {
    
    private var dev = SomeStruct(firstName: "uday", lastName: "kc")
    private  var testDict: [String: Double] = ["USD:": 10.0, "EUR:": 10.0, "ILS:": 10.0,"USD1:": 10.0, "EUR1:": 10.0, "ILS1:": 10.0,"USD2:": 10.0, "EUR2:": 10.0, "ILS2:": 10.0,"USD3:": 10.0, "EUR3:": 10.0, "ILS3:": 10.0,"USD4:": 10.0, "EUR4:": 10.0, "ILS4:": 10.0]
    
    var body: some View {
        
        VStack{
            
            Text("\(dev.getFullName())")
                .underline(color: .gray)
            
            ForEach(testDict.keys.sorted(), id: \.self) { key in
                HStack {
                    Text(key == "ILS:" ? "India": key)
                    Text(key == "ILS:" ? "\(100.0)" : "\(testDict[key] ?? 1.0)")
                }
            }
        }
    }
}



struct DetailView: View {
   // var model: MyModel
    @State var selectedTab = 0
    
    var body: some View {
        HStack{
//        Button {
//            selectedTab -= 1
//        } label: {
//            Text("<")
//                .font(Font.headline)
//                .bold()
            
       // }.disabled(selectedTab == 0)
        TabView(selection: $selectedTab) {
            ForEach(0...7,id: \.self) { i in
                HStack(spacing: 15){
                    
                    
                    Text("Helmet \(i)")
                        .frame(width: 250,height: 250)
                        .background(SwiftUI.Color.red)
                        .cornerRadius(20)
                    
                }
            }
        }.tabViewStyle(.page)
            .onChange(of: selectedTab) { newValue in
                AudioServicesPlaySystemSoundWithCompletion(1157, nil)
                
            }
//        Button {
//            selectedTab += 1
//        } label: {
//            Text(">")
//                .font(Font.headline)
//                .bold()
//        }.disabled(selectedTab == 7)
    }
    }
}
struct Item: Identifiable {
    var id: Int
    var title: String
    var color: SwiftUI.Color
}

class Store: ObservableObject {
    @Published var items: [Item]
    
    let colors: [SwiftUI.Color] = [.red, .orange, .blue, .teal, .mint, .green, .gray, .indigo, .black]

    // dummy data
    init() {
        items = []
        for i in 0...7 {
            let new = Item(id: i, title: "Item \(i)", color: colors[i])
            items.append(new)
        }
    }
}


struct SnapContentView: View {
    
    @StateObject var store = Store()
    @State private var snappedItem = 0.0
    @State private var draggingItem = 0.0
    
    var body: some View {
        
        ZStack {
            ForEach(store.items) { item in
                
                // article view
                HStack {
                   
                        RoundedRectangle(cornerRadius: 18)
                            .fill(item.color)
                       
                    
                }
                .frame(width: 200, height: 200)
                .scaleEffect(1.0 - abs(distance(item.id)) * 0.2 )
                .opacity(1.0 - abs(distance(item.id)) * 0.3 )
                .offset(x: myXOffset(item.id), y: 0)
                .zIndex(1.0 - abs(distance(item.id)) * 0.1)
                .onAppear{
                    print("id==\(item.id)")
                }
                .padding()
                
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    draggingItem = snappedItem + value.translation.width / 100
                    AudioServicesPlaySystemSoundWithCompletion(1157, nil)
                }
                .onEnded { value in
                   withAnimation {
                        draggingItem = snappedItem + value.predictedEndTranslation.width / 100
                        draggingItem = round(draggingItem).remainder(dividingBy: Double(store.items.count))
                        snappedItem = draggingItem
                    }
                }
        )
    }
    
    func distance(_ item: Int) -> Double {
        return (draggingItem - Double(item)).remainder(dividingBy: Double(store.items.count))
    }
    
    func myXOffset(_ item: Int) -> Double {
        let angle = Double.pi * 2 / Double(store.items.count) * distance(item)
        return sin(angle) * 200
    }
    
}
struct SnapContentView_Previews: PreviewProvider {
    static var previews: some View {
        SnapContentView()
    }
}

struct UserCard : View {
    var user : User
    
    var body: some View {
        HStack(spacing: 10){
            AsyncImage(url: URL(string: user.image)) { image in
                image
                    .resizable()
                    .frame(width: 100,height: 100)
                    .aspectRatio(contentMode: .fit)
                    .background(Gradient(colors: [SwiftUI.Color.red,SwiftUI.Color.white,SwiftUI.Color.green]))
                    .cornerRadius(10)
                
            } placeholder: {
                ProgressView()
            }
            VStack(alignment: .leading,spacing: 5){
                (Text(user.firstName)+Text(" ")+Text(
                    (user.lastName)))
                Text(user.birthDate)
                Text(user.bloodGroup)
                Text(user.gender.rawValue)
            }.foregroundColor(.white)
            Spacer()
        }
        
    }
}
