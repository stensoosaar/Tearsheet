//
//  GroupedReturnsChart.swift
//  Tearsheet
//
//  Created by Sten Soosaar on 24.08.2024.
//

import Charts
import TabularData
import SwiftUI


public struct GroupedReturnsChart: View {
	
	let dataframe: DataFrame
	
	private var rows : [ChartPoint] {
		var selection = dataframe.selecting(columnNames: "bucket", "strategy_returns")
		selection.combineColumns(ColumnID("bucket",Date.self), ColumnID("strategy_returns",Double.self), into: "value") { (date, value) -> ChartPoint? in
			guard let date = date, let value = value else {return nil}
			return ChartPoint(name: "strategy", date: date, value: value)
		}
		
		return selection["value"].compactMap({$0}) as [ChartPoint]
	}
	
	private var interval: Calendar.Component {
		guard let mean = dataframe.summary(of: "interval")["mean"][0] as? Double else {
			return .month
		}
	
		switch mean {
		case 0...4: 	return .weekOfYear
		case 5...48: 	return .month
		case 49...108: 	return .quarter
		default: 		return .year
		}
	}

	public init(dataframe: DataFrame) {
		self.dataframe = dataframe
	}

	public var body: some View {
		
		VStack(alignment: .leading){
			
			Text("Returns")
				.font(.headline)

			Chart(rows, id: \.date) {row in
					
				BarMark(x: .value("Date", row.date, unit: interval),
					yStart: .value("Strategy", 0),
						yEnd: .value("Strategy", row.value)
				)
					.opacity(0.75)
				}
				.chartYAxis{
					AxisMarks{
						AxisGridLine()
						AxisValueLabel()
							.offset(x:10)
						
					}
				}
				.chartXAxis{
					AxisMarks{
						AxisValueLabel(centered: true)
					}
				}			

		}
	}
}
