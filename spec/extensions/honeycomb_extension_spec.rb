require 'support/fakehoney'

require 'sequel/extensions/honeycomb'

RSpec.shared_examples_for 'records a database query' do |name:, sql_match:|
  it 'records the SQL query' do
    expect(last_event.data).to include(sql: sql_match)
  end

  it 'records how long the statement took' do
    expect(last_event.data[:durationMs]).to be_a Numeric
  end
end

RSpec.describe Sequel::Extensions::Honeycomb do
  let(:last_event) { $fakehoney.events.last }

  after { $fakehoney.reset }

  context 'after an insert' do
    before { TestDB.Animals.insert name: 'Max', species: 'Lion' }

    include_examples 'records a database query',
      name: 'INSERT',
      sql_match: /^INSERT INTO "animals"/
  end
end
