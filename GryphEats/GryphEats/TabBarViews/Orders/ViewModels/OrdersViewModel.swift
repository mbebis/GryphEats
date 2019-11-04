//
//  OrdersViewModel.swift
//  GryphEats
//
//  Created by Domenic Bianchi on 2019-11-01.
//  Copyright © 2019 The Subway Squad. All rights reserved.
//

import Foundation

// MARK: - OrdersViewModel

class OrdersViewModel: ObservableObject {
    
    // MARK: Internal
    
    @Published private(set) var loadingState: LoadingState<[Order]> = .loading
    
    func fetchOrders() {
        loadingState = .loading
        
        GraphClient.shared.fetch(query: UserOrdersQuery(userID: "1")) { result in
            switch result {
            case .success(let data):
                self.loadingState = .loaded(data.getOrdersByUserId.compactMap({ $0 }).map { order in
                    Order(
                        id: order.id,
                        customer: Customer(name: ""),
                        status: Order.Status(rawValue: order.status) ?? .new,
                        timePlaced: order.timePlaced,
                        items: order.items.map { item in
                            RestaurantFoodItem(
                                foodItem: item.item.fragments.foodItemDetails,
                                restaurantId: order.restaurantId,
                                restaurantName: "") // TODO: Need restaurant name
                    })
                })
            case .failure:
                self.loadingState = .error
            }
        }
    }
}