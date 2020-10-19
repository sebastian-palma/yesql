# frozen_string_literal: true

require 'spec_helper'
require 'yesql/bindings/extract'

describe ::YeSQL::Bindings::Extract do
  describe '.call' do
    let(:indexed_bindings) do
      { site: 'af', sites: %w[cl mx], date: '2020-02-01', ids: [1, 2, 3] }.to_a
    end
    let(:hash) { {} }
    let(:index) { 1 }
    let(:value) { 'af' }

    subject do
      described_class.new(indexed_bindings, hash, index, value)
    end

    context '1st element in `indexed_bindings`' do
      it { expect(subject.bind_vals).to eq([nil, 'af']) }
      it { expect(subject.bind_vars).to eq('?') }
      it { expect(subject.last_val).to eq(1) }
      it { expect(subject.prev).to be_nil }
    end

    context '2nd element in `indexed_bindings`' do
      let(:hash) do
        {
          site: {
            bind_vars: '$1',
            bind_vals: [nil, 'af'],
            last_val: 1,
            match: :site,
            prev: nil,
            value: 'af'
          }
        }
      end
      let(:index) { 2 }
      let(:value) { %w[cl mx] }

      it { expect(subject.bind_vals).to eq([[nil, 'cl'], [nil, 'mx']]) }
      it { expect(subject.bind_vars).to eq('?, ?') }
      it { expect(subject.last_val).to eq(3) }
      it { expect(subject.prev).to eq(:site) }
    end

    context '3rd element in `indexed_bindings`' do
      let(:hash) do
        {
          site: {
            bind_vars: '$1',
            bind_vals: [nil, 'af'],
            last_val: 1,
            match: :site,
            prev: nil,
            value: 'af'
          },
          sites: {
            bind_vars: '$2, $3',
            bind_vals: [[nil, 'cl'], [nil, 'mx']],
            last_val: 3,
            match: :sites,
            prev: :site,
            value: %w[cl mx]
          }
        }
      end
      let(:index) { 3 }
      let(:value) { '2020-02-01' }

      it { expect(subject.bind_vals).to eq([nil, '2020-02-01']) }
      it { expect(subject.bind_vars).to eq('?') }
      it { expect(subject.last_val).to eq(4) }
      it { expect(subject.prev).to eq(:sites) }
    end

    context '3rd element in `indexed_bindings`' do
      let(:hash) do
        {
          site: {
            bind_vars: '$1',
            bind_vals: [nil, 'af'],
            last_val: 1,
            match: :site,
            prev: nil,
            value: 'af'
          },
          sites: {
            bind_vars: '$2, $3',
            bind_vals: [[nil, 'cl'], [nil, 'mx']],
            last_val: 3,
            match: :sites,
            prev: :site,
            value: %w[cl mx]
          },
          date: {
            bind_vars: '$4',
            bind_vals: [nil, '2020-02-01'],
            last_val: 4,
            match: :date,
            prev: :sites,
            value: '2020-02-01'
          }
        }
      end
      let(:index) { 4 }
      let(:value) { [1, 2, 3] }

      it { expect(subject.bind_vals).to eq([[nil, 1], [nil, 2], [nil, 3]]) }
      it { expect(subject.bind_vars).to eq('?, ?, ?') }
      it { expect(subject.last_val).to eq(7) }
      it { expect(subject.prev).to eq(:date) }
    end
  end
end
