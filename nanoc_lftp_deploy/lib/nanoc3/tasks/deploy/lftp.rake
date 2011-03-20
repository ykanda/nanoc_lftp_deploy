# -*- encoding: utf-8 -*-

namespace :deploy do
  desc 'Upload the compiled site using lftp'
  task :lftp do
    dry_run     = !!ENV['dry_run']
    config_name = ENV['config'] || :default

    deployer = Nanoc3::Extra::Deployers::Lftp.new
    deployer.run(
		:config_name => config_name,
		:dry_run => dry_run
	)
  end
end
