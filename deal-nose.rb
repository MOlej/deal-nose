require 'nokogiri'
require 'open-uri'

print 'Your city (in polish): '
city = gets.chomp.downcase.tr('ąęółżźćń', 'aeolzzcn')

print 'Product: '
search = gets.chomp.tr(' ', '-')

url = URI.encode("https://www.olx.pl/#{city}/q-#{search}/")

# TODO: handling 404
site = Nokogiri::HTML(URI.parse(url).read)

# TODO: parsing offers from all result pages

products_count = site.css('div.offer-wrapper').length

puts "Found #{products_count} products:"

products_count.times do |i|
  name = site.css('div.offer-wrapper').css('a strong')[i].text
  price = site.css('div.offer-wrapper').css('p.price strong')[i].text
  puts "#{i + 1}. #{name} for #{price}"
end
