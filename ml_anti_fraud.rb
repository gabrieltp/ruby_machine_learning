require 'decisiontree'
require 'csv'

dataset = CSV.open('transactional_data.csv')

convert_bool = { 'TRUE' => 1, 'FALSE' => 0, 'has_cbk' => 'has_cbk_bin' }

my_csv = CSV.open('transactional_data.csv')
CSV.open('saved_csv.csv', 'w') do |csv|
    my_csv.each { |row| csv << [convert_bool[row.last], *row[0...row.size]] }
end

CSV.open('saved_csv2.csv', 'w') do |output_csv|
    CSV.foreach('saved_csv.csv') do |row|
      modified_row = row.map { |value| value.nil? || value.empty? ? '0' : value }
      output_csv << modified_row
    end
end

CSV.open('saved_csv3.csv', 'wb') do |csv_out|
    CSV.foreach('saved_csv2.csv') do |row|
        first_column_value = row[0]
        new_row = row[1..-2] + [first_column_value]
        csv_out << new_row
    end
end

clean_dataset = CSV.read('saved_csv3.csv')

attributes = ['transaction_id','merchant_id','user_id','card_number','transaction_date','transaction_amount','device_id']

training = clean_dataset[1..clean_dataset.length*0.7]

test = ['21323596','17348','8','650487******9884','2019-11-01T01:27:15.811098','2416.70','0','0']

dec_tree = DecisionTree::ID3Tree.new(attributes, training, 1, transaction_id: :continuous, 
    merchant_id: :continuous, user_id: :continuous, card_number: :continuous, transaction_date: :continuous, transaction_amount: :continuous, device_id: :continuous)
dec_tree.train

decision = dec_tree.predict(test)
puts "Predicted: #{decision} ... True decision: #{test.last}"