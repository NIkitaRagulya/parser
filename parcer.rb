require 'curb'
require 'nokogiri'
require 'csv'

@url = ARGV[0]
@file_name = ARGV[1]

all_products_url = []

@i = 0
@previous = 0
@current = 0

loop do
  @i += 1
  url = @i > 1 ? @url + '?p=' + @i.to_s : @url
  doc = Nokogiri::HTML(Curl.get(url).body_str)
  doc.xpath('//ul[@id = "product_list"]/li').each do |product|
    all_products_url |= [product.xpath('.//a[@class="product-name"]/@href')]
  end
  @current = all_products_url.length
  break if @previous == @current

  @previous = @current
end

Product = Struct.new(:name, :price, :image)
product_array = []

all_products_url.each do |product_url|
  product = Nokogiri::HTML(Curl.get(product_url.first.value).body_str)
  product.xpath('//ul[@class="attribute_radio_list pundaline-variations"]/li').each do |variation|
    print '.'
    product_name = product.xpath('.//h1[@class="product_main_name"]').text + ' - ' +
                   variation.xpath('.//span[@class="radio_label"]').text
    product_price = variation.xpath('.//span[@class="price_comb"]').text
    product_image = product.xpath('.//img[@id="bigpic"]/@src').first.value

    product_array.push(Product.new(product_name, product_price, product_image))
  end
end

puts ''

CSV.open(@file_name, 'a+') do |csv|
  csv << ['Name', 'Price', 'Image url']
  product_array.each do |product|
    csv << [product.name, product.price, product.image]
  end
end
