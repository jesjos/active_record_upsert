module ActiveRecord
  RSpec.describe 'Alernate conflict keys' do
    describe '#upsert' do
      let(:record) { DefaultingRecord.new(name: 'Alice') }
      it 'allows the database to set default column values' do
        record.upsert
        expect(record.uuid).to_no be_nil
      end
    end
  end
end