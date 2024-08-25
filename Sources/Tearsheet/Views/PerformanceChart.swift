//
//  PerformanceChart.swift
//  Tearsheet
//
//  Created by Sten Soosaar on 24.08.2024.
//

import SwiftUI
import TabularData
import Charts


public struct PerformanceChart: View {
	
	let dataframe: DataFrame
	
	public init(dataframe: DataFrame) {
		self.dataframe = dataframe
	}
	
	private var rows : [ChartPoint] {
		
		var strategy = dataframe.selecting(columnNames: "date", "strategy_cumulative")
		strategy.combineColumns(ColumnID("date",Date.self), ColumnID("strategy_cumulative",Double.self), into: "value") { (date, value) -> ChartPoint? in
			guard let date = date, let value = value else {return nil}
			return ChartPoint(name: "strategy", date: date, value: value)
		}
		
		var benchmark = dataframe.selecting(columnNames: "date", "benchmark_cumulative")
		benchmark.combineColumns(ColumnID("date",Date.self), ColumnID("benchmark_cumulative",Double.self), into: "value") { (date, value) -> ChartPoint? in
			guard let date = date, let value = value else {return nil}
			return ChartPoint(name: "benchmark", date: date, value: value)
		}
		
		let a = strategy["value"].compactMap({$0}) as [ChartPoint]
		let b = benchmark["value"].compactMap({$0}) as [ChartPoint]

		
		return zip(a, b).flatMap({[$0, $1]})
	}

	public var body: some View {
		VStack{
			VStack(alignment: .leading, spacing: 10){
				
				Text("Performance")
					.font(.headline)

				Chart(rows, id: \.date) {
					
					LineMark(
						x: .value("Date", $0.date, unit: .day),
						y: .value("Return", $0.value)
					)
					.foregroundStyle(by: .value("name", $0.name))
					.lineStyle(StrokeStyle.init(lineWidth: 2))
					
				}
				.chartXAxis{
					AxisMarks{
						AxisGridLine()
					}
				}
				.chartYAxis{
					AxisMarks{
						AxisGridLine()
						AxisValueLabel()
							.offset(x:10)
					}
				}
				.chartLegend(position: .top, alignment: .leading, spacing: 8)
			}
		}
	}
}




