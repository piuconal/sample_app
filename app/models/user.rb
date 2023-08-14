class User < ApplicationRecord
  USER_PARAMS = [:name, :email, :password, :password_confirmation].freeze

  validates :name,
            presence: true,
            length: {
              in: Settings.user.name.min_length..Settings.user.name.max_length,
              too_long: "#{Settings.user.name.max_length}
                      characters is the maximum allowed",
              too_short: "#{Settings.user.name.min_length}
                      character is the minimum allowed"
            }

  validates :email,
            presence: true,
            length: {maximum: Settings.user.email.max_length},
            format: {with: /\A#{Settings.user.email.valid_regex}\z/},
            uniqueness: true

  has_secure_password

  before_save :downcase_email

  def self.digest string
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create string, cost => cost
  end

  private

  def downcase_email
    email.downcase!
  end
end
