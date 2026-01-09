User.create!(
  login_id: "staff_admin",
  user_fullname: "駅員",
  password: "StaffAdmin1234$",
  password_confirmation: "StaffAdmin1234$",
  role: 1
)

User.create!(
  login_id: "operator_admin",
  user_fullname: "運行管理者",
  password: "OperatorAdmin1234$",
  password_confirmation: "OperatorAdmin1234$",
  role: 2
)

User.create!(
  login_id: "test_taro",
  user_fullname: "テスト太郎",
  password: "Abc123!",
  password_confirmation: "Abc123!",
  role: 0
)

User.create!(
  login_id: "senshu_1",
  user_fullname: "専修太郎",
  password: "Senshu1!",
  password_confirmation: "Senshu1!",
  role: 0
)

User.create!(
  login_id: "senshu_2",
  user_fullname: "専修太郎",
  password: "Senshu2!",
  password_confirmation: "Senshu2!",
  role: 0
)

User.create!(
  login_id: "senshu_3",
  user_fullname: "専修太郎",
  password: "Senshu3!",
  password_confirmation: "Senshu3!",
  role: 0
)
