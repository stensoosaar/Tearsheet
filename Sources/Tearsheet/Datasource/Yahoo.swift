import Foundation
import DuckDB



public enum YahooFinance: String{
	
	case spx 		= "^SPX"
	case ndx 		= "^NDX"
	case ftse 		= "^FTSE"
	case eStoxx50 	= "^STOXX50E"
	case dax 		= "^FGAXI"
	case djia 		= "^DJI"
	
	public func getURL(for interval: DateInterval) ->URL{
		var host = "https://query1.finance.yahoo.com/v7/finance/download/\(self.rawValue)"
		host += "?period1=\(Int(interval.start.timeIntervalSince1970))"
		host += "&period2=\(Int(interval.end.timeIntervalSince1970))"
		host += "&interval=1d&events=history&includeAdjustedClose=true"
		guard let url = URL(string: host) else { fatalError("failed to load prices for \(self.rawValue)") }
		return url
	}
	
}
