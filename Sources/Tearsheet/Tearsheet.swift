//
//  File.swift
//  
//
//  Created by Sten Soosaar on 14.11.2023.
//

import Foundation
import TabularData
import DuckDB


public final class Tearsheet: Sendable {
	
	let database: Database
	let connection: Connection
	
	
	private init(database: Database, connection: Connection) throws  {
		self.database = database
		self.connection = connection
		
		try self.connection.execute("""
			CREATE VIEW performance AS
				WITH 
				strategy_data AS (
					SELECT
						date,
						cash_flow,
						LAG(end_balance) OVER (ORDER BY date) AS previous_balance,
						cash_flow,
						end_balance,
						date - LAG(date) OVER (ORDER BY date) AS date_diff
					FROM strategy),
				strategy_returns AS (
					SELECT
						date,
						cash_flow,
						end_balance,
						(end_balance - previous_balance - cash_flow) / (previous_balance + cash_flow * date_diff) AS strategy_return
						FROM strategy_data),
				benchmark_returns AS (
					SELECT
						date,
						(close - LAG(close) OVER (ORDER BY date)) / LAG(close) OVER (ORDER BY date) AS benchmark_return
					FROM benchmark),
				summary AS (
					SELECT 
						s.date as date,
						s.cash_flow::DOUBLE as cash_flow,
						s.end_balance::DOUBLE as end_balance,
						s.strategy_return::DOUBLE as strategy_return,
						COALESCE(SUM(s.strategy_return) OVER (ORDER BY s.date), 0) AS strategy_cumulative,
						b.benchmark_return::DOUBLE as benchmark_return,
						COALESCE(SUM(b.benchmark_return) OVER (ORDER BY b.date), 0) AS benchmark_cumulative
					FROM strategy_returns s
					JOIN benchmark_returns b
					ON s.date = b.date
					ORDER BY s.date)
				SELECT 
					date,
					cash_flow,
					end_balance,
					strategy_return,
					strategy_cumulative,
					benchmark_return,
					benchmark_cumulative,
					MAX(strategy_cumulative) OVER (ORDER BY date) AS high_watermark,
					strategy_cumulative - MAX(strategy_cumulative) OVER (ORDER BY date) AS drawdown
				FROM summary;
		""")
					
		try connection.execute("""
			CREATE VIEW grouped_returns AS	
				WITH 
					date_interval AS (
						SELECT 
							DATEDIFF('month', min(date), max(date)) AS interval_in_months
						FROM performance)
				SELECT
					CASE
						WHEN interval_in_months <= 4 THEN time_bucket(INTERVAL '1 week', DATE)
						WHEN interval_in_months <= 48 THEN time_bucket(INTERVAL '1 month', DATE)
						WHEN interval_in_months <= 108  THEN time_bucket(INTERVAL '3 months', DATE)
						ELSE time_bucket(INTERVAL '1 year', DATE)
					END AS bucket,
					SUM(strategy_return) AS strategy_returns,
					AVG(interval_in_months) AS interval
				FROM performance
				CROSS JOIN date_interval
				GROUP BY bucket
				ORDER BY bucket;
		""")
		

					
	}
		
	
	public func performance() throws -> DataFrame {
			
		let result = try connection.query("""
			select 
				date, 
				strategy_return, 
				strategy_cumulative, 
				benchmark_return, 
				benchmark_cumulative, 
				high_watermark, 
				drawdown
			from performance;
		""")
		let dates = result[0].cast(to: DuckDB.Date.self)
		let strategy = result[1].cast(to: Double.self)
		let strategyCum = result[2].cast(to: Double.self)
		let benchmark = result[3].cast(to: Double.self)
		let benchmarkCum = result[4].cast(to: Double.self)
		let hwm = result[5].cast(to: Double.self)
		let drawdowns = result[6].cast(to: Double.self)
	
		var frame = TabularData.DataFrame(columns: [
			TabularData.Column(dates).eraseToAnyColumn(),
			TabularData.Column(strategy).eraseToAnyColumn(),
			TabularData.Column(strategyCum).eraseToAnyColumn(),
			TabularData.Column(benchmark).eraseToAnyColumn(),
			TabularData.Column(benchmarkCum).eraseToAnyColumn(),
			TabularData.Column(hwm).eraseToAnyColumn(),
			TabularData.Column(drawdowns).eraseToAnyColumn()
		])
	
		frame.transformColumn("date") { (duckDate: DuckDB.Date) -> Foundation.Date in
			return Foundation.Date(duckDate)
		}
		
		return frame
	}

	
	public func groupedReturns() throws -> DataFrame {
		let result = try connection.query("select * from grouped_returns;")
		let dates = result[0].cast(to: DuckDB.Date.self)
		let returns = result[1].cast(to: Double.self)
		let interval = result[2].cast(to: Double.self)

		var frame = DataFrame(columns:[
			TabularData.Column(dates).eraseToAnyColumn(),
			TabularData.Column(returns).eraseToAnyColumn(),
			TabularData.Column(interval).eraseToAnyColumn(),
		])
		
		frame.transformColumn("bucket") { (duckDate: DuckDB.Date) -> Foundation.Date in
			return Foundation.Date(duckDate)
		}
		
		return frame
		
	}
	
	
	public func greeks() throws -> DataFrame {
		
		let result = try connection.query("""
			WITH 
				date_interval AS (
					SELECT
						DATEDIFF('month', MIN(date), MAX(date)) AS interval_in_months
					FROM performance
				)
			SELECT
				SQRT(252) * mean / all_dev AS sharpe,
				SQRT(252) * mean / neg_dev AS sortino
			FROM (
				SELECT
					STDDEV(strategy_return) FILTER (WHERE strategy_return < 0) AS neg_dev,
					STDDEV(strategy_return) AS all_dev,
					MEAN(strategy_return) AS mean,
				FROM performance
			) AS subquery;
		"""
		)
		
		let sharpe = result[0].cast(to: Double.self)
		let sortino = result[1].cast(to: Double.self)
			
		let frame = DataFrame(columns:[
			TabularData.Column(sharpe).eraseToAnyColumn(),
			TabularData.Column(sortino).eraseToAnyColumn(),
		])

		return frame
		
	}
	
	
	public func header() throws -> DataFrame {
		
		let result = try connection.query("""
			SELECT
				net_assets,
				net_assets - total_cash_flow as gain,
				total_return * 100 as total_return,
				(POW(1 + total_return, 252.0 / count) - 1) * 100  AS cagr
			FROM (
				SELECT
					last(end_balance) as net_assets,
					sum(cash_flow) as total_cash_flow,
					LAST(strategy_cumulative) AS total_return,
					MEAN(strategy_return) AS mean,
					COUNT(strategy_return) AS count
				FROM performance
			) AS subquery;
		"""
		)
		
		let netAssets = result[0].cast(to: Double.self)
		let change = result[1].cast(to: Double.self)
		let changePerCent = result[2].cast(to: Double.self)
		let cagr = result[3].cast(to: Double.self)

			
		let frame = DataFrame(columns:[
			TabularData.Column(netAssets).eraseToAnyColumn(),
			TabularData.Column(change).eraseToAnyColumn(),
			TabularData.Column(changePerCent).eraseToAnyColumn(),
			TabularData.Column(cagr).eraseToAnyColumn(),
		])

		return frame
		
	}
	
	
	public func distribution() throws -> DataFrame {
		
		let result = try connection.query("""
			WITH returns AS (
				SELECT strategy_return FROM performance
			),
			binned_returns AS (
				SELECT
					CASE
						WHEN strategy_return < -0.05 THEN '< -5'
						WHEN strategy_return >= -0.05 AND strategy_return < -0.04 THEN '-5 to -4'
						WHEN strategy_return >= -0.04 AND strategy_return < -0.03 THEN '-4 to -3'
						WHEN strategy_return >= -0.03 AND strategy_return < -0.02 THEN '-3 to -2'
						WHEN strategy_return >= -0.02 AND strategy_return < -0.01 THEN '-2 to -1'
						WHEN strategy_return >= -0.01 AND strategy_return < 0 THEN '-1 to 0'
						WHEN strategy_return >= 0 AND strategy_return < 0.01 THEN '0 to 1'
						WHEN strategy_return >= 0.01 AND strategy_return < 0.02 THEN '1 to 2'
						WHEN strategy_return >= 0.02 AND strategy_return < 0.03 THEN '2 to 3'
						WHEN strategy_return >= 0.03 AND strategy_return < 0.04 THEN '3 to 4'
						WHEN strategy_return >= 0.04 AND strategy_return < 0.05 THEN '4 to 5'
						ELSE '>= 5'
					END AS return_range,
					COUNT(*) AS count
				FROM returns
				GROUP BY return_range
			),
			ordered_binned_returns AS (
				SELECT
					return_range,
					count,
					CASE
						WHEN return_range = '< -5' THEN -6
						WHEN return_range = '>= 5' THEN 6
						WHEN return_range LIKE '%to%' THEN CAST(SPLIT_PART(return_range, ' ', 1) AS DOUBLE)
						ELSE CAST(SPLIT_PART(return_range, ' ', 1) AS DOUBLE)
					END AS sort_key
				FROM binned_returns
			)
			SELECT return_range, count
			FROM ordered_binned_returns
			ORDER BY sort_key;
		""")
		
		let bins = result[0].cast(to: String.self)
		let returns = result[1].cast(to: Int.self)

		let frame = DataFrame(columns:[
			TabularData.Column(bins).eraseToAnyColumn(),
			TabularData.Column(returns).eraseToAnyColumn(),
		])
				
		return frame

		
	}
	
