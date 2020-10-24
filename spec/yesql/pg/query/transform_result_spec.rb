# frozen_string_literal: true

require 'spec_helper'
require 'yesql/params/output'
require_relative '../../../minimalpg/config/environment'

describe ::YeSQL::Query::TransformResult do
  xdescribe '.call' do
    subject(:transformed_result) { described_class.new(output: output, result: result).call }

    let(:query) { 'SELECT 1 AS foo, 2' }
    let(:result) { ActiveRecord::Base.connection.exec_query(query) }

    shared_examples 'a result with columns ouput' do
      context 'when output = "columns"' do
        let(:output) { ::YeSQL::Params::Output.new(:columns) }

        it { expect(transformed_result).to eq(%w[foo 2]) }
      end
    end

    shared_examples 'a result with hash ouput' do
      context 'when output = "hash"' do
        let(:output) { ::YeSQL::Params::Output.new(:hash) }

        # rubocop:disable Style/HashSyntax
        it { expect(transformed_result).to eq([{ foo: 1, :'2' => 2 }]) }
        # rubocop:enable Style/HashSyntax
      end
    end

    shared_examples 'a result with rows ouput' do
      context 'when output = "rows"' do
        let(:output) { ::YeSQL::Params::Output.new(:rows) }

        it { expect(transformed_result).to eq([[1, 2]]) }
      end
    end

    context 'with Rails 5', :rails5 do
      it_behaves_like 'a result with columns ouput'
      it_behaves_like 'a result with hash ouput'
      it_behaves_like 'a result with rows ouput'
    end

    context 'with Rails other than 5' do
      it_behaves_like 'a result with columns ouput'
      it_behaves_like 'a result with hash ouput'
      it_behaves_like 'a result with rows ouput'
    end
  end
end
