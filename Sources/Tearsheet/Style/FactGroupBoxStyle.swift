//
//  File.swift
//  
//
//  Created by Sten Soosaar on 13.12.2023.
//

import SwiftUI


public struct FactGroupBoxStyle: GroupBoxStyle {
	
	public init(){}

	public func makeBody(configuration: Configuration) -> some View {
		VStack(alignment: .leading) {
			
			configuration.label
				.font(.subheadline)
				.foregroundColor(.secondary)
			
			configuration.content
				.font(.title)
				.foregroundColor(.primary)

		}
	}
	
}
