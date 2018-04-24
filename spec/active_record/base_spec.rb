module ActiveRecord
  RSpec.describe 'Base' do
    describe '#upsert' do
      let(:record) { MyRecord.new(id: 'some_id') }
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

        it 'creates record with all the attributes it is initialized with' do
          record = MyRecord.new(id: 25, name: 'Some name', wisdom: 3)
          record.upsert(attributes: [:id, :name])
          expect(record.reload.wisdom).to eq(3)
        end
      end

      context 'when the record already exists' do
        let(:key) { 1 }
        before { MyRecord.create(id: key, name: 'somename') }

        it 'sets the updated_at timestamp' do
          first_updated_at = MyRecord.find(key).updated_at
          upserted = MyRecord.new(id: key)
          upserted.upsert
          expect(upserted.reload.updated_at).to be > first_updated_at
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

        context 'when specifying attributes' do
          it 'sets all the specified attributes' do
            upserted = MyRecord.new(id: key)
            upserted.upsert(attributes: [:id, :name])
            expect(upserted.name).to eq(nil)
          end
        end
      end

      context 'when the record is not new' do
        it 'raises an error' do
          record = MyRecord.create(name: 'somename')
          record.save
          expect { record.upsert }.to raise_error(RecordSavedError)
        end
      end

      context 'with validation' do
        it 'does not upsert if the object is invalid' do
          record = Vehicle.new(wheels_count: 4)
          expect { record.upsert }.to_not change{ Vehicle.count }
          expect(record.upsert).to eq(false)
        end

        it 'saves the object if validate: false is passed' do
          record = Vehicle.new(wheels_count: 4)
          expect { record.upsert(validate: false) }.to change{ Vehicle.count }.by(1)
        end
      end

      context "when supporting a partial index" do
        before { Account.create(name: 'somename', active: true) }

        context 'when the record matches the partial index' do
          it 'raises an error' do
            expect{ Account.upsert!(name: 'somename', active: true) }.not_to change{ Account.count }.from(1)
          end
        end

        context 'when the record does meet the where clause' do
          it 'raises an error' do
            expect{ Account.upsert!(name: 'somename', active: false) }.to change{ Account.count }.from(1).to(2)
          end
        end
      end
    end

    describe '#upsert!' do
      it 'raises ActiveRecord::RecordInvalid if the object is invalid' do
        record = Vehicle.new(wheels_count: 4)
        expect { record.upsert! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe '.upsert' do
      context 'when the record already exists' do
        let(:key) { 1 }
        let(:attributes) { {id: key, name: 'othername', wisdom: nil} }
        let(:existing_updated_at) { Time.new(2017, 1, 1) }
        let!(:existing) { MyRecord.create(id: key, name: 'somename', wisdom: 2, updated_at: existing_updated_at) }

        it 'updates all passed attributes' do
          record = MyRecord.upsert(attributes)
          expect(record.name).to eq(attributes[:name])
          expect(record.wisdom).to eq(attributes[:wisdom])
        end

        it 'sets the updated_at timestamp' do
          record = MyRecord.upsert(attributes)
          expect(record.reload.updated_at).to be > existing_updated_at
        end

        context 'with conditions' do
          it 'does not update the record if the condition does not match' do
            expect {
              MyRecord.upsert(attributes, arel_condition: MyRecord.arel_table[:wisdom].gt(3))
            }.to_not change { existing.reload.name }
          end

          it 'updates the record if the condition matches' do
            expect {
              MyRecord.upsert(attributes, arel_condition: MyRecord.arel_table[:wisdom].lt(3))
            }.to change { existing.reload.wisdom }.to(nil)
            expect(existing.reload.updated_at).to be > existing_updated_at
          end
        end
      end

      context 'when another index violation is made' do
        it 'raises an error' do
          record = MyRecord.create(name: 'somename', wisdom: 1)
          MyRecord.create(name: 'other', wisdom: 2)
          expect { MyRecord.upsert(id: record.id, wisdom: 2) }.to raise_error(ActiveRecord::RecordNotUnique)
        end
      end
    end

    describe '.upsert!' do
      it 'raises ActiveRecord::RecordInvalid if the object is invalid' do
        expect { Vehicle.upsert!(wheels_count: 4) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
