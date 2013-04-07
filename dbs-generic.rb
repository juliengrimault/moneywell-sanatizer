#!/usr/bin/ruby
#!/usr/bin/ruby

require 'csv'
# http://ruby-doc.org/stdlib-1.9.2/libdoc/csv/rdoc/CSV.html
require 'utils'
require 'dbs_code_map.rb'

module MoneyWellSanatizer
  class DBS
    include Utils

    attr_accessor :csv_file, :sanatized #both are array of arrays
    attr_accessor :indexes_to_delete

    def initialize(csv_file, indexes_to_delete)
      @csv_file = csv_file
      @indexes_to_delete = indexes_to_delete
    end

    def remove_non_standart_lines(array_of_arrays)
      result = []
      array_of_arrays.each_index do |i|
        result << array_of_arrays[i] unless indexes_to_delete.include?(i)
      end

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

