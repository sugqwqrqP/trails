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
  login_id: "seed_saburou",
  user_fullname: "シード三郎",
  password: "Seed3!",
  password_confirmation: "Seed3!",
  role: 0
)

User.create!(
  login_id: "seed_saburou2",
  user_fullname: "シード三郎",
  password: "Seed3!",
  password_confirmation: "Seed3!",
  role: 0
)

User.create!(
  login_id: "seed_saburou3",
  user_fullname: "シード三郎",
  password: "Seed3!",
  password_confirmation: "Seed3!",
  role: 0
)
