json.array!(@merchants) do |merchant|
  json.extract! merchant, :id, :business_type_primary, :business_type_secondary, :sic_1, :sic_2, :sic_3, :interchange_percentage, :avg_ticket, :amex_percentage, :amex_per_item, :check_card_percentage, :amex_vol, :check_card_vol, :mc_vol, :vs_vol, :disc_vol, :debit_vol, :total_transactions, :amex_transactions, :interchange_fees, :total_fees, :debit_transactions, :debit_network_fees, :ebt_vol, :ebt_fees
  json.url merchant_url(merchant, format: :json)
end
