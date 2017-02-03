class PosicaoTabuleiro

  attr_accessor :x, :y

  include ActiveModel::Validations

  validate :dentro_dos_limites

  #validar que x e y sao positivos

  def initialize(params)
    @x = params[:x]
    @y = params[:y]
  end

  def ==(outro)
    self.x == outro.x && self.y == outro.y
  end

  def dentro_dos_limites
    errors.add(:fora_dos_limites, 'A posição está fora dos limites do tabuleiro') unless Tabuleiro::LIMITES.member?(self.x) && Tabuleiro::LIMITES.member?(self.y)
  end
end