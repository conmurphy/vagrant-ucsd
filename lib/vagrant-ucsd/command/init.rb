module VagrantPlugins
  module UCSD
    module Command
      class Init < Vagrant.plugin("2", :command)
       def self.synopsis
          "Build initial Vagrantfile"
        end
        
       # This will build the Vagrantfile and insert the attributes required
        

       def createInitFile()

			script = File.open("Vagrantfile", "w")
			
			script.puts "# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

	config.vm.box = 'ucsd'
 
	config.vm.provider :ucsd do |ucsd|
		ucsd.access_key = 'my_access_key'
		ucsd.host_ip = 'ucsd_host_ip_address'
    ucsd.catalog_item = 'ucsd_catalog_item'
    ucsd.vdc = 'ucsd_vdc'
    ucsd.vm_name = 'vm_name'
    ucsd.username = 'username'
	end
  
  	config.vm.synced_folder '.', '/opt/myApp/', type: 'rsync'

end"
			script.close   

		end
        
        def execute
          
			createInitFile()
			
        end
      end
    end
  end
end