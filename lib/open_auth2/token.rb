module OpenAuth2

  # Used to get Access/Refresh tokens from OAuth server.
  class Token
    extend DelegateToConfig
    include Connection

    # Called internally from Client#token only.
    #
    # Returns: self.
    #
    def initialize(config)
      @config      = config
      @faraday_url = authorize_url

      self
    end

    # Packages info from config & passed in arguments into an url that
    # user can to visit to authorize this app.
    #
    # Examples:
    #   token.build_code_url
    #   #=> 'http://...'
    #
    #   # or
    #   token.build_code_url(:scope => 'publish_stream')
    #
    # Accepts:
    #   params: (optional) Hash of additional config.
    #
    # Returns: String (url).
    #
    def build_code_url(params={})
      url = URI::HTTPS.build(:host  => host,
                             :path  => authorize_path,
                             :query => encoded_body(params))

      url.to_s
    end

    # Make request to OAuth server for access token & ask @config to
    # parse it. @config delegates to the appropriate provider.
    #
    # We ask @config since the format of response differs between
    # OAuth servers widely.
    #
    # Accepts:
    #   params: (optional) Hash of additional config to be sent with
    #           request.
    #
    # Returns: ?.
    #
    def get(params={})
      body        = get_body_hash(params)
      raw_request = post(body)

      parse(raw_request)
    end

    # Make request to OAuth server to refresh the access token &
    # ask @config to parse it.
    #
    # Accepts:
    #   params: (optional) Hash of additional config to be sent with
    #           request.
    #
    # Returns: ?.
    #
    def refresh(params={})
      body        = refresh_body_hash(params)
      raw_request = post(body)

      parse(raw_request)
    end

    def token_expired?
      token_expires_at > Time.now
    rescue
      nil
    end

    private

    # We use URI#parse to get rid of those pesky extra /.
    def host
      URI.parse(code_url).host
    end

    # Make travel safe.
    def encoded_body(params)
      URI.encode_www_form(url_body_hash(params))
    end

    # Combine default options & user arguments.
    def url_body_hash(params)

      # user can define scope as String or Array
      joined_scope = scope.join(',') if scope.respond_to?(:join)

      {
        :response_type => response_type,
        :client_id     => client_id,
        :redirect_uri  => redirect_uri,
        :scope         => joined_scope
      }.merge(params)
    end

    def get_body_hash(params)
      {
        :client_id      => client_id,
        :client_secret  => client_secret,
        :code           => code,
        :grant_type     => access_token_grant_name,
        :redirect_uri   => redirect_uri
      }.merge(params)
    end

    def refresh_body_hash(params)
       {
         :client_id         => client_id,
         :client_secret     => client_secret,
         :grant_type        => refresh_token_grant_name,
         refresh_token_name => refresh_token
       }.merge(params)
    end

    # Makes the actual request. `connection` is a Faraday object.
    def post(body)
      connection.post do |conn|
        conn.headers["Content-Type"] = "application/x-www-form-urlencoded"
        conn.headers["Accept"]       = "application/json"
        conn.url(token_path)
        conn.body = body
      end
    end

    def parse(response)
      @config.parse(response.body)
      response
    end
  end
end
