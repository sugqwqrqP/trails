
module Staff::UsersHelper
  def role_label(role)
    case role
    when "user"
      "利用者"
    when "staff"
      "駅員"
    when "operator"
      "運行管理者"
    else
      role
    end
  end
end
