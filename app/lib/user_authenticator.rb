class UserAuthenticator
  class AuthenticationError < StandardError; end

  attr_reader :authenticator

  def initialize(code: nil)
    @authenticator =
      code.present? ? Oauth.new(code) : Standard.new(login: nil, password: nil)
  end

  def perform
    authenticator.perform
  end

  def user
    authenticator.user
  end

  def access_token
    authenticator.access_token
  end
end
