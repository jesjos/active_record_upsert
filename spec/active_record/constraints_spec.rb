module ActiveRecord
  RSpec.describe 'Constraint-based conflict keys' do
    describe '#upsert' do
      let(:record) { ConstraintExample.new(name: 'John', age: 14, color: 'hot pink') }

      context 'when the record does not exist' do
        it 'sets timestamps' do
          record.upsert
          expect(record.created_at).not_to be_nil
          expect(record.updated_at).not_to be_nil
        end

        it 'sets id' do
          record.color = 'blue'
          expect(record.id).to be_nil
          record.upsert(attributes: [:color])
          expect(record.id).not_to be_nil
        end
      end

      context 'when the record already exists' do
        let(:attrs) { {name: 'John', age: '14', color: 'blue'} }
        before { ConstraintExample.create(attrs) }

        it 'sets the updated_at timestamp' do
          first_updated_at = ConstraintExample.find_by(attrs).updated_at
          upserted = ConstraintExample.new(attrs)
          upserted.upsert
          expect(upserted.updated_at).to be > first_updated_at
        end

        it 'does not reset the created_at timestamp' do
          first_created_at = ConstraintExample.find_by(attrs).created_at
          upserted = ConstraintExample.new(attrs)
          upserted.upsert
          expect(upserted.created_at).to eq(first_created_at)
        end

      end

      context 'when the record is not new' do
        let(:attrs) { {name: 'John', age: '14'} }
        it 'raises an error' do
          record = ConstraintExample.create(attrs)
          record.save
          expect { record.upsert }.to raise_error(RecordSavedError)
        end
      end
    end
  end
end
