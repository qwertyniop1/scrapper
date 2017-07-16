require 'optparse'
require 'ostruct'

class ArgumentsParser
  def self.parse(args)
    arguments = OpenStruct.new
    arguments.request_timeout = 30
    arguments.request_tries = 3
    arguments.threads = 2
    arguments.log_level = :info

    parser = OptionParser.new do |options|
      options.banner = 'Usage: scrapper.rb URL OUTPUT_PATH [options]'
      options.separator ''

      options.separator ''
      options.separator 'Optional arguments:'

      options.on(
        '--timeout [TIMEOUT]',
        Integer,
        'Timeout for HTTP requests'
      ) { |timeout| arguments.request_timeout = timeout }

      options.on(
        '--tries [TRIES]',
        Integer,
        'Number of attempts to receive a HTTP response'
      ) { |tries| arguments.request_tries = tries }

      options.on(
        '-t [THREADS]',
        '--threads [THREADS]',
        Integer,
        'Number of threads (0 to turn off multithreading)'
      ) { |threads| arguments.threads = threads }

      options.on(
        '-l [LEVEL]',
        '--log-level [LEVEL]',
        [:debug, :info, :warn, :error, :silent],
        'Specify level of logging (debug, info, warn, error)'
      ) do |level|
        level = :info if level.nil?
        arguments.log_level = level
      end
    end

    parser.parse! args
    arguments
  end
end
