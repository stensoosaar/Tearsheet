import Tearsheet
import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true


Task{
	do {
		
		guard let url = Bundle.main.url(forResource: "sample", withExtension: "csv") else {fatalError("Bad url")}
		let tearsheet = try await Tearsheet.analyze(contentsOfCSVFile: url, benchmark: YahooFinance.spx)
		
		let view = TearsheetView(model: tearsheet)
			.frame(width: 900, height: 1800)

		PlaygroundPage.current.setLiveView(view)
		
	} catch {
		print(error)
	}
	
}
