
require "log4r"
require 'rest-client';
require 'json';
require 'base64'

require 'vagrant/util/retryable'

require 'vagrant-ucsd/util/timer'


module VagrantPlugins
  module UCSD
    module Action
     
      class Deploy
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("ucsd::action::connect")
        end

        def call(env)
          
          # Get the rest API key for authentication
          access_key = env[:machine].provider_config.access_key
          host_ip = env[:machine].provider_config.host_ip
          catalog_item = env[:machine].provider_config.catalog_item
          vdc = env[:machine].provider_config.vdc
          vm_name = env[:machine].provider_config.vm_name
          username = env[:machine].provider_config.username
          
          timeout = 90

          #@logger.info("Deploying VM to UCSD...")

          begin


            encoded = URI.encode("https://#{host_ip}/app/api/rest?formatType=json&opName=userAPIProvisionRequest&opData=\{param0:\{\"catalogName\":\"#{catalog_item}\",\"vdcName\":\"#{vdc}\",\"vmName\":\"#{vm_name}\",\"userID\":\"#{username}\"\}\}");           
            
            response = JSON.parse(RestClient::Request.execute(
   									:method => :post,
  									:url => encoded,
                    :headers => {"X-Cloupia-Request-Key" => "#{access_key}"},
                    :verify_ssl => false,
                    :content_type => "json",
                    :accept => "json"
									));

            requestID = response["serviceResult"]
            
          rescue => e

              puts "Error\n\n"

              if e.inspect ==  "Timed out connecting to server"
                puts "\n#ConnectionError - Unable to connnect to UCS Director \n"
                exit
              else
                puts e.inspect
                exit
              end
      
          end

                # Wait for SSH to be ready.
                env[:ui].info(I18n.t("ucsd.waiting_for_ready"))
               
                while timeout > 0

                  timeout -= 1
                  
                  # When an  instance comes up, it's networking may not be ready
                  # by the time we connect.
                  begin

                      encoded = URI.encode("https://#{host_ip}/app/api/rest?formatType=json&opName=userAPIGetServiceRequestDetails&opData=\{param0:\"#{requestID}\"\}");           
                      
                      response = JSON.parse(RestClient::Request.execute(
                        :method => :get,
                        :url => encoded,
                        :headers => {"X-Cloupia-Request-Key" => "#{access_key}"},
                        :verify_ssl => false,
                        :content_type => "json",
                        :accept => "json"
                      ));
                      
                      status = response["serviceResult"]["status"]

                      if status == "Complete" then 
                        env[:machine_state_id]= :created

                        encoded = URI.encode("https://#{host_ip}/app/api/rest?formatType=json&opName=userAPIGetVMsForServiceRequest&opData=\{param0:\"#{requestID}\"\}");           
                      
                        response = JSON.parse(RestClient::Request.execute(
                          :method => :get,
                          :url => encoded,
                          :headers => {"X-Cloupia-Request-Key" => "#{access_key}"},
                          :verify_ssl => false,
                          :content_type => "json",
                          :accept => "json"
                        ));

                        env[:machine_public_ip] = response["serviceResult"]["vms"][0]["ipAddress"]
                        break
                      elsif status == "Submitted" || status == "In Progress"
                        env[:ui].info(I18n.t("ucsd.waiting_for_ssh"))
                      end
                  
                  rescue => e
                    puts "Error\n\n"
                    puts e
                  end

                  sleep 20
                end
             
           
        
            # Ready and booted!
            env[:ui].info(I18n.t("ucsd.ready"))
         

          @app.call(env)
        end
      end
    end
  end
end
