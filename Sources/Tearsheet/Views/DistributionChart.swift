//
//  DistributionChart.swift
//  Tearsheet
//
//  Created by Sten Soosaar on 25.08.2024.
//

import Charts
import TabularData
import SwiftUI


public struct DistributionChart: View {
	
	private struct Blaah: Identifiable{
		var id = UUID()
		var name: String
		var count: Int
	}
	
	let dataframe: DataFrame
	
	private var rows : [Blaah] {
		var selection = dataframe.selecting(columnNames: "return_range", "count")
		selection.combineColumns(ColumnID("return_range",String.self), ColumnID("count",Int.self), into: "value") { (name, value) -> Blaah? in
			guard let name = name, let value = value else {return nil}
			return Blaah(name: name, count: value)
		}
		
		return selection["value"].compactMap({$0}) as [Blaah]
	}
	
	public init(dataframe: DataFrame) {
		self.dataframe = dataframe
	}

	public var body: some View {
		VStack(alignment: .leading) {
			Text("Returns distribution")
				.font(.headline)
				
			Chart(rows, id: \.id){ row in
				BarMark(
					x: .value("Name", row.name),
					yStart:.value("Strategy", 0),
					yEnd: .value("Strategy", row.count)
				)
				.opacity(0.85)
			}
			
		}
	}
}
