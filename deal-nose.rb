require 'nokogiri'
require 'open-uri'
require 'byebug'

Offer = Struct.new(:title, :price)

def get_webpage(url)
  Nokogiri::HTML(URI.parse(url).read)
rescue OpenURI::HTTPError
  puts 'Webpage does not exist.'
end

def get_offers_nodeset(url, page_number)
  get_webpage(url + "?=page#{page_number}").css('div.offer-wrapper')
end

def exclude_promoted_offers(offers)
  standard_offers = []
  offers.each do |page|
    page.each do |offer|
      standard_offers << offer unless offer.children[1].values.to_s.split.include?('promoted-list')
    end
  end
  standard_offers
end

def map_nodes_to_structs(offers)
  offers.map! do |offer|
    Offer.new(offer.css('a strong').text,
              offer.css('p.price strong').text)
  end
end

def put_offers(offers)
  offers.each_with_index do |offer, i|
    print "#{i + 1}. #{offer.title}"
    puts offer.price.empty? ? '' : " for #{offer.price}"
  end
end

url = ''
loop do
  print 'Your city (in polish): '
  city = gets.chomp.downcase.tr('ąęółżźćń', 'aeolzzcn')

  print 'Product: '
  search = gets.chomp.tr(' ', '-')

  url = URI.encode("https://www.olx.pl/#{city}/q-#{search}/")
  get_webpage(url) ? break : puts('Check the search query.')
end

webpage = get_webpage(url)
# checks the OLX webpage for the pager or the message that no offers was found 
pages_count = if webpage.css('span.item.fleft').any?
                webpage.css('span.item.fleft').last.text.to_i
              elsif webpage.xpath('//*[@id="body-container"]/div[2]/div/div[2]/p/text()').any?
                0
              else
                1
              end

puts "Pages count: #{pages_count}"
pages = pages_count > 5 ? 5 : pages_count # restrict results to first 5 pages
puts "Fetching #{pages} pages..."

# iterates over multiple pages
offers = []
pages.times do |page_number|
  offers << get_offers_nodeset(url, page_number)
end

standard_offers = map_nodes_to_structs(exclude_promoted_offers(offers))

puts "Found #{standard_offers.length} products:"
put_offers(standard_offers)
