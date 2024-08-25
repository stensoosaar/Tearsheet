import Charts
import SwiftUI
import TabularData



public struct TearsheetView: View {
  
	private enum ViewState {
		case fetching(Error?)
		case loaded(DataFrame)
	}
  
	let model: Tearsheet
	
	@State private var header = ViewState.fetching(nil)
	@State private var performance = ViewState.fetching(nil)
	@State private var groupedRetuens = ViewState.fetching(nil)
	@State private var greeks = ViewState.fetching(nil)
	@State private var distributions = ViewState.fetching(nil)

	public init(model: Tearsheet) {
		self.model = model
	}

	public var body: some View {
		
		VStack{
			
			Group {
				switch header {
				case .loaded(let dataFrame):
					HeaderView(dataFrame: dataFrame)
				case .fetching(nil):
					ProgressView { Text("Fetching Data") }
				case .fetching(let error?):
					ErrorView(title: "Query Failed", error: error)
				}
			}
			.padding()
			.task {
				do {
					let frame = try model.header()
					self.header = .loaded(frame)
				} catch {
					self.header = .fetching(error)
				}
			}
			

			Group {
				switch performance {
				case .loaded(let dataFrame):
					VStack (alignment: .leading, spacing: 30){
						PerformanceChart(dataframe: dataFrame)
							.frame(height: 400)
						DrawdownChart(dataframe: dataFrame)
							.frame(height: 300)

					}
				case .fetching(nil):
					ProgressView { Text("Fetching Data") }
				case .fetching(let error?):
					ErrorView(title: "Query Failed", error: error)
				}
			}
			.padding()
			.task {
				do {
					let frame = try model.performance()
					self.performance = .loaded(frame)
				} catch {
					self.performance = .fetching(error)
				}
			}
			
			Group {
				switch groupedRetuens {
				case .loaded(let dataFrame):
					GroupedReturnsChart(dataframe: dataFrame)
						.frame(height: 300)
				case .fetching(nil):
					ProgressView { Text("Fetching Data") }
				case .fetching(let error?):
					ErrorView(title: "Query Failed", error: error)
				}
			}
			.padding()
			.task {
				do {
					let frame = try model.groupedReturns()
					self.groupedRetuens = .loaded(frame)
				} catch {
					self.groupedRetuens = .fetching(error)
				}
			}
			
			Group {
				switch distributions {
				case .loaded(let dataFrame):
					VStack {
						DistributionChart(dataframe: dataFrame)
							.frame(height: 200)

					}
				case .fetching(nil):
					ProgressView { Text("Fetching Data") }
				case .fetching(let error?):
					ErrorView(title: "Query Failed", error: error)
				}
			}
			.padding()
			.task {
				do {
					let frame = try model.distribution()
					self.distributions = .loaded(frame)
				} catch {
					self.distributions = .fetching(error)
				}
			}
			
			Group {
				switch greeks {
				case .loaded(let dataFrame):
					VStack {
						GreeksChart(dataframe: dataFrame)
							.frame(height: 150)

					}
				case .fetching(nil):
					ProgressView { Text("Fetching Data") }
				case .fetching(let error?):
					ErrorView(title: "Query Failed", error: error)
				}
			}
			.padding()
			.task {
				do {
					let frame = try model.greeks()
					self.greeks = .loaded(frame)
				} catch {
					self.greeks = .fetching(error)
				}
			}
		}
	}
}