	/// Creates Tearsheet from Postgresql table
	/// expects fields (date, cash_flow, end_balance
	/// - Parameters:
	/// - user: postgres username
	/// - password: postgres password
	/// - tableName:  postgres table/view for data
	/// - benchmark: benchmark symbol for performance comparision
	
	@MainActor
	public static func analyze(user: String, password: String, tableName table: String, benchmark: YahooFinance) async throws -> Tearsheet {
		
		let db = try Database(store: .inMemory)
		let con = try db.connect()
		
		let prefix = "pgdb"
		let tableName = String(format:"%@.%@",prefix,table)
		
		try con.execute("INSTALL postgres;")
		try con.execute("LOAD postgres;")
		try con.execute("ATTACH 'dbname = portfolios user = \(user) password = \(password) host=127.0.0.1 port = 5432' AS \(prefix) (TYPE POSTGRES, READ_ONLY);")
		try con.execute("create table strategy as select date, cash_flow, end_balance from \(tableName);")
		try con.execute("DETACH \(prefix);")
				
		let dateRange = try con.query("select min(date) as start, max(date) as end from strategy;")
		guard let start = dateRange[0].cast(to: (DuckDB.Date.self)).first?.unsafelyUnwrapped,
			let end = dateRange[1].cast(to: DuckDB.Date.self).first?.unsafelyUnwrapped
		else { fatalError("fucked up when finding date interval") }

		let interval = DateInterval(start:Foundation.Date(start), end: Foundation.Date(end).endOfDay)
		
		let (benchmarkData,_) = try await URLSession.shared.download(from: benchmark.getURL(for: interval))
		
		try con.execute("""
			create table benchmark as 
			select Date as date, Close as close 
			from read_csv_auto(\"\(benchmarkData.path)\");
		""")
		
		return try Tearsheet(database: db, connection: con)
		
	}
	
