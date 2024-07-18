class User < ApplicationRecord
  USER_PARAMS = [:name, :email, :password, :password_confirmation].freeze
  attr_accessor :remember_token, :activation_token

  before_save :downcase_email
  before_create :create_activation_digest
  scope :recent, ->{order(created_at: :desc)}

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

  validates :password,
            presence: true,
            length: {minimum: 6},
            allow_nil: true

  has_secure_password

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost => cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  def forget
    update_column(:remember_digest, nil)
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
