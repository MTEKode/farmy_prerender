module FarmyPrerender
  class Tool
    PRERENDER_REDIS_KEY = 'prerender_'

    def initialize(options)
      raise('Need Initialize host and render_server') if valid_options?(options)
      @redis = Redis.new(driver: :hiredis)
      @host = options['host']
      @render_server = options['render_server']
    end

    def render(path)
      response = HTTP.post("#{@render_server}/render", json: {
          renderType: 'html',
          fullpage: 'true',
          # javascript: 'var prerenderData = window.angular && window.angular.version;',
          url: "#{@host}#{path}"
      })
      parsed_body = parse_body(response.body.to_str) if response && response.body
      @redis.del("#{@host}#{path}")
      @redis.set("#{PRERENDER_REDIS_KEY}#{@host}#{path}", parsed_body)
    end

    def parse_body(body)
      begin
        JSON.parse(body)['content']
      rescue
        body
      end
    end

    def valid_body?(html)
      json_body = Nokogiri::HTML(html).css('body')
      json_body && json_body.length > 0
    end

    def rendered_view(path)
      value = @redis.get("#{PRERENDER_REDIS_KEY}#{@host}#{path}")
      if value and valid_body?(value)
        value
      else
        render(path)
        rendered_view(path)
      end
    end

    def rendered_view_raw(path)
      parsed_body = parse_body(HTTP.get("#{@render_server}/#{@host}#{path}").body.to_s)
      if parsed_body.empty?
        render(path)
        rendered_view_raw(path)
      else
        parsed_body
      end
    end

    def fix_url(txt)
      txt.tr('src="/', "src=\"#{@host}").tr('href="/', "href=\"#{@host}")
    end

    def valid_options?(options)
      options.has_key?('render_server') && options.has_key?('host')
    end
  end
end