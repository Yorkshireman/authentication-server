class AuthenticateUser
  prepend SimpleCommand
  attr_accessor :email, :password # review if this line is needed after everything is working

  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    JsonWebToken.encode(user_id: user.id) if user
  end

  private

  def user
    user = User.find_by_email(email)
    return user if user && user.authenticate(password)

    errors.add :user_authentication, 'Invalid credentials'
    nil
  end
end
