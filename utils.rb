#!/usr/bin/ruby

require 'csv'
# http://ruby-doc.org/stdlib-1.9.2/libdoc/csv/rdoc/CSV.html

module MoneyWellSanatizer
  module Utils
    def print_csv(array_of_arrays)
      i = 0
      array_of_arrays.each do |row|
        puts "#{i} - #{row.to_s}" 
        i += 1
      end
    end

    def write_to_file(array_of_arrays, output_filename)
      CSV.open(output_filename, "wb") do |csv|
        array_of_arrays.each do |row|
          csv << row
        end
      end
    end

    def output_filename(input_filename)
      extension = File.extname(input_filename)
      basename = File.basename(input_filename,extension)
      dirname = File.dirname(input_filename)
      return "#{dirname}/#{basename}_sanatized#{extension}"
    end
  end
end