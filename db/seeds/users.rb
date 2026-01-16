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

family_names = %w[
  佐藤 鈴木 高橋 田中 渡辺 伊藤 山本 中村 小林 加藤
  吉田 山田 佐々木 山口 斎藤 松本 井上 木村 林 清水
  山崎 森 阿部 池田 橋本 石川 山下 中島 前田 藤田
]
given_names = %w[
  太郎 大輔 翔 直樹 健太 悠斗 翔太 颯太 亮 直人
  大樹 拓海 健 瞳 美咲 沙織 彩香 由美 恵 里奈
  優花 真由 美月 さくら 陽菜 葵 愛 実咲 結衣 明日香
]

created = 0
index = 1
while created < 30
  full_name = "#{family_names.sample} #{given_names.sample}"
  login_id = format("seed_user_%02d", index)
  index += 1

  User.create!(
    login_id: login_id,
    user_fullname: full_name,
    password: "SeedUser1234!",
    password_confirmation: "SeedUser1234!",
    role: 0
  )

  created += 1
end
