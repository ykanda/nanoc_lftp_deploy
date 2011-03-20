# encoding: utf-8

module Nanoc3::Extra::Deployers
  # A deployer that deploys a site using lftp.
  class Lftp
    # Default options
    DEFAULT_OPTIONS = [
      #	'--exclude=".hg"',
      #	'--exclude=".svn"',
      #	'--exclude=".git"'
    ]

    # Creates a new deployer that uses rsync. The deployment configurations
    # will be read from the configuration file of the site (which is assumed
    # to be the current working directory).
    def initialize
      # Get site
      error 'No site configuration found' unless File.file?('config.yaml')
      @site = Nanoc3::Site.new('.')
    end

    # Runs the task. Possible params:
    #
    # @option params [Boolean] :dry_run (false) True if the action itself
    # should not be executed, but still printed; false otherwise.
    #
    # @option params [String] :config_name (:default) The name of the
    # deployment configuration to use.
    #
    # @return [void]
    def run(params={})
      # Extract params
      config_name = params.has_key?(:config_name) ? params[:config_name].to_sym : :default
      dry_run     = params.has_key?(:dry_run)     ? params[:dry_run]            : false

      # Validate config
      error 'No deploy configuration found'                    if @site.config[:deploy_lftp].nil?
      error "No deploy configuration found for #{config_name}" if @site.config[:deploy_lftp][config_name].nil?

      # Set arguments
    # src = File.expand_path(@site.config[:output_dir]) + '/'
      src     = @site.config[:output_dir]
      dst     = @site.config[:deploy_lftp][config_name][:dst].split(':')[1]
      user    = @site.config[:deploy_lftp][config_name][:user]
      pass    = @site.config[:deploy_lftp][config_name][:pass]
      site    = @site.config[:deploy_lftp][config_name][:dst].split(':')[0]
      options = @site.config[:deploy_lftp][config_name][:options] || DEFAULT_OPTIONS

      # Validate arguments
    # error 'No dst found in deployment configuration' if dst.nil?
    # error 'dst requires no trailing slash' if dst[-1,1] == '/'
      if dst != nil
        if dst[-1,1] == '/'
          error 'dst requires no trailing slash' if dst[-1,1] == '/'
        end
      else
        dst = ""
      end


      # Run
      if dry_run
         warn 'Performing a dry-run; no actions will actually be performed'
         run_shell_cmd(
			sprintf(
               "echo lftp -c \'open -u %s,%s -e \"mirror --delete --only-newer --verbose -R ./%s /%s\" %s\'",
               user, pass, src, dst, site
		    )
		 )
      else
      #  run_shell_cmd([ 'lftp', options, src, dst ].flatten)
         run_shell_cmd(
			sprintf(
               "lftp -c \'open -u %s,%s -e \"mirror --delete --only-newer --verbose -R ./%s /%s\" %s\'",
			   user, pass, src, dst, site
		    )
		 )
      end
    end

  private

    # Prints the given message on stderr and exits.
    def error(msg)
      raise RuntimeError.new(msg)
    end

    # Runs the given shell command. This is a simple wrapper around Kernel#system.
    def run_shell_cmd(args)
      system(*args)
      raise "command exited with a nonzero status code #{$?.exitstatus} (command: #{args.join(' ')})" if !$?.success?
    end
  end
end
