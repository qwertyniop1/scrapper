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

def create_logger(level)
  return NullLogger.new if level == :silent

  logger = Logger.new(STDOUT)
  logger.level = level
  logger.formatter = proc do |severity, datetime, progname, msg|
    "[#{severity}] #{msg}\n"
  end
  logger
end

def main
  begin
    options = ArgumentsParser.parse(ARGV)
  rescue OptionParser::InvalidOption => error
    puts error
    exit(1)
  end
  if ARGV.size < 2
    puts 'Error! Too few arguments'
    exit(1)
  end
  target_url = ARGV.first
  output_filename = ARGV[1]

  logger = create_logger(options.log_level)

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

  logger.info "Start processing url: #{target_url}"
  start_time = Time.now

  results = scrapper.parse

  end_time = Time.now
  logger.info "Scrapping finished in #{end_time - start_time} seconds"

  if results.nil? || results.empty?
    logger.warn 'No data has been scrapped. Nothing to save.'
    exit(1)
  end

  columns = %i{name price image}
  save_to_csv(results, output_filename, columns)
end

main