	/// Creates Tearsheet from csv file
	/// expects fields (date, cash_flow, end_balance
	/// - Parameters:
	/// - file: url for csv
	/// - benchmark: benchmark symbol for performance comparision

	@MainActor
	public static func analyze(contentsOfCSVFile file: URL, benchmark: YahooFinance) async throws -> Tearsheet {
		
		let db = try Database(store: .inMemory)
		let con = try db.connect()
		
		try con.execute(" CREATE TABLE strategy (date DATE PRIMARY KEY NOT NULL, cash_flow DECIMAL DEFAULT 0, end_balance DECIMAL NOT NULL);")
		try con.execute("COPY strategy (date,cash_flow,end_balance) FROM '\(file.path)' CSV HEADER;")
		
		let dateRange = try con.query("select min(date) as start, max(date) as end from strategy;")
		guard let start = dateRange[0].cast(to: (DuckDB.Date.self)).first?.unsafelyUnwrapped,
			let end = dateRange[1].cast(to: DuckDB.Date.self).first?.unsafelyUnwrapped
		else { fatalError("fucked up when finding date interval") }
		
		let interval = DateInterval(start:Foundation.Date(start), end: Foundation.Date(end).endOfDay)
		
		let (benchmarkData,_) = try await URLSession.shared.download(from: benchmark.getURL(for: interval))
		
		try con.execute("""
			create table benchmark as 
			select Date as date, Close as close 
			from read_csv_auto(\"\(benchmarkData.path)\");
		""")
		
		return try Tearsheet(database: db, connection: con)
		
	}
	
	

	
}

