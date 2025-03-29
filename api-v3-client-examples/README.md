# api-v3-client-example

## Overview
The examples provided outline how to auto generate libraries for the Nexpose/InsightVM RESTful api using Swagger 
Codegen.  The setup_workspace.rb script is meant to quickly get started generating the files and sample scripts
leveraging the generated library have been place in the samples/ directory.

## Use
Below are the very basic steps for getting started.  Feel free to experiment and see what best fits your needs:
1. Ensure Java is installed and on path; required for Swagger Codegen library
2. Update setup_workspace.rb with the appropriate Nexpose/InsightVM console URL
3. Run setup_workspace.rb
4. Update samples/settings.yml with console connection details (URL, Username, Password)
5. Profit!
 