# frozen_string_literal: true

require 'spec_helper'
require 'yesql/query/result'
require_relative '../../../../minimalpg/config/environment'

describe ::YeSQL::Query::Result do
  describe '.call' do
    subject do
      described_class.new(
        binds: binds,
        bind_statement: bind_statement,
        file_path: file_path,
        prepare: prepare_option
      )
    end

    let(:file_path) { 'imaginary_path/imaginary_file' }
    let(:prepare_option) { true }
    let(:bind_statement) { 'SELECT id, ? FROM foo WHERE LOWER(site) IN (?, ?);' }
    let(:binds) { %w[foo NO NA] }
    let(:result) { subject.call }

    shared_examples 'pg connection query execution' do |title, rails_version = nil|
      context title, rails_version do
        it do
          expect(::ActiveRecord::Base.connection).to(
            receive(:exec_query).with(
              bind_statement, file_path, binds, prepare: prepare_option
            )
          )
          result
        end
      end
    end

    it_behaves_like 'pg connection query execution', 'with Rails = 5', :rails5
    it_behaves_like 'pg connection query execution', 'with Rails != 5'
  end
end
