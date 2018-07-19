# frozen_string_literal: true

module FarmyPrerender
  class Tool
    PRERENDER_REDIS_KEY = 'prerender_'

    def initialize(options)
      raise('Need Initialize host and render_server') unless valid_options?(options)
      @redis = options[:redis]
      @host = options[:host]
      @render_server = options[:render_server]
    end

    def render(path)
      path = fix_render_param(path)
      response = HTTP.post("#{@render_server}/render", json: {
          renderType: 'html',
          fullpage: 'true',
          # javascript: 'var prerenderData = window.angular && window.angular.version;',
          url: "#{@host}#{path}"
      })
      parsed_body = parse_body(response.body.to_str) if response && response.body
      @redis.try(:del, "#{PRERENDER_REDIS_KEY}#{@host}#{path}")
      @redis.try(:set, "#{PRERENDER_REDIS_KEY}#{@host}#{path}", parsed_body)
      @redis.try(:expireat, "#{PRERENDER_REDIS_KEY}#{@host}#{path}", (Time.now + 5.minute).to_i)
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
      return false if json_body == '<body><p>undefined</p></body>'
      return true if json_body && json_body.length > 0
    end

    def rendered_view(path)
      path = fix_render_param(path)
      value = @redis.try(:get, "#{PRERENDER_REDIS_KEY}#{@host}#{path}")
      if value and valid_body?(value)
        value
      else
        render(path)
        rendered_view(path)
      end
    end

    def rendered_view_raw(path)
      path = fix_render_param(path)
      parsed_body = parse_body(HTTP.get("#{@render_server}/#{@host}#{path}").body.to_s)
      if parsed_body.empty?
        render(path)
        rendered_view_raw(path)
      else
        parsed_body
      end
    end

    def fix_url(txt)
      txt.gsub('src="/', "src=\"#{@host}").gsub('href="/', "href=\"#{@host}")
    end

    def fix_render_param(txt)
      txt.gsub('?_force_rendered_=', '')
    end

    def valid_options?(options)
      options.has_key?(:render_server) && options.has_key?(:host)
    end
  end
end