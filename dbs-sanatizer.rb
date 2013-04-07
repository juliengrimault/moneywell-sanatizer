#!/usr/bin/ruby

require 'csv'
# http://ruby-doc.org/stdlib-1.9.2/libdoc/csv/rdoc/CSV.html
require 'utils'
require 'dbs_code_map.rb'
require 'dbs-generic.rb'


#The begining of the csv file is not standart, it is something like below

#0
#1 - Account Details For:,Multi-Currency Autosave 027-028028-5
#2 - Statement as at:,29 Mar 2013 
#3
#4 - Currency:, SGD - Singapore Dollar
#5 - Available Balance:,4858.95
#6 - Ledger Balance:,4859.95
#7
#8 - Transaction Date,Value Date,Statement Code,Reference,Debit Amount,Credit Amount,Client Reference,Additional Reference
#9 - 29 Mar 2013,,ADV,TRF, 100.00, ,007-49655-9  : I-BANK,,
# we remove the line  0 to 7
      


if ARGV.length < 1
  puts "Usage: dbs-sanatizer.rb csv_file"
  exit 0
end

csv_file = ARGV[0]
lines_to_delete = *(0..7)
posb = MoneyWellSanatizer::DBS.new(csv_file,lines_to_delete)
posb.sanatize

      
