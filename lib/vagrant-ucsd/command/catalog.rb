module VagrantPlugins
  module UCSD
    module Command
      class Catalog < Vagrant.plugin("2", :command)
       def self.synopsis
          "Retrieve available catalog items"
        end

        def execute
          	
          	access_key = ""
            host_ip = ""
            vm_name = ""

			if File.exists?("VagrantFile")
				File.readlines("VagrantFile").grep(/ucsd.access_key/) do |line|
				    unless line.empty?
				      access_key = line.scan(/["']([^"']*)["']/)[0][0]
				    end
				end
				File.readlines("VagrantFile").grep(/ucsd.host_ip/) do |line|
				    unless line.empty?
				      host_ip = line.scan(/["']([^"']*)["']/)[0][0]
				      
				    end
				end
				File.readlines("VagrantFile").grep(/ucsd.vm_name/) do |line|
				    unless line.empty?
				      vm_name = line.scan(/["']([^"']*)["']/)[0][0]
				      
				    end
				end
			end

			if access_key.empty?
				access_key = ENV["access_key"]
			end
			if host_ip.empty?
				host_ip = ENV["host_ip"]
			end

			if access_key.nil?
				puts "Access Key missing. Please enter into VagrantFile or environmental variable 'export access_key= '"
			end
			if host_ip.nil?
				puts "Host IP missing. Please enter into VagrantFile or environmental variable 'export host_ip= '"
			end

			if !(access_key.nil?  or host_ip.nil?)
          		begin

		            encoded = URI.encode("https://#{host_ip}/app/api/rest?opName=userAPIGetAllCatalogs");           
		            
		            catalog = JSON.parse(RestClient::Request.execute(
		   					:method => :get,
		  					:url => encoded,
		  					:headers => {"X-Cloupia-Request-Key" => "#{access_key}"},
		                    :verify_ssl => false,
		                    :content_type => "json",
		                    :accept => "json"
					));


		            catalogs = catalog["serviceResult"]["rows"]
		 
					 # build table with data returned from above function
					
					table = Text::Table.new
					table.head = ["Catalog Item", "Description"]
					puts "\n"
				
					#for each item in returned list, display certain attributes in the table
					catalogs.each do |row|
						item = row["Catalog_Name"]
						description = row["Catalog_Description"]
						
						table.rows << ["#{item}", "#{description}"]
					end
				
					puts table
					
					puts"\n"

					encoded = URI.encode("https://#{host_ip}/app/api/rest?opName=userAPIGetAllVDCs");           
		            
		            vdcs = JSON.parse(RestClient::Request.execute(
		   					:method => :get,
		  					:url => encoded,
		  					:headers => {"X-Cloupia-Request-Key" => "#{access_key}"},
		                    :verify_ssl => false,
		                    :content_type => "json",
		                    :accept => "json"
					));


		            vdc = vdcs["serviceResult"]["rows"]
		 
					 # build table with data returned from above function
		           
					table = Text::Table.new
					table.head = ["VDC", "Description" ,"Locked State"]
					puts "\n"
				
					#for each item in returned list, display certain attributes in the table
					vdc.each do |row|
						vdc_name = row["vDC"]
						description = row["vDC_Description"]
						locked_state = row["Lock_State"]

				
						table.rows << ["#{vdc_name}", "#{description}", "#{locked_state}"]
					end
				
					puts table
					
					puts"\n"

					
                
	          	rescue => e

		            if e.inspect ==  "Timed out connecting to server"
		              puts "\n#ConnectionError - Unable to connnect to UCS Director \n"
		              exit
		            else
		              puts e.inspect
		              exit
		            end
				end	
			end
          
         	0
          
		  
				
        end
      end
    end
  end
end