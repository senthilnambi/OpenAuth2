require 'active_support/inflector'

require_relative 'open_auth2/provider'
require_relative 'open_auth2/provider/base'
require_relative 'open_auth2/provider/default'
require_relative 'open_auth2/provider/facebook'
require_relative 'open_auth2/provider/google'

require_relative 'open_auth2/config'

module OpenAuth2
  VERSION = '0.0.1'

  # Raised in Config#provider= when user sets to provider not in
  # 'lib/open_auth2/provider/' or included by them manually.
  #
  class UnknownProvider < StandardError; end
end
