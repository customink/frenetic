class Frenetic
  module StructureMethodDefiner
    def structure(&block)
      @_structure_block = Proc.new(&block) if block_given?
    end
  end
end
