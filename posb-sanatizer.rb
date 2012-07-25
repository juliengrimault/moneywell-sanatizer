#!/usr/bin/ruby

require 'csv'
# http://ruby-doc.org/stdlib-1.9.2/libdoc/csv/rdoc/CSV.html
require 'dbs_code_map.rb'

def remove_non_standart_lines(array_of_arrays)
  #The begining of the csv file is not standart, it is something like below

  #0 - Account Details For:POSB Savings 010-81630-0
  #1 - Statement as at:25 Jul 2012
  #2 - Available Balance:2272.14
  #3 - Ledger Balance:2356.60
  #4 - 
  #5 - Transaction DateReferenceDebit AmountCredit AmountTransaction Ref1Transaction Ref2Transaction Ref3
  #6 - 
  #7 - 25 Jul 2012UMC- XX.XX YYYY    MO RE 20JUL5264-7100-0209-5267 EUR20.40
  #8 - 22 Jul 2012UMC-S XXXX.XX YYYYY              SI NG 19JUL5264-7100-0209-5267
  #     and so on for the transactions...

  # we remove the line  0 to 4 and 6
  result = array_of_arrays.drop(5)
  result.delete_at(1)

  #clean trailing empty value
  header_count = result[0].count
  result.each do |row|
    while row.count > header_count
      row.pop
    end
  end
  result
end

def expand_transaction_codes(array_of_arrays)
  array_of_arrays[0] << "Code Explanation"
  i = 0
  array_of_arrays.each do |row|
    if i == 0 #skip headers
      i += 1
      next
    end

    transaction_reference = row[1]
    reference_explanation = nil
    unless transaction_reference.nil?
      reference_explanation = CODE_MAP[transaction_reference]
      if reference_explanation.nil?
        puts "Transaction Reference #{transaction_reference} not found in Code Map. Line #{i}"
      end
    end
    row << reference_explanation
    i += 1
  end
  array_of_arrays
end


def print_csv(array_of_arrays)
  i = 0
  array_of_arrays.each do |row|
    puts "#{i} - #{row.to_s}" 
    i += 1
  end
end

def write_to_file(array_of_arrays)
  CSV.open("csvfile_out.csv", "wb") do |csv|
    array_of_arrays.each do |row|
      csv << row
    end
  end
end


if ARGV.length < 1
  puts "Usage: posb-sanatizer.rb csv_file"
  exit 0
end

csv_file = ARGV[0]
array_of_arrays = CSV.read(csv_file)
puts "Removing the line  0 to 4 and 6"
array_of_arrays =  remove_non_standart_lines(array_of_arrays)
array_of_arrays = expand_transaction_codes(array_of_arrays)
write_to_file(array_of_arrays)