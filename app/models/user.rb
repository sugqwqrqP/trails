class User < ApplicationRecord


  has_many :reservations, dependent: :destroy
  enum role: { user: 0, staff: 1, operator: 2 }

  def role_label
    case role
    when "user"     then "利用者"
    when "staff"    then "駅員"
    when "operator" then "運行管理者"
    end
  end

  # ログインID
  validates :login_id,
    presence: { message: "を入力してください" }

  validates :login_id,
    length: {
      in: 6..20,
      message: "は6文字以上20文字以下で入力してください"
    },
    format: {
      with: /\A[a-zA-Z0-9_]+\z/,
      message: "は英数字とアンダースコアのみ使用できます"
    },
    uniqueness: { message: "はすでに使用されています" },
    if: -> { login_id.present? }

  # 氏名
  validates :user_fullname,
    presence: { message: "を入力してください" },
    length: {
      maximum: 20,
      message: "は20文字以内で入力してください"
    }

  # パスワード
  has_secure_password

  validates :password,
    length: {
      in: 6..20,
      message: "は6文字以上20文字以下で入力してください"
    },
    format: {
      with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@¥!$&]).+\z/,
      message: "は大文字・小文字・数字・記号(@¥!$&)を含めてください"
    },
    unless: -> { password.blank? }

    # 駅員と運行管理者を除外
    scope :customers, -> { where(role: :user) }
end
