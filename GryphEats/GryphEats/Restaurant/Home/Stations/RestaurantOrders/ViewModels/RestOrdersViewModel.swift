//
//  RestOrdersViewModel.swift
//  GryphEats
//
//  Created by Matthew Bebis on 10/23/19.
//  Copyright © 2019 The Subway Squad. All rights reserved.
//

import Apollo
import SwiftUI

// MARK: - RestOrdersViewModel

class RestOrdersViewModel: ObservableObject {
    
    // MARK: Lifecycle
    
    init(restID: String) {
        self.restID = restID
    }
    
    deinit {
        cancelSubscription()
    }
    
    // MARK: Internal
    
    @Published private(set) var loadingState: LoadingState<[Order]> = .loading
    var restID: String
    
    func fetchOrders() {
        loadingState = .loading
        
        GraphClient.shared.fetch(query: OrdersByRestQuery(restID: restID)) { result in
            switch result {
            case .success(let data):
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .none
                // US English Locale (en_US)
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
                dateFormatter.amSymbol = "am"
                dateFormatter.pmSymbol = "pm"
                
                var orders: [Order] = []
                
                for order in data.getOrdersByRestaurantId.compactMap({ $0 }) {
                    var foodItems: [RestaurantFoodItem] = []
                    for orderItem in (order.orderitems.compactMap({ $0 })) {
                        foodItems.append(RestaurantFoodItem(
                            foodItem: GraphFoodItem(
                                id: orderItem.foodid,
                                name: orderItem.item.fragments.foodItemDetails.name,
                                price: orderItem.item.fragments.foodItemDetails.price),
                            restaurantId: order.restaurantid,
                            restaurantName: "TODO"))
                    }
                    let date = order.timeplaced
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
                    let dateParsed = dateFormatter.date(from: date)
                    dateFormatter.dateFormat = "h:mma MMM dd, yyyy"
                    let dateString = dateFormatter.string(from: dateParsed!)
                    orders.append(Order(
                        id: order.orderid,
                        restaurantID: order.restaurantid,
                        customer: Customer(name: "John Doe"),
                        status: order.ordertype,
                        timePlaced: dateString,
                        items: foodItems
                    ))
                }
                self.loadingState = .loaded(orders)
            case .failure:
                self.loadingState = .error
            }
        }
        
        subscription = GraphClient.shared.subscribe(
            subscription: OrderUpdatedSubscription(restaurantID: restID))
        { result in
            switch result {
            case .success(let data):
                
                guard let orders2 = data.orderUpdated?.compactMap({ $0 }) else {
                    self.loadingState = .error
                    return
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .none
                // US English Locale (en_US)
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
                dateFormatter.amSymbol = "am"
                dateFormatter.pmSymbol = "pm"
                
                var orders: [Order] = []
                
                for order in orders2.compactMap({ $0 }) {
                    var foodItems: [RestaurantFoodItem] = []
                    for orderItem in (order.orderitems.compactMap({ $0 })) {
                        foodItems.append(RestaurantFoodItem(
                            foodItem: GraphFoodItem(
                                id: orderItem.foodid,
                                name: orderItem.item.fragments.foodItemDetails.name,
                                price: orderItem.item.fragments.foodItemDetails.price),
                            restaurantId: order.restaurantid,
                            restaurantName: "TODO"))
                    }
                    let date = order.timeplaced
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
                    let dateParsed = dateFormatter.date(from: date)
                    dateFormatter.dateFormat = "h:mma MMM dd, yyyy"
                    let dateString = dateFormatter.string(from: dateParsed!)
                    orders.append(Order(
                        id: order.orderid,
                        restaurantID: order.restaurantid,
                        customer: Customer(name: "John Doe"),
                        status: order.ordertype,
                        timePlaced: dateString,
                        items: foodItems
                    ))
                    
                }
                
                self.loadingState = .loaded(orders)
            case .failure:
                self.loadingState = .error
            }
        }
    }
    
    func cancelSubscription() {
        subscription?.cancel()
        subscription = nil
    }
    
    // MARK: Private
    
    private var subscription: Cancellable?
    
}