class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  before_save :downcase_email

  validates :name, presence: true, length: {maximum: 50}
  validates :emails, presence: true, length: {maximum: 255},
             format: {with: VALID_EMAIL_REGEX},
             uniqueness: true
  validates :age, presence: true,
             numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :phone, presence: true, format: {with: /\A\d{10,11}\z/}

  has_secure_password

  private
  def downcase_email
    emails.downcase!
  end
end
