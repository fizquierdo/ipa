###
# wiktionary licensed under
# https://creativecommons.org/licenses/by-sa/3.0/ 
#
require 'mechanize'
require 'csv'

module IPAwiki
  class Table
    attr_reader :html_table
    def initialize(html_table)
      @html_table = html_table
    end

    def headers
      @headers ||= html_table.search('th').map(&:text)
    end

    def records
      @rows ||= extract_rows
    end

    def to_tsv(fname, sep="\t")
      CSV.open(fname, 'wb', col_sep: sep) do |tsv|
        tsv << headers
        records.each{ |r| tsv << r }
      end
    end

    def to_hash(key=:IPA)
      out = {}
      records.each do |record| 
        h = Hash[headers.map(&:to_sym).zip(record)]
        out.merge!(h[key] => h)
      end
      out 
    end

    private
    def extract_rows
      rows = []
      html_table.search('tr').each do |tr|
        cells = tr.search('td')
        next if cells.empty?
        rows << cells.map(&:text).map(&:remove_numbers)
      end
      rows
    end
  end

  class Downloader
    attr_reader :url
    def initialize(url='https://en.wiktionary.org/wiki/Wiktionary:IPA_pronunciation_key')
      @url = url
    end

    def write_tables(table_name='ipa_table')
      mechanize = Mechanize.new
      page = mechanize.get(url)
      tables = page.search('table.wikitable')
      tables.each_with_index do |table, index|
        t = IPAwiki::Table.new(table)
        t.to_tsv("#{table_name}_#{index}.tsv")
      end
    end
  end
end

class String
  def remove_numbers
    self.tr("0-9","")
  end
end
