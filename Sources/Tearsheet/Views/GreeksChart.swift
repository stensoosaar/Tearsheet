//
//  GreeksChart.swift
//  Tearsheet
//
//  Created by Sten Soosaar on 24.08.2024.
//



import Charts
import TabularData
import SwiftUI


public struct GreeksChart: View {
	
	let dataframe: DataFrame
	
	
	private var content: DataFrame {
		return dataframe.selecting(columnNames: "sharpe", "sortino")
	}	
	
	public init(dataframe: DataFrame) {
		self.dataframe = dataframe
	}

	public var body: some View {
		VStack(alignment: .leading) {
			Text("Risk-Reward Ratios")
				.font(.headline)
				
			Chart(content.columns, id: \.name){

				BarMark(
					x: .value("Value", $0[0] as? Double ?? 0),
					y: .value("Name", $0.name)
				)
				.foregroundStyle(
					.linearGradient(
						stops:[
							Gradient.Stop(color: .red, location: 0 / ($0[0] as? Double ?? 1)),
							Gradient.Stop(color: .yellow, location: 1 / ($0[0] as? Double ?? 1)),
							Gradient.Stop(color: .green, location: 2 / ($0[0] as? Double ?? 1)),

						],
						startPoint: .leading,
						endPoint: .trailing)
				)
				.opacity(0.85)
				.zIndex(1)
			}
			
		}
	}
}


