require 'rails_helper'

RSpec.describe Import::FileParser do
  let(:term) { FactoryBot.create :term }
  let(:import) { FactoryBot.create :import, term: term }
  let(:import_service) { ImportService.new(import) }

  it 'splits columns for semicolon separated values' do
    import.update! file: prepare_static_test_file('import_data.csv', open: true)
    import.import_options.update! column_separator: ';'

    expect(import_service.column_count).to eq(13)
  end

  it 'splits columns for comma separated values' do
    import.update! file: prepare_static_test_file('import_data_commas.csv', open: true)
    import.import_options.update! column_separator: ','

    expect(import_service.column_count).to eq(13)
  end
end
