class User < ApplicationRecord
  has_secure_password

  enum role: { user: 0, staff: 1, operator: 2 }

  # ログインID
  validates :login_id, presence: true
  validates :login_id,
    length: { in: 6..20 },
    format: { with: /\A[a-zA-Z0-9_]+\z/ },
    uniqueness: true,
    unless: -> { login_id.blank? }

  # 氏名
  validates :user_fullname, presence: true
  validates :user_fullname,
    length: { maximum: 20 },
    unless: -> { user_fullname.blank? }

  # パスワード
  validates :password, presence: true
  validates :password,
    length: { in: 6..20 },
    format: {
      with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@¥!$&]).+\z/
    },
    unless: -> { password.blank? }
end
