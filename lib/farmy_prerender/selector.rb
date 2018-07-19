# frozen_string_literal: true

module FarmyPrerender
  class Selector
    def initialize(app, options)
      @app = app
      @render_server = options[:render_server]
      @use_redis = !options[:redis].nil?
      @tool = Tool.new(options)
    end

    def call(env)
      return build_response(env, rendered_response(env)) if should_rendered_view?(env)
      status, headers, response = @app.call(env)
      [status, headers, response]
    end

    def rendered_response(env)
      key_uri = env['REQUEST_URI']
      @use_redis ? @tool.rendered_view(key_uri) : @tool.rendered_view_raw(key_uri)
    end

    def build_response(env, new_response)
      return false unless new_response
      headers = {
          'Content-Length' => new_response.length.to_s
      }
      [200, Rack::Utils::HeaderHash.new(headers), [new_response]]
    end

    def should_rendered_view?(env)
      return false unless render_server_alive?
      return true if is_robot?(env)
      return true if has_render_param?(env)
      false
    end

    def is_robot?(env)
      user_agent = env['HTTP_USER_AGENT']
      %w(googlebot facebookbot twitterbot WhatsApp).any? do |crawler_user_agent|
        user_agent.downcase.include?(crawler_user_agent.downcase)
      end
    end

    def has_render_param?(env)
      query_params = Rack::Utils.parse_query(Rack::Request.new(env).query_string)
      true if query_params.has_key?('_force_rendered_') && !query_params.has_key?('url')
    end

    def render_server_alive?
      uri_server = URI(@render_server)
      begin
        Timeout.timeout(120) do
          s = TCPSocket.new(uri_server.hostname, uri_server.port)
          s.close
        end
        return true
      rescue Errno::ECONNREFUSED, Timeout::Error, StandardError
        return false
      end
    end

  end
end
