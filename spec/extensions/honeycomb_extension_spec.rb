require 'support/fakehoney'

require 'sequel/extensions/honeycomb'

RSpec.shared_examples_for 'records a database query' do |name:, sql_match:, sql_not_match: nil|
  it 'sends a db event' do
    expect(last_event.data['type']).to eq('db')
  end

  it "sets 'name' to #{name.inspect} (although something more informative would be nicer!)" do
    expect(last_event.data['name']).to eq(name)
  end

  it 'records the SQL query' do
    expect(last_event.data).to include('db.sql' => sql_match)
  end

  it 'records the table being queried' do
    expect(last_event.data).to include('db.table' => 'animals')
  end

  it 'records the parameterised SQL query rather than the literal parameter values' do
    pending 'find out if this is feasible for Sequel'

    expect(last_event.data['db.sql']).to_not match(sql_not_match)
  end if sql_not_match

  it 'records how long the statement took' do
    expect(last_event.data['duration_ms']).to be_a Numeric
  end

  it 'includes meta fields in the event' do
    expect(last_event.data).to include(
      'meta.package' => 'sequel',
      'meta.package_version' => Sequel::VERSION,
    )
  end
end

RSpec.describe Sequel::Extensions::Honeycomb do
  let(:last_event) { $fakehoney.events.last }

  after { $fakehoney.reset }

  context 'after an insert' do
    before { TestDB.Animals.insert name: 'Max', species: 'Lion' }

    include_examples 'records a database query',
      name: 'INSERT',
      sql_match: /^INSERT INTO "animals"/,
      sql_not_match: /Lion/
  end

  context 'after a select' do
    before do
      TestDB.Animals.insert name: 'Pooh', species: 'Bear'
      @sanders = TestDB.Animals.where(species: 'Bear').first
    end

    include_examples 'records a database query',
      name: 'SELECT',
      sql_match: /^SELECT .* FROM "animals"/,
      sql_not_match: /Bear/

    it 'records how many records were returned' do
      pending 'depends on underlying adapter API?'

      expect(last_event.data['db.num_rows_returned']).to eq(1)
    end
  end

  context 'after an update' do
    before do
      @robin_id = TestDB.Animals.insert name: 'Robin Hood', species: 'Fox'
      TestDB.Animals.where(id: @robin_id).update(name: 'Robert of Loxley')
    end

    it 'records a database query' do
      pending 'need to hook in at a different level (Sequel::Database#execute or Sequel::Dataset#execute_dui)'
      fail "doesn't send events for UPDATE"

      #name: 'UPDATE',
      #sql_match: /^UPDATE "animals"/,
      #sql_not_match: /Robert/
    end
  end

  context 'after a delete' do
    before do
      @robin_id = TestDB.Animals.insert name: 'Robin Hood', species: 'Fox'
      TestDB.Animals.where(id: @robin_id).delete
    end

    it 'records a database query' do
      pending 'need to hook in at a different level (Sequel::Database#execute or Sequel::Dataset#execute_dui)'
      fail "doesn't send events for DELETE"

      #name: 'DELETE',
      #sql_match: /^DELETE FROM "animals"/
    end
  end

  context 'if the database raises an error' do
    before do
      expect { TestDB.Animals.where(habitat: 'jungle').count }.to raise_error(Sequel::DatabaseError, /habitat/)
    end

    it 'records the exception' do
      expect(last_event.data).to include(
        'db.error' => 'Sequel::DatabaseError',
        'db.error_detail' => /habitat/,
      )
    end

    it 'still records how long the statement took' do
      expect(last_event.data['duration_ms']).to be_a Numeric
    end
  end
end
