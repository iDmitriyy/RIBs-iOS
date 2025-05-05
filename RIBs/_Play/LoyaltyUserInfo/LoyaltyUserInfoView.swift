//
//  LoyaltyUserInfoView.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 05.05.2025.
//

import Observation
import SwiftUI

struct TestView: View {
  @Bindable var model: TestScreenDataModel
  
  init(model: TestScreenDataModel) {
    self.model = model
  }
  
  var body: some View {
    TextField("Name", text: $model.nameText)
  }
}

#Preview {
  TestView(model: TestScreenDataModel())
}


