require 'logger'
require 'byebug'

require_relative 'lib/scrapper/scrapper'
require_relative 'lib/petsonic/list_page'
require_relative 'lib/petsonic/item_page'

def main
  target_url = ARGV.first

  logger = Logger.new(STDOUT)

  scrapper = Scrapper.new(
    target_url,
    list_page_class: PetsonicListPage,
    item_page_class: PetsonicItemPage,
    logger: logger
  )

  res = scrapper.parse
  p res
  puts res
end

main
