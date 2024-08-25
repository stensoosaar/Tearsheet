//
//  ErrorView.swift
//  Tearsheet
//
//  Created by Sten Soosaar on 24.08.2024.
//

import SwiftUI


struct ErrorView: View {
  
  let title: String
  let error: Error
  
  init(title: String, error: Error) {
	self.title = title
	self.error = error
  }
  
  var body: some View {
	  VStack(spacing: 8) {
		Text("☠️")
		  .font(.largeTitle)
		Text(title)
		  .font(.subheadline)
		  .foregroundColor(.gray)
		  .fontWeight(.bold)
		Text(error.localizedDescription)
		  .font(.caption)
		  .foregroundColor(.gray)
		
	  }
	  .multilineTextAlignment(.center)
  }
}

