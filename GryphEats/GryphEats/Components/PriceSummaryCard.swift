//
//  PriceSummaryCard.swift
//  GryphEats
//
//  Created by Domenic Bianchi on 2019-10-15.
//  Copyright © 2019 The Subway Squad. All rights reserved.
//

import SwiftUI

// MARK: - PriceSummaryCard

struct PriceSummaryCard: View {
    
    // MARK: DisplayMode
    
    enum DisplayMode {
        /// Use this to show a summary of the subtotal, tax, and total of the cart, as well as potential discounts by using your student card meal plan.
        case full
        /// Use this to show a summary of the subtotal, tax, and total of the cart if using an on campus meal plan. This will also show a "Pay" button.
        case onCampusMealPlan
        /// Use this to show a summary of the subtotal, tax, and total of the cart if using an ultra meal plan. This will also show a "Pay" button.
        case ultraMealPlan
    }
    
    // MARK: PaymentAction
    
    enum PaymentAction {
        case studentCard
        case credit
        case confirmPayment
    }
    
    // MARK: Lifecycle
    
    init(displayMode: DisplayMode = .full, action: @escaping (PaymentAction) -> Void) {
        self.displayMode = displayMode
        self.action = action
    }
    
    // MARK: Internal
    
    var body: some View {
        let subtotal = cart.subtotal()
        let tax = cart.tax()
        
        return VStack {
            HStack {
                Text("Subtotal").bold()
                Spacer()
                Text(subtotal.asDollarString)
            }.padding(.top, 20)
                .padding(.bottom, 5)
                .padding(.horizontal)
            
            if displayMode == .full || displayMode == .onCampusMealPlan {
                discountRow(type: .onCampus, amount: (subtotal - cart.subtotal(for: .onCampus)).asDollarString)
            }
            
            if displayMode == .full || displayMode == .ultraMealPlan {
                discountRow(type: .offCampus, amount: (subtotal - cart.subtotal(for: .offCampus)).asDollarString)
            }
            
            HStack {
                Text("Tax (13% HST)").bold()
                Spacer()
                Text(tax.asDollarString)
            }.padding(.vertical, 5)
                .padding(.horizontal)
            
            if displayMode == .full || displayMode == .onCampusMealPlan {
                discountRow(type: .onCampusTax, amount: (tax - cart.tax(for: .onCampus)).asDollarString)
            }
            
            if displayMode == .full || displayMode == .ultraMealPlan {
                discountRow(type: .offCampusTax, amount: (tax - cart.tax(for: .offCampus)).asDollarString)
            }
            
            HStack {
                Text("Total").bold()
                Spacer()
                Text(cart.total().asDollarString)
            }.padding(.vertical, 5)
                .padding(.horizontal)
                .foregroundColor(.guelphRed)
            
            if displayMode == .full || displayMode == .onCampusMealPlan {
                discountRow(type: .onCampusTotal, amount: cart.total(for: .onCampus).asDollarString)
            }
            
            if displayMode == .full || displayMode == .ultraMealPlan {
                discountRow(type: .offCampusTotal, amount: cart.total(for: .offCampus).asDollarString)
            }
            
            if displayMode == .full {
                Text("Meal Plan discounts are only valid if you pay with your student card.")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                HStack {
                    Spacer()
                    ApplePayButton().frame(height: 47)
                    Spacer()
                }.padding(.horizontal, 10)
                    .cornerRadius(5)
                
                ActionButton(text: "Checkout with Student Card", backgroundColor: .guelphRed, foregroundColor: .white) {
                    withAnimation {
                        self.action(.studentCard)
                    }
                }.padding(.top, 10)
                
                ActionButton(text: "Other Checkout Options") {
                    withAnimation {
                        self.action(.credit)
                    }
                }.padding(.top, 10)
                    .padding(.bottom, 20)
            } else if displayMode == .onCampusMealPlan || displayMode == .ultraMealPlan {
                ActionButton(
                    text: "Pay \(cart.total(for: displayMode == .onCampusMealPlan ? .onCampus : .offCampus).asDollarString)",
                    backgroundColor: .guelphRed,
                    foregroundColor: .white)
                {
                    self.action(.confirmPayment)
                }.padding(.vertical)
            }
        }.font(.system(size: 14))
            .background(Color.white)
            .cornerRadius(5)
            .padding(.all, 10)
            .shadow(radius: 2)
    }
    
    // MARK: Private
    
    @EnvironmentObject private var cart: Cart
    
    private let action: (PaymentAction) -> Void
    private let displayMode: DisplayMode
    
    private func discountRow(type: DiscountType, amount: String) -> some View {
        HStack {
            Text(type.rawValue)
                .padding(.leading, 20)
            Spacer()
            
            if type == .onCampusTotal || type == .offCampusTotal {
                Text(amount).foregroundColor(.guelphRed)
            } else {
                Text("-" + amount)
            }
        }.font(.system(size: 10))
            .padding(.horizontal)
            .padding(.bottom, 10)
            .foregroundColor(.secondary)
    }
    
    private enum DiscountType: String {
        case onCampus = "With On-Campus Meal Plan (30% discount)"
        case onCampusTax = "With On-Campus Meal Plan (No Tax)"
        case onCampusTotal = "With On-Campus Meal Plan"
        
        case offCampus = "With Ultra Meal Plan (10% discount)"
        case offCampusTax = "With Ultra Meal Plan (5% tax discount)"
        case offCampusTotal = "With Ultra Meal Plan"
    }
}

struct PriceSummaryCard_Previews: PreviewProvider {
    static var previews: some View {
        PriceSummaryCard(displayMode: .onCampusMealPlan, action: { _ in }).environmentObject(Cart())
    }
}
