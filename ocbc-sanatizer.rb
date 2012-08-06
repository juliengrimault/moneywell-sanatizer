#!/usr/bin/ruby

require 'utils.rb'
require 'dbs_code_map.rb'

module MoneyWellSanatizer
  class OCBC
    include Utils

    attr_accessor :csv_file, :sanatized #both are array of arrays
    def initialize(csv_file)
      @csv_file = csv_file
    end

    def remove_non_standart_lines(array_of_arrays)
      #The begining of the csv file is not standart, it is something like below

    #0 Account details for:
    #1 Account details for:,FRANK Account 641-585260-001
    #2 Available ,20.83
    #3 Balance,20.83
    #4
    #5 Transaction History 
    #6 Transaction date,Value date,Description,Withdrawals (SGD),Deposits (SGD)

      # we remove the line  0 to 5
      result = array_of_arrays.drop(6)
    end

    #the transaction details span across multiple lines (not valid CSV =.=)
    #we concatenate the multiline into 1 line and delete the invalid lines
    def collapse_multiline_comments(array_of_arrays)
      last_valid_transaction = 0
      i = 0
      array_of_arrays.delete_if do |row|
        if i == 0 #ignore header
          i += 1
          false
          next
        end

        if row[0].nil? || row[0] == ''#invalid line, get the comment and concatenate it. We also mark this line for deletion
          extra_description = row[2]
          description = array_of_arrays[last_valid_transaction][2]
          array_of_arrays[last_valid_transaction][2] = "#{description} #{extra_description}"
          i += 1
          true
        else #valid transaction line
          last_valid_transaction = i
          i += 1
          false
        end
      end
      array_of_arrays
    end

    def sanatize
      original = CSV.read(@csv_file)
      @sanatized =  remove_non_standart_lines(original)
      @sanatized = collapse_multiline_comments(@sanatized)
      write_to_file(@sanatized,output_filename(@csv_file))
    end

  end
end

if ARGV.length < 1
  puts "Usage: ocbc-sanatizer.rb csv_file"
  exit 0
end

csv_file = ARGV[0]
ocbc = MoneyWellSanatizer::OCBC.new(csv_file)
ocbc.sanatize

