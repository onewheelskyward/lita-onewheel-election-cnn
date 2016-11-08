require 'spec_helper'

describe Lita::Handlers::OnewheelElectionCnn, lita_handler: true do
  it { is_expected.to route_command('election') }

  it 'shows the current election results' do
    mock = File.open('spec/fixtures/election.json').read
    allow(RestClient).to receive(:get) { mock }
    send_command 'election'
    expect(replies[0]).to eq("Hillary Clinton: 0.0%")
    expect(replies[1]).to eq("Donald Trump: 0.0%")
  end

  it 'shows a winner' do
    mock = File.open('spec/fixtures/winner.json').read
    allow(RestClient).to receive(:get) { mock }
    send_command 'election'
    expect(replies[0]).to eq("Hillary Clinton: 0.0% WINNER! 0 electoral votes.")
    expect(replies[1]).to eq("Donald Trump: 0.0%")
  end

  it 'shows by state' do
    mock = File.open('spec/fixtures/election.json').read
    allow(RestClient).to receive(:get) { mock }
    send_command 'election va'
    expect(replies[0]).to eq("Virginia (13 electoral votes) - Hillary Clinton: 0.0%")
    expect(replies[1]).to eq("Virginia (13 electoral votes) - Donald Trump: 0.0%")
  end

  it 'shows by STATE' do
    mock = File.open('spec/fixtures/election.json').read
    allow(RestClient).to receive(:get) { mock }
    send_command 'election VA'
    expect(replies[0]).to eq("Virginia (13 electoral votes) - Hillary Clinton: 0.0%")
    expect(replies[1]).to eq("Virginia (13 electoral votes) - Donald Trump: 0.0%")
  end

  it 'shows by full state name downcase' do
    mock = File.open('spec/fixtures/election.json').read
    allow(RestClient).to receive(:get) { mock }
    send_command 'election new york'
    expect(replies[0]).to eq("NEW YORK (29 electoral votes) - Hillary Clinton: 0.0%")
    expect(replies[1]).to eq("NEW YORK (29 electoral votes) - Donald Trump: 0.0%")
  end
end
