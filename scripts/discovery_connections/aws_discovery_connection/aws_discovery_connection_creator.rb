require 'nexpose'
require 'yaml'
require 'eso'

# aws_discovery_connection_creator.rb creates a new AWS Asset Sync discovery connection
# USAGE:
#    bundle install
#    export NEXPOSE_PW=redacted NEXPOSE_AWS_ACCESS_KEY_ID=redacted NEXPOSE_AWS_SECRET_ACCESS_KEY=redacted && bundle exec ruby ./aws_discovery_connection_creator.rb

# Set up Nexpose and AWS credentials
nexpose_host = 'localhost'
nexpose_username = 'admin'
nexpose_port = 3780
# For security's sake, pull the password from an environment variable rather than a config file.
nexpose_password = ENV['NEXPOSE_PW']

# Create connection to nexpose console
@nsc = Nexpose::Connection.new(nexpose_host, nexpose_username, nexpose_password, nexpose_port)

# Login to Nexpose
@nsc.login

# Logout of Nexpose when script Exits
at_exit { @nsc.logout }

# Create the configuration_manager which will post new configurations
configuration_manager = Eso::ConfigurationManager.new(@nsc)
# Create the integration_option_manager which will post new integration options linked to a configuration
integration_option_manager = Eso::IntegrationOptionsManager.new(@nsc)

# Load the discovery connection configurations from a file.
dc_configurations = YAML.load_file('aws_configuration.yml')
dc_configurations.each { |dc_label, dc_configuration|
  puts "Processing #{dc_label}..."

  # Create a site for assets to live in
  site = Nexpose::Site.new("#{dc_configuration['configName']} Site")
  site_id = site.save(@nsc)

  # If NEXPOSE_AWS_ACCESS_KEY_ID and NEXPOSE_AWS_SECRET_ACCESS_KEY are set in env vars, use them in the config.
  if ENV['NEXPOSE_AWS_ACCESS_KEY_ID']
    dc_configuration['configurationAttributes']['properties']['accessKeyID'] = {'valueClass' => 'String', 'value'=> access_key_id}
  end
  if ENV['NEXPOSE_AWS_SECRET_ACCESS_KEY']
    dc_configuration['configurationAttributes']['properties']['secretAccessKey'] = {'valueClass' => 'String', 'value' => secret_access_key}
  end

  # POST the request for a discovery connection configuration.
  # If the following fails, make sure that the config is valid (enter it into the UI and `Test Connection`) and that
  # it's not a duplicate of a preexisting config.
  request_body = JSON.generate(dc_configuration)
  config_id = configuration_manager.post_service_configuration(request_body)

  # POST a sync_aws_assets_with_tags integration option.
  # Integration options are used to use the configuration bits of a discovery connection to perform
  # some type of action -- in this case, syncing the assets from the discovery connection (via config_id) to a site
  # (via site_id). Integration options must be created and then started.
  sync_integration_option = Eso::IntegrationOptionsManager.build_sync_aws_assets_with_tags_option(
                                                             name: "sync-#{config_id}",
                                                             # Integration options link a DC config -> site
                                                             discovery_conn_id: config_id)
  sync_integration_option.site_id = site_id
  sync_integration_option.id = integration_option_manager.create(sync_integration_option.to_json)
  integration_option_manager.start(sync_integration_option.id)

  # POST a verify_aws_targets integration option. This integration option is needed to do pre-scan verification
  # of AWS assets. Pre-scan verification is the process of checking that an AWS ip actually (still) belongs to
  # the customer so the customer doesn't scan other companies' assets.
  verify_integration_option = Eso::IntegrationOptionsManager.build_verify_aws_targets_option(
      name: "verify-#{config_id}",
      discovery_conn_id: config_id)
  verify_integration_option.site_id = site_id
  verify_integration_option.id = integration_option_manager.create(verify_integration_option.to_json)
  integration_option_manager.start(verify_integration_option.id)
}