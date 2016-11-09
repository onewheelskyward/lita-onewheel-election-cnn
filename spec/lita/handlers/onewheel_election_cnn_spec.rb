require 'spec_helper'

describe Lita::Handlers::OnewheelElectionCnn, lita_handler: true do
  it { is_expected.to route_command('election') }
  it { is_expected.to route_command('e') }
  it { is_expected.to route_command('election ny') }
  it { is_expected.to route_command('e ny') }
  it { is_expected.to route_command('ansielection') }

  it 'shows the current election results' do
    mock = File.open('spec/fixtures/election.json').read
    allow(RestClient).to receive(:get) { mock }
    send_command 'election'
    expect(replies[0]).to eq("United States 2016 Presidential Election, 1% reporting.")
    expect(replies[1]).to eq("Hillary Clinton: 0.0%, 0 popular votes, 0 electoral votes.")
    expect(replies[2]).to eq("Donald Trump: 0.0%, 0 popular votes, 19 electoral votes.")
  end

  it 'shows a winner' do
    mock = File.open('spec/fixtures/winner.json').read
    allow(RestClient).to receive(:get) { mock }
    send_command 'election'
    expect(replies[0]).to eq("United States 2016 Presidential Election, 1% reporting.")
    expect(replies[1]).to eq("Hillary Clinton: 0.0%, 0 popular votes, 0 electoral votes.  WINNER!  ")
    expect(replies[2]).to eq("Donald Trump: 0.0%, 0 popular votes, 0 electoral votes.")
  end

  it 'shows by state' do
    mock = File.open('spec/fixtures/election.json').read
    allow(RestClient).to receive(:get) { mock }
    send_command 'election va'
    expect(replies[0]).to eq("Virginia, 13 electoral votes, 0% reporting")
    expect(replies[1]).to eq("Hillary Clinton: 0.0%, 0 popular votes")
    expect(replies[2]).to eq("Donald Trump: 0.0%, 0 popular votes")
  end

  it 'shows by STATE' do
    mock = File.open('spec/fixtures/election.json').read
    allow(RestClient).to receive(:get) { mock }
    send_command 'election VA'
    expect(replies[0]).to eq("Virginia, 13 electoral votes, 0% reporting")
    expect(replies[1]).to eq("Hillary Clinton: 0.0%, 0 popular votes")
    expect(replies[2]).to eq("Donald Trump: 0.0%, 0 popular votes")
  end

  it 'shows by full state name downcase' do
    mock = File.open('spec/fixtures/election.json').read
    allow(RestClient).to receive(:get) { mock }
    send_command 'election new york'
    expect(replies[0]).to eq("NEW YORK, 29 electoral votes, 0% reporting")
    expect(replies[1]).to eq("Hillary Clinton: 0.0%, 0 popular votes")
    expect(replies[2]).to eq("Donald Trump: 0.0%, 0 popular votes")
  end

  it 'ansis' do
    mock = File.open('spec/fixtures/election.json').read
    allow(RestClient).to receive(:get) { mock }
    send_command 'ansielection'
    expect(replies.last).to eq("Clinton 0 |\u000312\u000300----------------------------👽-------------------------\u000304█\u000300| Trump 19")
  end
end
