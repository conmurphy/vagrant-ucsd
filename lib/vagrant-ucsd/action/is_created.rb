module VagrantPlugins
  module UCSD
    module Action
      # This can be used with "Call" built-in to check if the machine
      # is created and branch in the middleware.
      class IsCreated
        def initialize(app, env)
          @app = app
        end

        def call(env)


              vm_name = env[:machine].provider_config.vm_name

              if !env[:machine_name]
                env[:machine_name] = vm_name
              end

              access_key = env[:machine].provider_config.access_key
              host_ip = env[:machine].provider_config.host_ip

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
                          env[:machine_public_ip] = row["IP_Address"]
                          env[:machine_ssh_info] = { :host =>  env[:machine_public_ip], :port => 22, :username => "vagrant"}
                          env[:ssh_info]  = { :host =>  env[:machine_public_ip], :port => 22, :username => "vagrant"}
                          env[:result] = :created
                         break
                      end
                    end

              rescue => e
                puts "Error\n"
                puts e
              end 

              if found == false
                env[:result] = :not_created
              end
           

          @app.call(env)
        end
      end
    end
  end
end
