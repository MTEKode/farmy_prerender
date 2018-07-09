# frozen_string_literal: true

class  FarmyPrerender
  class Selector
    def initialize(app)
      @app = app
    end

    def call(env)
      return build_response(env, rendered_response(env)) if should_rendered_view?(env)
      status, headers, response = @app.call(env)
      [status, headers, response]
    end

    def rendered_response(env)
      key_uri = env['REQUEST_URI']
      FarmyPrerender.instance.rendered_view(key_uri)
    end

    def build_response(env, new_response)
      return false unless new_response
      headers = {
          'Content-Length' => new_response.length.to_s
      }
      [200, Rack::Utils::HeaderHash.new(headers), [new_response]]
    end

    def should_rendered_view?(env)
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
      request = Rack::Request.new(env)
      true if Rack::Utils.parse_query(request.query_string).has_key?('_escaped_fragment_')
    end

  end
end
