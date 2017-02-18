require "log4r"

require 'vagrant/util/retryable'

require 'vagrant-ucsd/util/timer'

module VagrantPlugins
  module UCSD
    module Action
      # This starts a stopped instance.
      class TerminateInstance
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("ucsd::action::terminate_instance")
        end

        def call(env)
           

              vm_name = env[:machine].provider_config.vm_name

              if !env[:machine_name]
                env[:machine_name] = vm_name
              end

              access_key = env[:machine].provider_config.access_key
              host_ip = env[:machine].provider_config.host_ip
              username = env[:machine].provider_config.username

              begin 
                encoded = URI.encode("https://#{host_ip}/app/api/rest?opName=userAPIFilterTabularReport&opData={param0:\"0\",param1:\"All Clouds\",param2:\"VMS-T0\",param3:\" \",param4:\" \"}"

                );           
                    
                    response = JSON.parse(RestClient::Request.execute(
                      :method => :get,
                      :url => encoded,
                      :headers => {"X-Cloupia-Request-Key" => "#{access_key}"},
                      :verify_ssl => false,
                      :content_type => "json",
                      :accept => "json"
                    ));

                    existingVMs = response["serviceResult"]["rows"]

                    found = false

                    existingVMs.each do |row|
                      if row["VM_Name"] == vm_name
                          found = true
                          env[:vm_id] = row["VM_ID"]
                          if row["Power_State"] == "ON"
                            env[:result] = :running
                          else 
                            env[:result] = :stopped
                          end
                         break
                      end
                    end

              rescue => e
                puts "Error \n"
                puts e
              end 

              if found == true

                
                encoded = URI.encode("https://#{host_ip}/app/api/rest?opName=userAPIExecuteVMAction&opData={param0:\"#{env[:vm_id]}\",param1:\"destroyVM\", param2:\"\"}");            
                    
                    response = JSON.parse(RestClient::Request.execute(
                      :method => :post,
                      :url => encoded,
                      :headers => {"X-Cloupia-Request-Key" => "#{access_key}"},
                      :verify_ssl => false,
                      :content_type => "json",
                      :accept => "json"
                    ));

                if response["serviceError"] == "REMOTE_SERVICE_EXCEPTION: No such resource exists or user does not have access privileges: VM Action destroyVM" 
                  timeout = -1
                  env[:ui].info(I18n.t("ucsd.delete_not_available"))
                else 
                  timeout = 90
                end

                while timeout > 0

                  timeout -= 1
                  
                 begin 
                  encoded = URI.encode("https://#{host_ip}/app/api/rest?opName=userAPIFilterTabularReport&opData={param0:\"0\",param1:\"All Clouds\",param2:\"VMS-T0\",param3:\" \",param4:\" \"}"

                  );           
                      
                      response = JSON.parse(RestClient::Request.execute(
                        :method => :get,
                        :url => encoded,
                        :headers => {"X-Cloupia-Request-Key" => "#{access_key}"},
                        :verify_ssl => false,
                        :content_type => "json",
                        :accept => "json"
                      ));

                      existingVMs = response["serviceResult"]["rows"]

                      found = false

                      existingVMs.each do |row|
                        if row["VM_Name"] == vm_name
                            found = true                   
                           break
                        end
                      end




                rescue => e
                  puts "Error \n"
                  puts e
                end 


                  if found == false
                    env[:state] = nil?
                    env[:ui].info(I18n.t("ucsd.terminated"))
                    break
                  else
                    env[:ui].info(I18n.t("ucsd.terminating"))
                  end
                
                sleep 20
              end
              end

          @app.call(env)
        end
      end
    end
  end
end
