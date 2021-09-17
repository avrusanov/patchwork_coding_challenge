require 'uri'
require 'net/http'
require 'json'
require 'rspec/autorun'
require 'bigdecimal'

API_KEY = 'd2ca7e8d412338d9e02dd0aee83fed04b15caac5'
API_URL = 'https://api.nomics.com/v1/'

def call_nomic_api(path)
  uri = URI("#{API_URL}#{path}&key=#{API_KEY}")

  Net::HTTP.get(uri)
end

def task_1_retrieve_cryptocurrencies
  currencies = ['BTC', 'XRP', 'ETH']

  JSON.parse(call_nomic_api("currencies?ids=#{currencies.join(',')}"))
end

def task_2_retrieve_cryptocurrencies_specific_values 
  currencies = ['ETH', 'BTC']
  filtered_keys = ['circulating_supply', 'max_supply', 'name', 'symbol', 'price']

  ticker_data = JSON.parse(call_nomic_api("currencies/ticker?ids=#{currencies.join(',')}"))

  filtered_ticker_data = ticker_data.map do |currency|
    currency.delete_if { |k,v| !(filtered_keys.include? k) }
  end
  
  filtered_ticker_data
end

def task_3_convert_crypto_to_fiat(crypto_currency, fiat_currency)
  ticker_data = JSON.parse(call_nomic_api("currencies/ticker?ids=#{crypto_currency}&convert=#{fiat_currency}"))

  BigDecimal(ticker_data.first['price'])
end

def task_4_the_price_of_one_cryptocurrency
  first_cryptocurrency = 'BTC'
  second_cryptocurrency = 'ETH'

  first_cryptocurrency_to_usd = task_3_convert_crypto_to_fiat(first_cryptocurrency, 'USD')

  sleep 2

  second_cryptocurrency_to_usd = task_3_convert_crypto_to_fiat(second_cryptocurrency, 'USD')

  second_cryptocurrency_from_first = second_cryptocurrency_to_usd / first_cryptocurrency_to_usd

  second_cryptocurrency_from_first
end

RSpec.describe do
  describe 'Task1. Get the full payload of BTC,XRP,ETH cryptocurrencies' do
    it 'returns full payload' do
      sleep 2
      expected_ccs = ['BTC', 'XRP', 'ETH']
      cryptocurrencies = task_1_retrieve_cryptocurrencies
      expect(cryptocurrencies.size).to eq(expected_ccs.size)
      0.upto(expected_ccs.size-1) do |i|
        expect(expected_ccs.include? cryptocurrencies[i]['id']).to eq(true)
      end
    end
  end

  describe 'Task 2. Retrieve [circulating_supply, max_supply, name, symbol, price] for [ETH, BTC]' do
    it 'returns required fields' do
      sleep 2
      expected_ccs = ['Bitcoin', 'Ethereum']
      filtered_keys = ['circulating_supply', 'max_supply', 'name', 'symbol', 'price']
      cryptocurrencies = task_2_retrieve_cryptocurrencies_specific_values
      expect(cryptocurrencies.size).to eq(expected_ccs.size)
      0.upto(expected_ccs.size-1) do |i|
        expect(expected_ccs.include? cryptocurrencies[i]['name']).to eq(true)

        expect(cryptocurrencies[i].keys - filtered_keys).to be_empty
      end
      
    end
  end

  describe 'Task 3. Retrieve a specific cryptocurrency to specific fiat.' do
    it 'returns BigDecimal' do
      sleep 2
      expect(task_3_convert_crypto_to_fiat('ETH','USD').class).to eq(BigDecimal)
    end
  end

  describe 'Task 4. Calculate the price of one cryptocurrency from another' do
    it 'returns BigDecimal too' do
      sleep 2
      expect(task_4_the_price_of_one_cryptocurrency.class).to eq(BigDecimal)
    end
  end
end
