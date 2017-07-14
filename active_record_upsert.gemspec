# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record_upsert/version'

Gem::Specification.new do |spec|
  spec.name          = "active_record_upsert"
  spec.version       = ActiveRecordUpsert::VERSION
  spec.authors       = ["Jesper Josefsson", "Olle Jonsson"]
  spec.email         = ["jesper.josefsson@gmail.com", "olle.jonsson@gmail.com"]
  spec.homepage      = "https://github.com/jesjos/active_record_upsert/"

  spec.summary       = %q{Real PostgreSQL 9.5+ upserts using ON CONFLICT for ActiveRecord}

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.platform = Gem::Platform::RUBY

  spec.add_runtime_dependency 'activerecord', '>= 5.0', '< 5.2'
  spec.add_runtime_dependency 'arel', '> 7.0', '< 9.0'
  spec.add_runtime_dependency 'pg', '~> 0.18'
end
