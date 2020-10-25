# frozen_string_literal: true

require 'spec_helper'
require 'yesql/bindings/transformed'
require_relative '../../../minimalpg/config/environment'

describe ::YeSQL::Bindings::Transformed do
  describe '.call' do
    subject { described_class.new(statement_binds: statement_binds) }

    let(:transformed_bindings) { subject.call }

    shared_examples 'pg transformed binds' do
      describe 'pg adapter', :pg_adapter do
        let(:statement_binds) do
          [
            [[nil, 666], '$1'],
            [[nil, nil], '$2'],
            [[[nil, 1], [nil, 2]], '$3, $4'],
            [[nil, 5], '$5'],
            [[nil, 5], '$5']
          ]
        end

        it do
          expect(transformed_bindings).to eq([[nil, 666], [nil, nil], [nil, 1], [nil, 2], [nil, 5]])
        end
      end
    end

    shared_examples 'mysql transformed binds' do |eq|
      describe 'mysql adapter', :mysql_adapter do
        let(:statement_binds) do
          [
            [[nil, 666], '?'],
            [[nil, nil], '?'],
            [[[nil, 1], [nil, 2]], '?, ?'],
            [[nil, 5], '?'],
            [[nil, 5], '?']
          ]
        end

        it { expect(transformed_bindings).to eq(eq) }
      end
    end

    describe 'Rails 5', :rails5 do
      it_behaves_like 'mysql transformed binds', [666, nil, 1, 2, 5, 5]
      it_behaves_like 'pg transformed binds'
    end

    describe 'Rails != 5' do
      it_behaves_like 'mysql transformed binds', [[nil, 666], [nil, nil], [nil, 1], [nil, 2],
                                                  [nil, 5], [nil, 5]]
      it_behaves_like 'pg transformed binds'
    end
  end
end
