module ActiveRecord
  RSpec.describe 'Base' do
    describe '.upsert_keys' do
      context 'when using inheritance' do
        context 'and not setting subclass upsert keys' do
          it 'returns the superclass upsert keys' do
            expect(Bicycle.upsert_keys).to eq(Vehicle.upsert_keys)
          end
        end
      end
    end
  end
end
