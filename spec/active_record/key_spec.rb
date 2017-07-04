module ActiveRecord
  describe 'Alernate conflict keys' do
    describe '#upsert' do
      let(:record) { Vehicle.new(make: 'Ford', name: 'Focus') }
      it 'calls save/create/commit callbacks' do
        expect(record).to receive(:before_s)
        expect(record).to receive(:after_s)
        expect(record).to receive(:after_c)
        expect(record).to receive(:before_c)
        expect(record).to receive(:after_com)
        record.upsert
      end

      context 'when the record does not exist' do
        it 'sets timestamps' do
          record.upsert
          expect(record.created_at).not_to be_nil
          expect(record.updated_at).not_to be_nil
        end
      end

      context 'when the record already exists' do
        let(:attrs) { {make: 'Ford', name: 'Focus'} }
        before { Vehicle.create(attrs) }
        it 'sets the updated_at timestamp' do
          first_updated_at = Vehicle.find_by(attrs).updated_at
          upserted = Vehicle.new(attrs)
          upserted.upsert
          expect(upserted.updated_at).to be > first_updated_at
        end

        it 'does not reset the created_at timestamp' do
          first_created_at = Vehicle.find_by(attrs).created_at
          upserted = Vehicle.new(attrs)
          upserted.upsert
          expect(upserted.created_at).to eq(first_created_at)
        end

        it 'loads the data from the db' do
          upserted = Vehicle.new(**attrs, wheels_count: 1)
          upserted.upsert
          expect(upserted.wheels_count).to eq(1)
        end
      end
      context 'different ways of setting keys' do
        let(:attrs) { {make: 'Ford', name: 'Focus'} }
        before { Vehicle.create(attrs) }
        it 'works with multiple symbol args' do
          Vehicle.upsert_keys :make, :name
          upserted = Vehicle.new(**attrs, wheels_count: 1)
          upserted.upsert
          expect(upserted.wheels_count).to eq(1)
        end
        it 'works with multiple string args' do
          Vehicle.upsert_keys 'make', 'name'
          upserted = Vehicle.new(**attrs, wheels_count: 1)
          upserted.upsert
          expect(upserted.wheels_count).to eq(1)
        end
        it 'works with array of symbols' do
          Vehicle.upsert_keys [:make, :name]
          upserted = Vehicle.new(**attrs, wheels_count: 1)
          upserted.upsert
          expect(upserted.wheels_count).to eq(1)
        end
        it 'works with array of strings' do
          Vehicle.upsert_keys ['make', 'name']
          upserted = Vehicle.new(**attrs, wheels_count: 1)
          upserted.upsert
          expect(upserted.wheels_count).to eq(1)
        end
        it 'works with a single symbol' do
          v = Vehicle.create
          Vehicle.upsert_keys :id
          upserted = Vehicle.new(id: v.id, wheels_count: 1)
          upserted.upsert
          expect(upserted.wheels_count).to eq(1)
          expect(upserted.id).to eq(v.id)
        end
        it 'works with a single string' do
          v = Vehicle.create
          Vehicle.upsert_keys 'id'
          upserted = Vehicle.new(id: v.id, wheels_count: 1)
          upserted.upsert
          expect(upserted.wheels_count).to eq(1)
          expect(upserted.id).to eq(v.id)
        end
      end

      context 'when the record is not new' do
        let(:attrs) { {make: 'Ford', name: 'Focus'} }
        it 'raises an error' do
          record = Vehicle.create(attrs)
          record.save
          expect { record.upsert }.to raise_error(RecordSavedError)
        end
      end
    end
  end
end
