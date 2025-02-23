class WebScraperService
    SELECTORS = {
      amazon: {
        title: ['#productTitle', '#title'],
        price: ['.a-price-whole', '#priceblock_ourprice', '#priceblock_dealprice', '.a-price .a-offscreen'],
        description: ['#productDescription', '#feature-bullets'],
        category: ['#wayfinding-breadcrumbs_container', '.a-breadcrumb'],
        brand: ['#bylineInfo'],
        rating: ['#acrPopover'],
        image: ['#landingImage', '.imgTagWrapper img', '#main-image-container img']
      }
    }.freeze
  
    def initialize(url, site: :amazon, max_retries: 3, cache_duration: 24.hours)
      @url = url
      @site = site
      @max_retries = max_retries
      @cache_duration = cache_duration
      @agent = Mechanize.new
      configure_agent
    end
  
    def scrape
      return cached_result if cached_result.present?
  
      retries = 0
      begin
        page = @agent.get(@url)
  
        Rails.logger.info("Scraped page content (first 500 chars): #{page.body[0..500]}")
  
        if page.nil? || captcha_detected?(page)
          Rails.logger.error("Scraping blocked by CAPTCHA for #{@url}")
          return nil
        end
  
        result = extract_data(page)
        cache_result(result) if result.present?
        result
      rescue => e
        retries += 1
        if retries <= @max_retries
          sleep(2 ** retries) 
          retry
        else
          Rails.logger.error("Scraping error for URL #{@url}: #{e.message}")
          Rails.logger.error(e.backtrace.join("\n"))
          nil
        end
      end
    end
  
    private
  
    def configure_agent
      @agent.user_agent = random_user_agent
      @agent.history.max_size = 0
      @agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @agent.robots = false
      @agent.open_timeout = 10
      @agent.read_timeout = 10
  
    end
  
    def random_user_agent
      user_agents = [
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Safari/537.36',
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36'
      ]
      user_agents.sample
    end
  
    def extract_data(page)
      selectors = SELECTORS[@site]
      {
        title: extract_text(page, selectors[:title]),
        price: extract_price(page, selectors[:price]),
        description: extract_text(page, selectors[:description]),
        category_name: extract_category(page, selectors[:category]),
        image: extract_image(page, selectors[:image]),
        additional_info: {
          brand: extract_text(page, selectors[:brand]),
          rating: extract_text(page, selectors[:rating])
        }
      }
    end
  
    def extract_text(page, selectors)
      selectors.each do |selector|
        element = page.at(selector)
        return element.text.strip if element
      end
      nil
    end
  
    def extract_price(page, selectors)
      selectors.each do |selector|
        element = page.at(selector)
        next unless element
  
        price_text = element.text.strip
        return price_text.scan(/\d+[\.,]?\d*/).join('').to_f if price_text.present?
      end
      0.0
    end
  
    def extract_category(page, selectors)
      selectors.each do |selector|
        element = page.at(selector)
        next unless element
  
        categories = element.search('li, a')
        next if categories.empty?
  
        category_text = categories[-2]&.text&.strip
        return category_text if category_text.present?
      end
      "General"
    end
  
    def extract_image(page, selectors)
      selectors.each do |selector|
        element = page.at(selector)
        next unless element
    
        image_url = element['src'] || element['data-src']
        if image_url.present?
          Rails.logger.info("Found image URL: #{image_url}")
          return image_url
        end
      end
      nil
    end
  
    def captcha_detected?(page)
      return false if page.nil? || page.body.nil?
      page.title.to_s.include?("CAPTCHA") || page.body.to_s.include?("captcha")
    end
  
    def cache_key
      "scraper:#{Digest::MD5.hexdigest(@url)}"
    end
  
    def cached_result
      Rails.cache.read(cache_key)
    end
  
    def cache_result(result)
      Rails.cache.write(cache_key, result, expires_in: @cache_duration)
    end
  end
  