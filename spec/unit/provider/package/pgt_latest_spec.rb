#!/usr/bin/env rspec

require 'yaml'
require 'spec_helper'

# TODO: rewrite this whole damn file

provider_class = Puppet::Type.type(:package).provider(:portagegt)

describe provider_class do
	before :each do
		provider_class.stubs(:command).with(:eix).returns('/usr/bin/eix')

		Puppet.expects(:warning).never
	end

	def pkg(args = {})
		defaults = { :provider => 'portagegt' }
		Puppet::Type.type(:package).new(defaults.merge(args))
	end


	describe '#latest' do
		context "when multiple categories avaliable and a package definition is ambiguous" do
			it {
				fh = File.open("spec/unit/provider/package/eix/mysql_loose.xml", "rb")
				mysql_loose = fh.read
				fh.close()

				proc {
					provider_class.stubs(:eix).with("--xml", "--pure-packages", "--exact", "--name", "mysql").returns(mysql_loose)

					provider = provider_class.new(pkg({ :name => "mysql", :ensure => :latest }))
					provider.latest
				}.should raise_error(Puppet::Error, /Multiple categories .* available for package .*/)
			}
		end

		context "when package is specified explicitly" do
			it {
				fh = File.open("spec/unit/provider/package/eix/mysql.xml", "rb")
				mysql = fh.read
				fh.close()

				provider_class.stubs(:eix).with("--xml", "--pure-packages", "--exact", "--category-name", "dev-db/mysql").returns(mysql)

				provider = provider_class.new(pkg({ :name => "dev-db/mysql", :ensure => :latest }))
				provider.latest.should == "5.1.62-r1"
			}
		end
	end #xml parse check
end