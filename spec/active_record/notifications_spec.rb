module ActiveRecord
  RSpec.describe 'Base' do

    describe '#upsert' do

      let(:events) { [] }

      before(:each) do
        @subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
          events << args
        end
      end

      after(:each) do
        ActiveSupport::Notifications.unsubscribe(@subscriber)
      end

      it 'emits an ActiveSupport notification with an appropriate name' do
        MyRecord.upsert(wisdom: 2)

        payload = events[-1][-1]
        expect(payload[:name]).to eq('MyRecord Upsert')
      end
    end

  end
end