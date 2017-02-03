FactoryGirl.define do
  factory :movimento_peao do

    trait :com_posicao_x2_y2 do
      association :posicao_inicial, :com_posicao_x2_y2
      association :posicao_final, :com_posicao_x5_y5
    end

    trait :com_posicao_x5_y5 do
      association :posicao_inicial, :com_posicao_x5_y5
      association :posicao_final, :com_posicao_x2_y2
    end

    trait :com_posicao_x7_y5 do
      association :posicao_inicial, :com_posicao_x5_y5
      association :posicao_final, :com_posicao_x7_y5
    end

    trait :com_posicao_x0_y0 do
      association :posicao_inicial, :com_posicao_x0_y0
      association :posicao_final, :com_posicao_x1_y1
    end

    trait :com_posicao_x1_y1 do
      association :posicao_inicial, :com_posicao_x1_y1
      association :posicao_final, :com_posicao_x0_y0
    end

  end
end