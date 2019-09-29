class UserAuthenticator
  class AuthenticationError < StandardError; end

  attr_reader :authenticator

  def initialize(code: nil, login: nil, password: nil)
    @authenticator =
      code.present? ? Oauth.new(code) : Standard.new(login, password)
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
