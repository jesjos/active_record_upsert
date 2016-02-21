module ActiveRecord
  describe Base do
    describe '#upsert' do
      let(:record) { MyRecord.new(id: 'some_id') }
      it 'calls save/create callbacks' do
        expect(record).to receive(:before_s)
        expect(record).to receive(:after_s)
        expect(record).to receive(:after_c)
        expect(record).to receive(:before_c)
        record.upsert
      end

      context 'when the record already exists' do
        let(:key) { 1 }
        before { MyRecord.create(id: key, name: 'somename') }
        it 'sets the updated_at timestamp' do
          first_updated_at = MyRecord.find(key).updated_at
          upserted = MyRecord.new(id: key)
          upserted.upsert
          expect(upserted.updated_at).to be > first_updated_at
        end

        it 'does not reset the created_at timestamp' do
          first_created_at = MyRecord.find(key).created_at
          upserted = MyRecord.new(id: key)
          upserted.upsert
          expect(upserted.created_at).to eq(first_created_at)
        end

        it 'loads the data from the db' do
          upserted = MyRecord.new(id: key)
          upserted.upsert
          expect(upserted.name).to eq('somename')
        end
      end

      context 'when the record is not new' do
        it 'raises an error' do
          record = MyRecord.create(name: 'somename')
          record.save
          expect { record.upsert }.to raise_error(RecordSavedError)
        end
      end
    end
  end
end
