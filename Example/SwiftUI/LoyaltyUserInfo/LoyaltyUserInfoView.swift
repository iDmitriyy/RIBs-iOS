//
//  LoyaltyUserInfoView.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 05.05.2025.
//

import RIBs

// import Observation
import SwiftUI

struct LoyaltyCardFormView: View {
  @Bindable var model: TestScreenDataModel
  
  @State private var score = 0
  
  init(model: TestScreenDataModel) {
    self.model = model
  }
  
  var body: some View {
    ScrollView {
      TextField("FirstName", text: $model.firstName)
      
      TextField("LastName", text: $model.lastName)
      
      TextField("Enter your score", value: $score, formatter: formatter, onEditingChanged: { isEditing in print(isEditing) })
        .keyboardType(.decimalPad)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()
      
      Text("Eula text")
      Toggle(isOn: $model.isSubscriptionConsent) {
        "Accept"
      }
    }
  }
  
  let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
  }()
}

#Preview {
  LoyaltyCardFormView(model: TestScreenDataModel())
}
