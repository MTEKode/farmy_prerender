# frozen_string_literal: true

require_relative 'farmy_prerender/version'
require_relative 'farmy_prerender/selector'
require 'http'
require 'redis'


class FarmyPrerender
  include Singleton

  CHROMEDRIVER_VERSION = '2_40'
  HEADLESS_LOCAL = false

  def initialize
    @redis = Redis.new(driver: :hiredis)
    @render_server = 'http://localhost:5000'
    @host = 'http://staging5.farmy.ch'
  end

  def render(path)
    response = HTTP.post("#{@render_server}/render", json: {
        renderType: 'html',
        fullpage: 'true',
        javascript: 'var prerenderData = window.angular && window.angular.version;',
        url: "#{@host}#{path}"
    })
    parsed_body = parse_body(response.body.to_str) if response && response.body
    @redis.del("#{@host}#{path}")
    @redis.set("#{@host}#{path}", parsed_body)
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
    value = @redis.get("#{@host}#{path}")
    if value and valid_body?(value)
      value
    else
      render(path)
      rendered_view(path)
    end
  end

  def fix_url(txt)
    txt.tr('src="/', "src=\"#{@host}").tr('href="/', "href=\"#{@host}")
  end

end