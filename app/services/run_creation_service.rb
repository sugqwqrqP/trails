class RunCreationService
  def self.create!(attrs, context: nil)
    ActiveRecord::Base.transaction do
      run = Run.new(attrs)
      run.save!(context: context)

      create_cars!(run)
      create_seats!(run)

      run
    end
  end

  def self.create_cars!(run)
    fabulous = CarType.find_by!(name: "fabulous")
    reserved = CarType.find_by!(name: "reserved")
    green    = CarType.find_by!(name: "green")

    Car.create!(run: run, car_type: fabulous, number: 1)

    [2, 3, 6, 7, 8].each do |no|
      Car.create!(run: run, car_type: reserved, number: no)
    end

    [4, 5].each do |no|
      Car.create!(run: run, car_type: green, number: no)
    end
  end

  def self.create_seats!(run)
    run.cars.includes(:car_type).each do |car|
      case car.car_type.name
      when "fabulous"
        (1..6).each do |room_no|
          Seat.create!(car: car, row: room_no, column: "ROOM")
        end
      when "reserved"
        (1..8).each do |row|
          %w[A B C D E].each do |col|
            Seat.create!(car: car, row: row, column: col)
          end
        end
      when "green"
        (1..8).each do |row|
          %w[A B C D].each do |col|
            Seat.create!(car: car, row: row, column: col)
          end
        end
      end
    end
  end
end
