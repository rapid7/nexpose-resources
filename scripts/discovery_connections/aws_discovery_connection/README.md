# aws_discovery_connection_creator.rb
This script creates an AWS Asset Sync type discovery connection. It was written for customers setting up many discovery connections, or tearing them down and recreating them frequently. This script was adapted from the internal cucumber testing framework, but stripped of those dependencies other than the nexpose-client ruby gem.
## Usage
		bundle install
		export NEXPOSE_PW=redacted NEXPOSE_AWS_ACCESS_KEY_ID=redacted NEXPOSE_AWS_SECRET_ACCESS_KEY=redacted && bundle exec ruby ./aws_discovery_connection_creator.rb
For security's sake, nexpose password and aws keys are kept in env vars rather than a plaintext config file. If you have multiple connections to set up, it may be desireable to keep them in aws_configuration.yml or use some other kind of scheme.
## aws_configuration.yml
This config file contains two example configurations for an AWS discovery connection. More could be added, but these basically illustrate how to handle multiple regions and/or roles as well as the boolean fields.