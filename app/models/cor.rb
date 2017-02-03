class Cor

  PRETA = 'PRETA'
  BRANCA = 'BRANCA'

  def self.contrario_de(cor)
    return PRETA if cor == BRANCA
    BRANCA
  end
end