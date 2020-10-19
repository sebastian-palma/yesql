# frozen_string_literal: true

require 'spec_helper'
require 'yesql/bindings/extractor'

describe ::YeSQL::Bindings::Extractor do
  describe '.call' do
    let(:bindings) do
      { site: 'af', sites: %w[cl mx], date: '2020-02-01', ids: [1, 2, 3] }
    end

    subject { described_class.new(bindings: bindings) }

    it 'replaces the binding values for positional indexes starting by one, arrays are unnested' do
      expect(subject.call).to eq(
        site: {
          value: 'af',
          match: :site,
          prev: nil,
          last_val: 1,
          bind: {
            vals: [nil, 'af'],
            vars: '?'
          }
        },
        sites: {
          value: %w[cl mx],
          match: :sites,
          prev: :site,
          last_val: 3,
          bind: {
            vals: [[nil, 'cl'], [nil, 'mx']],
            vars: '?, ?'
          }
        },
        date: {
          value: '2020-02-01',
          match: :date,
          prev: :sites,
          last_val: 4,
          bind: {
            vals: [nil, '2020-02-01'],
            vars: '?'
          }
        },
        ids: {
          value: [1, 2, 3],
          match: :ids,
          prev: :date,
          last_val: 7,
          bind: {
            vals: [[nil, 1], [nil, 2], [nil, 3]],
            vars: '?, ?, ?'
          }
        }
      )
    end
  end
end
