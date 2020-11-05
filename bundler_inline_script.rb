require 'bundler/inline'
require 'curb'
require 'nokogiri'
require 'pry'
require "csv"

url = 'https://www.petsonic.com/snacks-huesos-para-perros/?p='

all_products_url = []

doc = Nokogiri::HTML(Curl.get('https://www.petsonic.com/snacks-huesos-para-perros/').body_str)
doc.xpath('//*[@id = "product_list"]/li').first(3).each do |product|
  all_products_url |= [product.xpath('.//a[@class="product-name"]/@href')]
end

$i = 1

$previous = all_products_url.length
$current = all_products_url.length

# while true do
#   $i += 1
#   doc = Nokogiri::HTML(Curl.get(url + $i.to_s).body_str)
#   doc.xpath('//*[@id = "product_list"]/li').each do |product|
#     all_products_url |= [product.xpath('.//a[@class="product-name"]/@href')]
#   end
#   $current = all_products_url.length
#   break if $previous == $current
#   $previous = $current
# end

product_hash = {name: [], price: [], image: []}

all_products_url.each do |product_url|
  product = Nokogiri::HTML(Curl.get(product_url.first.value).body_str)
  product.xpath('//ul[@class="attribute_radio_list pundaline-variations"]/li').each do |variation|
    product_hash[:name].push(product.xpath('.//h1[@class="product_main_name"]').text + variation.xpath('.//span[@class="radio_label"]').text)
    product_hash[:price].push(variation.xpath('.//span[@class="price_comb"]').text)
    product_hash[:image].push(product.xpath('.//img[@id="bigpic"]/@src').first.value)
  end
end

CSV.open("file.csv", "a+") {|csv| product_hash.to_a.each {|elem| csv << elem} }

CSV.open("file.csv", "a+") do |csv|
  csv << %w(Names Prices Images)
  product_hash.values.each do |line|
    csv << line
  end
end

puts product_hash
