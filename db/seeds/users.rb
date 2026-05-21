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
  login_id: "test_user1",
  user_fullname: "テストユーザー",
  password: "TestUser1!",
  password_confirmation: "TestUser1!",
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
  三谷 辻本 川瀬 畑 木原 浜口 古屋 大友 遠山 塩田
  神山 河内 齊藤 新井 奥村 河野 安藤 坂本 竹内 岩田
  平田 上野 森田 宮崎 石田 松井 小沢 服部 稲垣
  吉川 野村 坂井 大竹 永井 森本 宮田 渡部 田口
  福田 大西 大橋 石井 山本 中村 小林 井上
]
given_names = %w[
  太郎 大輔 翔 直樹 健太 悠斗 翔太 颯太 亮 直人
  大樹 拓海 健 瞳 美咲 沙織 彩香 由美 恵 里奈
  優花 真由 美月 さくら 陽菜 葵 愛 実咲 結衣 明日香
  航平 拓也 颯 真琴 葉月 杏奈 美羽 由佳 真央 ひなた
  凛 太一 皓介 遼 祐樹 奈々 香織 美紀 菜月 佳奈
  光 蓮 透 涼太 侑花 悠香 玲奈 こころ 美優 瑞希
]

created = 0
index = 7
while created < 200
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
