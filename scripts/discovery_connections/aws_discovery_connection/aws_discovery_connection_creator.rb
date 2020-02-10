require 'nexpose'
require 'yaml'
require 'eso'

# aws_discovery_connection_creator.rb creates a new AWS Asset Sync discovery connection
# USAGE: 
#    bundle install
#    export NEXPOSE_PW=redacted NEXPOSE_AWS_ACCESS_KEY_ID=redacted NEXPOSE_AWS_SECRET_ACCESS_KEY=redacted && bundle exec ruby ./aws_discovery_connection_creator.rb

# Set up Nexpose and AWS credentials
nexpose_host = 'localhost'
nexpose_username = 'nxadmin'
nexpose_password = ENV['NEXPOSE_PW']
# For security's sake, I kept the following two in env vars rather than a plaintext file. If you have a bunch of
# connections to set up, you may want to keep them in aws_configuration.yml or use some other kind of scheme.
access_key_id = ENV['NEXPOSE_AWS_ACCESS_KEY_ID']
secret_access_key = ENV['NEXPOSE_AWS_SECRET_ACCESS_KEY']

# Create connection to nexpose console
@nsc = Nexpose::Connection.new(nexpose_host, nexpose_username, nexpose_password)

# Login to Nexpose
@nsc.login

# Logout of Nexpose when script Exits
at_exit { @nsc.logout }

# Create a site for assets to live in
site = Nexpose::Site.new("unique_site_name")
site_id = site.save(@nsc)

# Load the discovery connection configuration from a file, name it, and stuff in credentials. There are example `AWS`
# and `AWS with console in AWS and multiple ARNs` in aws_configuration.yml. You could stuff more in there if desired.
template_type = ['AWS', 'AWS with console in AWS and multiple ARNs'][0]
dc_configuration = YAML.load_file('aws_configuration.yml')[template_type]
dc_configuration['configName'] = "AWSAssetSync-UniqueDisplayName"
dc_configuration['configurationAttributes']['properties']['accessKeyID'] = {'valueClass' => 'String', 'value'=> access_key_id}
dc_configuration['configurationAttributes']['properties']['secretAccessKey'] = {'valueClass' => 'String', 'value' => secret_access_key}

# POST the request for a discovery connection configuration
@configuration_manager = Eso::ConfigurationManager.new(@nsc)
#@configuration_manager.service_configurations(service_name: "amazon-web-services").each { |cfg| @configuration_manager.delete(cfg["configID"]) }
request_body = JSON.generate(dc_configuration)
# If the following fails, make sure that the config is valid (enter it into the UI and `Test Connection`) and that
# it's not a duplicate of a preexisting config.
config_id = @configuration_manager.post_service_configuration(request_body)

# POST a sync_aws_assets_with_tags integration option.
# Integration options are used to use the configuration bits of a discovery connection to perform
# some type of action -- in this case, syncing the assets from the discovery connection (via config_id) to a site
# (via site_id). Integration options must be created and then started.
integration_option_manager = Eso::IntegrationOptionsManager.new(@nsc)
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
