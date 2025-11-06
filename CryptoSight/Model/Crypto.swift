import Foundation

// MARK: - Response
struct CryptoResponse: Decodable {
    let status: Status
    let data: [CryptoData]
}

// MARK: - Status
struct Status: Decodable {
    let timestamp: String
    let errorCode: Int
    let errorMessage: String?
    let elapsed: Int
    let creditCount: Int
    let notice: String?
    let totalCount: Int?
    
    // Custom CodingKeys to map JSON keys to Swift properties
    enum CodingKeys: String, CodingKey {
        case timestamp
        case errorCode = "error_code"
        case errorMessage = "error_message"
        case elapsed
        case creditCount = "credit_count"
        case notice
        case totalCount = "total_count"
    }
}

// MARK: - CryptoData
struct CryptoData: Decodable {
    let id: Int
    let name: String
    let symbol: String
    let slug: String
    let numMarketPairs: Int
    let dateAdded: String
    let tags: [String]
    let maxSupply: Double?
    let circulatingSupply: Double
    let totalSupply: Double
    let infiniteSupply: Bool
    let platform: Platform?
    let cmcRank: Int
    let selfReportedCirculatingSupply: Double?
    let selfReportedMarketCap: Double?
    let tvlRatio: Double?
    let lastUpdated: String
    let quote: QuoteWrapper
    
    enum CodingKeys: String, CodingKey {
        case id, name, symbol, slug
        case numMarketPairs = "num_market_pairs"
        case dateAdded = "date_added"
        case tags
        case maxSupply = "max_supply"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case infiniteSupply = "infinite_supply"
        case platform
        case cmcRank = "cmc_rank"
        case selfReportedCirculatingSupply = "self_reported_circulating_supply"
        case selfReportedMarketCap = "self_reported_market_cap"
        case tvlRatio = "tvl_ratio"
        case lastUpdated = "last_updated"
        case quote
    }
}

// MARK: - Platform
struct Platform: Decodable {
    let id: Int
    let name: String
    let symbol: String
    let slug: String
    let tokenAddress: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, symbol, slug
        case tokenAddress = "token_address"
    }
}

// MARK: - QuoteWrapper
struct QuoteWrapper: Decodable {
    let usd: Quote
    
    enum CodingKeys: String, CodingKey {
        case usd = "USD"
    }
}

// MARK: - Quote
struct Quote: Decodable {
    let price: Double
    let volume24H: Double
    let volumeChange24H: Double
    let percentChange1H: Double
    let percentChange24H: Double
    let percentChange7D: Double
    let percentChange30D: Double
    let percentChange60D: Double
    let percentChange90D: Double
    let marketCap: Double
    let marketCapDominance: Double
    let fullyDilutedMarketCap: Double
    let tvl: Double?
    let lastUpdated: String
    
    enum CodingKeys: String, CodingKey {
        case price
        case volume24H = "volume_24h"
        case volumeChange24H = "volume_change_24h"
        case percentChange1H = "percent_change_1h"
        case percentChange24H = "percent_change_24h"
        case percentChange7D = "percent_change_7d"
        case percentChange30D = "percent_change_30d"
        case percentChange60D = "percent_change_60d"
        case percentChange90D = "percent_change_90d"
        case marketCap = "market_cap"
        case marketCapDominance = "market_cap_dominance"
        case fullyDilutedMarketCap = "fully_diluted_market_cap"
        case tvl
        case lastUpdated = "last_updated"
    }
}
