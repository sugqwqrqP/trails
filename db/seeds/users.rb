User.create!(
  login_id: "test_taro",
  user_fullname: "テスト太郎",
  password: "Abc123!",
  password_confirmation: "Abc123!",
  role: 0
)

User.create!(
  login_id: "staff_admin",
  user_fullname: "駅員",
  password: "StaffAdmin1234$",
  password_confirmation: "StaffAdmin1234$",
  role: 1
)
