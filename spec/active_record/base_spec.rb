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

      it 'updates the attribute before calling after callbacks' do
        MyRecord.create(id: 'some_id', name: 'Some name')

        allow(record).to receive(:after_s) { expect(record.name).to eq('Some name') }
        allow(record).to receive(:after_c) { expect(record.name).to eq('Some name') }
        allow(record).to receive(:after_com) { expect(record.name).to eq('Some name') }

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

        it 'clears any changes state on the instance' do
          record.upsert
          expect(record.changes).to be_empty
          expect(record.changed?).to be false
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

        it 'clears any changes' do
          upserted = MyRecord.new(id: key, name: 'other')
          upserted.upsert
          expect(upserted.changes).to be_empty
          expect(upserted.changed?).to be false
        end

        context 'when specifying attributes' do
          it 'sets all the specified attributes' do
            upserted = MyRecord.new(id: key)
            upserted.upsert(attributes: [:id, :name])
            expect(upserted.name).to eq(nil)
          end
        end

        context 'with opts' do
          let(:attrs) { {make: 'Ford', name: 'Focus', year: 2017 } }
          let!(:vehicle) { Vehicle.create(attrs) }

          context 'with upsert_keys' do
            it 'allows upsert_keys to be set when #upsert is called' do
              upserted = Vehicle.new({ make: 'Volkswagen', name: 'Golf', year: attrs[:year] })
              expect { upserted.upsert(opts: { upsert_keys: [:year] }) }.not_to change { Vehicle.count }.from(1)
              expect(upserted.id).to eq(vehicle.id)
            end
          end

          context 'with upsert_options' do
            it 'allows upsert_options to be set when #upsert is called' do
              upserted = Vehicle.new({ make: attrs[:make], name: 'GT', wheels_count: 4 })
              expect { upserted.upsert(opts: { upsert_keys: [:make], upsert_options: { where: 'year IS NULL' } }) }.to change { Vehicle.count }.from(1).to(2)
              expect(upserted.id).not_to eq(vehicle.id)
            end
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

    describe '#upsert_operation' do
      let(:attributes) { { id: 1 } }

      context 'when no upsert has been tried' do
        it 'returns nil' do
          record = MyRecord.new(attributes)
          expect(record.upsert_operation).to_not be
        end
      end

      context 'when the record does not exist' do
        it 'returns create' do
          record = MyRecord.upsert(attributes)
          expect(record.upsert_operation).to eq(:create)
        end
      end

      context 'when the record already exists' do
        before { MyRecord.create(attributes) }

        it 'returns update' do
          record = MyRecord.upsert(attributes)
          expect(record.upsert_operation).to eq(:update)
        end
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

        context 'with opts' do
          let(:attrs) { {make: 'Ford', name: 'Focus', year: 2017 } }
          let!(:vehicle) { Vehicle.create(attrs) }

          context 'with upsert_keys' do
            it 'allows upsert_keys to be set when .upsert is called' do
              expect { Vehicle.upsert({ make: 'Volkswagen', name: 'Golf', year: attrs[:year] }, opts: { upsert_keys: [:year] }) }.not_to change { Vehicle.count }.from(1)
              expect(vehicle.reload.make).to eq('Volkswagen')
            end
          end

          context 'with upsert_options' do
            it 'allows upsert_options to be set when #upsert is called' do
              expect { Vehicle.upsert({ make: attrs[:make], name: 'GT', wheels_count: 4 }, opts: { upsert_keys: [:make], upsert_options: { where: 'year IS NULL' } }) }.to change { Vehicle.count }.from(1).to(2)
              expect(vehicle.reload.wheels_count).to be_nil
            end
          end
        end
      end

      context 'with assocations' do
        let!(:existing) { Vehicle.create!(make: 'Make', name: 'Name') }
        let(:account) { Account.create! }

        it 'updates the foreign keys' do
          expect {
            Vehicle.upsert!(make: existing.make, name: existing.name, account: account)
          }.to change { existing.reload.account_id }.from(nil).to(account.id)
        end
      end

      context 'when another index violation is made' do
        it 'raises an error' do
          record = MyRecord.create(name: 'somename', wisdom: 1)
          MyRecord.create(name: 'other', wisdom: 2)
          expect { MyRecord.upsert(id: record.id, wisdom: 2) }.to raise_error(ActiveRecord::RecordNotUnique)
        end
      end

      context 'when updating attributes from the database' do
        it 'does not call setter methods' do
          record = MyRecord.new(name: 'somename', wisdom: 1)
          expect(record).to_not receive(:name=).with('somename')
          record.upsert
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
