module ReservationsHelper
  def seat_type_label(type)
    {
      "reserved"  => "指定席",
      "green"     => "グリーン車",
      "fabulous"  => "ファビュラスルーム"
    }[type]
  end
end
