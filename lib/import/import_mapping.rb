class Import::ImportMapping
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  
  attr_accessor *Import::StudentImport::IMPORTABLE_ATTRIBUTES  
  attr_reader :lookup_table
  
  def initialize(hash = nil)
    @lookup_table_prepared = false
    
    unless hash.nil?
      hash.each do |column, value|
        value = value.to_sym
        if Import::StudentImport::IMPORTABLE_ATTRIBUTES.include? value
          self.send("#{value}=".to_sym, column)
        end
      end
    end
  end
  
  def mapping_for_key(key)
    prepare_lookup_table unless @lookup_table_prepared
    
    @lookup_table[key.to_s]
  end
  alias :[] :mapping_for_key
  
  
  private
  def prepare_lookup_table
    @lookup_table = Hash.new
    
    Import::StudentImport::IMPORTABLE_ATTRIBUTES.each do |key|
      value = self.send key
      @lookup_table[value.to_s] = key unless value.nil?
    end
    @lookup_table_prepared = true
  end
end