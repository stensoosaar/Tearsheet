//
//  DrawdownChart.swift
//  Tearsheet
//
//  Created by Sten Soosaar on 24.08.2024.
//

import Charts
import TabularData
import SwiftUI


public struct DrawdownChart: View {
	
	let dataframe: DataFrame
	
	private var rows : [ChartPoint] {
		var selection = dataframe.selecting(columnNames: "date", "drawdown")
		selection.combineColumns(ColumnID("date",Date.self), ColumnID("drawdown",Double.self), into: "value") { (date, value) -> ChartPoint? in
			guard let date = date, let value = value else {return nil}
			return ChartPoint(name: "strategy", date: date, value: value)
		}
		
		return selection["value"].compactMap({$0}) as [ChartPoint]
	}

	public init(dataframe: DataFrame) {
		self.dataframe = dataframe
	}

	public var body: some View {
		VStack(alignment: .leading, spacing: 10){
			
			Text("Drawdowns")
				.font(.headline)

			Chart(rows, id: \.date) {
				
				AreaMark(
					x: .value("Date", $0.date, unit: .day),
					y: .value("Strategy", $0.value)
				)
				.foregroundStyle(
					.linearGradient(
						colors:[
							.red.opacity(0.85),
							.red.opacity(0.15)
						],
						startPoint: .bottom,
						endPoint: .top
					)
				)

				LineMark(
					x: .value("Date", $0.date, unit: .day),
					y: .value("Strategy", $0.value)
				)
				.lineStyle(StrokeStyle.init(lineWidth: 1))
				.foregroundStyle(Color.white)
				.offset( CGSize(width: 0, height: 1))
				
			}
			.chartYAxis{
				AxisMarks{
					AxisGridLine()
					AxisValueLabel()
						.offset(x:10)
				}
			}
		}
	}
}
