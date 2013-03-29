#!/usr/bin/ruby

require 'csv'
# http://ruby-doc.org/stdlib-1.9.2/libdoc/csv/rdoc/CSV.html
require 'utils'
require 'dbs_code_map.rb'
require 'dbs-generic.rb'

#The begining of the csv file is not standart, it is something like below

#0 - 
#1 - Account Details For:POSB Savings 010-81630-0
#2 - Statement as at:25 Jul 2012
#3 - Available Balance:2272.14
#4 - Ledger Balance:2356.60
#5 - 
#6 - Transaction Date,Reference,Debit Amount,Credit Amount,Transaction Ref1,Transaction Ref2,Transaction Ref3
#7 - 
#8 - 25 Jul 2012,UMC- ,XX.XX,YYYY,    MO RE 20JUL5264-7100-0209-5267 EUR20.40
#9 - 22 Jul 2012UMC-S XXXX.XX YYYYY              SI NG 19JUL5264-7100-0209-5267
#     and so on for the transactions...

# we remove the line  0 to 5 and 7


if ARGV.length < 1
  puts "Usage: posb-sanatizer.rb csv_file"
  exit 0
end

csv_file = ARGV[0]
lines_to_delete = *(0..5) 
lines_to_delete << 7
posb = MoneyWellSanatizer::DBS.new(csv_file, lines_to_delete)
posb.sanatize

