FactoryGirl.define do
  factory :tabuleiro do

    trait :com_pecas_de_baixo_brancas do
      tabuleiro Tabuleiro.new Cor::BRANCA
    end

    trait :com_pecas_de_baixo_pretas do
      tabuleiro Tabuleiro.new Cor::PRETA
    end

  end
end