#!/usr/bin/ruby

require 'csv'
# http://ruby-doc.org/stdlib-1.9.2/libdoc/csv/rdoc/CSV.html
require 'utils'
require 'dbs_code_map.rb'

module MoneyWellSanatizer
  class POSB
    include Utils

    attr_accessor :csv_file, :sanatized #both are array of arrays
    def initialize(csv_file)
      @csv_file = csv_file
    end

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

    def expand_transaction_code(row, line_number)
      transaction_reference = row[1]
        reference_explanation = nil
        unless transaction_reference.nil?
          reference_explanation = CODE_MAP[transaction_reference]
          if reference_explanation.nil?
            puts "Transaction Reference #{transaction_reference} not found in Code Map. Line #{line_number}"
          end
        end
      row << reference_explanation
    end

    def fix_empty_transaction_reference_1(row)
      if row[4].nil?
        row[4] = "-"
      end
    end

    def fix_rows(array_of_arrays)
      array_of_arrays[0] << "Code Explanation"
      i = 0
      array_of_arrays.each do |row|
        if i == 0 #skip headers
          i += 1
          next
        end

        expand_transaction_code(row,i)
        fix_empty_transaction_reference_1(row)
        i += 1
      end
      array_of_arrays
    end

    def sanatize
      original = CSV.read(@csv_file)
      @sanatized =  remove_non_standart_lines(original)
      @sanatized = fix_rows(@sanatized)
      write_to_file(@sanatized,output_filename(@csv_file))
    end

  end
end


if ARGV.length < 1
  puts "Usage: posb-sanatizer.rb csv_file"
  exit 0
end

csv_file = ARGV[0]
posb = MoneyWellSanatizer::POSB.new(csv_file)
posb.sanatize

