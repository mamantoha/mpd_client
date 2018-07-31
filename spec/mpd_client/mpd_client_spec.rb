# frozen_string_literal: true

require 'spec_helper'

describe MPD::Client do
  it 'should have version' do
    expect(MPD::Client::VERSION).to_not be_nil
  end

  describe '#initialize' do
    it 'should create new client' do
      client = MPD::Client.new

      expect(client.connected?).to eq(false)
    end
  end
end
