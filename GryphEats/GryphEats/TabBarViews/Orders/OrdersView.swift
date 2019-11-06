//
//  OrdersView.swift
//  GryphEats
//
//  Created by Domenic Bianchi on 2019-10-23.
//  Copyright © 2019 The Subway Squad. All rights reserved.
//

import SwiftUI

// MARK: - OrdersView

struct OrdersView: View {
    
    // MARK: Internal
    
    /** NOTE ABOUT A COUPLE OF SWIFTUI BUGS
     
     1) For the `.sheet` modifying, if I use `.constant($selectedOrder.wrappedValue != nil)` for `isPresented`, the view
     will present fine but will NOT dismiss. I have no idea why this is happening and I'm just assuming it's a bug since
     just using `$showSelectedOrder` works fine.
     
     2) When dismissing the presented sheet, `onDismiss` only fires if the sheet is dismissed using the default swipe
     gesture. If the view is dismissed using the `presentationMode`, `onDismiss` is not called. Due to this bug, I just
     pass a custom handler into the presented view that will be reliably called all the time when needed.
     */
    
    var body: some View {
        NavigationHeaderView(
            title: "Orders",
            navigationColor: .guelphYellow,
            contentBackgroundColor: .lightGray)
        {
            self.content
        }.sheet(isPresented: $showSelectedOrder) {
            OrderTrackingView(order: self.selectedOrder!) {
                self.viewModel.fetchOrders(userID: self.loggedInUser.id)
            }
        }.onAppear {
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().backgroundColor = .lightGray
            self.viewModel.fetchOrders(userID: self.loggedInUser.id)
        }
    }
    
    // MARK: Private
    
    @State private var selectedOrder: Order? = nil
    @State private var showSelectedOrder: Bool = false
    @ObservedObject private var viewModel = OrdersViewModel()
    @EnvironmentObject private var loggedInUser: User
    
    private var content: AnyView {
        switch viewModel.loadingState {
        case .loading:
            return AnyView(ActivityIndicatorView())
        case .loaded(let orders):
            // Swift UI Bug: `listRowBackground` and `listRowInsets` do not work without nesting a `ForEach` within
            // `List`
            return AnyView(List {
                ForEach(orders) { order in
                    OrderHistoryCard(order: order).onTapGesture {
                        self.selectedOrder = order
                        self.showSelectedOrder = true
                    }
                }.listConfiguration(backgroundColor: Color.lightGray)
            }.navigationBarItems(trailing: self.trailingNavigationBarItems))
        case .error:
            return AnyView(ErrorView(infoText: "Whoops! We could not fetch your orders.", buttonText: "Try Again") {
                self.viewModel.fetchOrders(userID: self.loggedInUser.id)
            })
        }
    }
    
    private var trailingNavigationBarItems: some View {
        Button(action: {
            self.viewModel.fetchOrders(userID: self.loggedInUser.id)
        }) {
            Image(systemName: "arrow.2.circlepath")
                .padding(.all, 10)
                .foregroundColor(.black)
        }
    }
}

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersView().environmentObject(User(id: "1", type: .customer, username: "", password: ""))
    }
}
