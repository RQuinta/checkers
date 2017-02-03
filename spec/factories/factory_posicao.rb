FactoryGirl.define do

  factory :posicao do

    trait :com_posicao_x2_y2 do
      x 2
      y 2
    end

    trait :com_posicao_x7_y5 do
      x 7
      y 5
    end

    trait :com_posicao_x5_y5 do
      x 5
      y 5
    end

    trait :com_posicao_x0_y0 do
      x 0
      y 0
    end

    trait :com_posicao_x1_y1 do
      x 1
      y 1
    end

  end

end