require 'spec_helper'

describe Lita::Handlers::OnewheelElectionCnn, lita_handler: true do
  it { is_expected.to route_command('election') }

  it 'shows the current election results' do
    mock = File.open('spec/fixtures/election.json').read
    allow(RestClient).to receive(:get) { mock }
    send_command 'election'
    expect(replies[0]).to eq("Hillary Clinton: 0.0%, 0% of precincts reporting.")
    expect(replies[1]).to eq("Donald Trump: 0.0%, 0% of precincts reporting.")
  end

  it 'shows a winner' do
    mock = File.open('spec/fixtures/winner.json').read
    allow(RestClient).to receive(:get) { mock }
    send_command 'election'
    expect(replies[0]).to eq("Hillary Clinton: WINNER! 0.0%, 0% of precincts reporting.")
    expect(replies[1]).to eq("Donald Trump: 0.0%, 0% of precincts reporting.")
  end
end
