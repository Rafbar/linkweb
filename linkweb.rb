require 'pry'
require 'headless'
require 'capybara'
require 'capybara-webkit'
require 'nokogiri'
require 'pp'

Capybara.reset_sessions!
Capybara.default_driver = :webkit
Capybara.javascript_driver = :webkit
Capybara::Webkit.configure do |config|
  config.allow_unknown_urls
end

class Linkweb
  @@dom_elements = ['a','button']
  @@bad_status_codes = [/\A4/,/\A5/]
  @@bad_html_strings = [/cannot load/, /failed to load/, /error/, /exception/]


	class << self

		def test(url)

      # Remove trailing slash i exists
      url = remove_trailing_slash(url)

      # Get pages html
      html = get_html(url)

      # Get hrefs for all the @@dom_elements
      hrefs = find_links(html,@@dom_elements,url)

      # Remove hrefs unrelated to the domain
      hrefs = remove_external_domain_hrefs(hrefs, url)

      # Checks the sites to which links were found
      bad_links = check_links(hrefs)

      # The UI, tadam.
      puts "\n\n####################################################"
      puts "#{bad_links.length} bad links detected for #{url}"
      puts "####################################################\n"
      puts "Bad links list: \n"
      pp bad_links
      puts "\n\n####################################################"
      
      # Clears the call output
      nil
		end

    # Gets initial page html
    def get_html(url)
      Headless.ly do
        session = Capybara::Session.new(:webkit)
        session.visit(url)
        Nokogiri::HTML(session.html)
      end
    end

    # Find existing links for the given html/url
    def find_links(html, elements, url)
      result_array = []
      elements.each do |el|
        partial_array = html.css("#{el}[href]").map{|x| x.attributes["href"].value}
          .map{|x| x[/\Ahttp/] ? x : url + x}
        result_array += partial_array
      end 
      result_array
    end


    # Capybara::Session wrapper for checking whether the given link is working or not.
    def check_links(urls)
      bad_links = []

      Headless.ly do 
        session = Capybara::Session.new(:webkit)
        
        urls.each do |x|
          puts "Now visiting: #{x[0..40]}"
          session.visit(x)
          puts session.status_code
          bad_links.push(x) if !check_page(session)
        end
      end

      bad_links
    end


    # Return false if determined that given session.page is broken.
    def check_page(session)
      # Check if status code for the given url is bad
      @@bad_status_codes.each do |code_regex|
        return false if code_regex =~ session.status_code.to_s
      end

      # Check if inner body text includes unwanted expressions
      @@bad_html_strings.each do |html_regex|
        html = Nokogiri::HTML(session.html)
        return false if html_regex =~ html.css('body').inner_text
      end
      true
    end

    # Removes trailing slash from the url
    def remove_trailing_slash(url)
      url[-1] == '/' ? url[0..-2] : url
    end

    # Removes hrefs for external domains
    def remove_external_domain_hrefs(hrefs, domain_url)
      short_url = domain_url.split('/')[2]
      url_regex = Regexp.new(short_url)
      hrefs.map do |href|
        href =~ url_regex ? href : nil
      end
    end

	end
end



puts "\n\n################################"
puts "Test site with Linkweb.test(url)"
puts "################################\n\n"\

binding.pry