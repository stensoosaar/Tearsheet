//
//  HeaderView.swift
//  Tearsheet
//
//  Created by Sten Soosaar on 24.08.2024.
//

import SwiftUI
import TabularData


public struct HeaderView: View {
	
	var dataFrame: DataFrame
	
	public init(dataFrame: DataFrame) {
		self.dataFrame = dataFrame
	}
	
	public var body: some View {
		
		VStack(alignment: .leading, spacing: 20){
			
			HStack(spacing: 30) {
				GroupBox("Net Assets"){
					Text("\(dataFrame["net_assets"][0] as? Double ?? 0, specifier: "%.2f")")
				}.groupBoxStyle(FactGroupBoxStyle())
				
				GroupBox("Change"){
					HStack(spacing: 20){
						Text("\(dataFrame["gain"][0] as? Double ?? 0, specifier: "%.2f")")
						Text("\(dataFrame["total_return"][0] as? Double ?? 0, specifier: "%.2f")%")
					}
				}.groupBoxStyle(FactGroupBoxStyle())
				
				Spacer()
				
				GroupBox("CAGR"){
					Text("\(dataFrame["cagr"][0] as? Double ?? 0, specifier: "%.2f")%")
				}.groupBoxStyle(FactGroupBoxStyle())
				
			}
			
		}
		

	}
	
	
}
