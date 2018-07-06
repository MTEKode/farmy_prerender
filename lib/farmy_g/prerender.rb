# frozen_string_literal: true

require 'farmy/prerender/version'
require 'http'

module FarmyG
  class Prerender
    include Singleton

    CHROMEDRIVER_VERSION = '2_40'
    HEADLESS_LOCAL = false

    def initialize
      @render_server = 'http://localhost:5000'
      @host = 'http://lvh.me:3000'
    end

    def render(path)
      HTTP.get("#{@render_server}/render?url=#{@host}#{path}")
    end

    def rendered_view(path)
      HTTP.get("#{@render_server}/#{@host}#{path}").try(:body).try(:to_s)
    end
  end
end

