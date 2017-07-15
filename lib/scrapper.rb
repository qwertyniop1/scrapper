#!/usr/bin/ruby
require 'logger'
require 'csv'
require 'byebug'

require_relative 'scrapper/scrapper'
require_relative 'petsonic/list_page'
require_relative 'petsonic/item_page'
require_relative 'arguments_parser'

def save_to_csv(data, filename, columns)
  CSV.open(filename, 'wb') do |csv|
    data.each do |row|
      csv << columns.map { |column| row[column] }
    end
  end
end

def main
  if ARGV.size < 2
    puts 'Error! Too few arguments'
    exit(1)
  end
  options = ArgumentsParser.parse(ARGV)
  target_url = ARGV.first
  output_filename = ARGV[1]

  logger = Logger.new(STDOUT)

  scrapper = Scrapper.new(
    target_url,
    list_page_class: PetsonicListPage,
    item_page_class: PetsonicItemPage,
    pagination_parameter: 'p',
    logger: logger,
    request_timeout: options.request_timeout,
    request_tries: options.request_tries,
    threads: options.threads
  )

  results = scrapper.parse

  if results.nil? || results.empty?
    logger.warn 'No data has been scrapped. Nothing to save.'
    exit(1)
  end

  columns = %i{name price image}
  save_to_csv(results, output_filename, columns)
end

main

#########
# TODO: args validation
# TODO: logger level
