module ActiveRecord
  RSpec.describe 'key exclusion' do
    describe '#upsert' do
      let(:record) { DefaultingRecord.new(name: 'Alice') }
      it 'allows the database to set default column values' do
        record.upsert(opts: {upsert_keys: [:name]})
        expect(record.uuid).to_not be_nil
        expect(record.uuid.size).to eq(36)
        expect(record.uuid).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
      end
    end
  end
end