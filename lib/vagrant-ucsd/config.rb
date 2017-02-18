require "vagrant"

module VagrantPlugins
  module UCSD
    class Config < Vagrant.plugin("2", :config)
      # The access key ID for accessing Cloudcenter.
      #
      # @return [String]
      attr_accessor :access_key

      # The host ip of UCSD to be provisioned from
      #
      # @return [String]
      attr_accessor :host_ip

      # The Catalog Name for the VM to be provisioned from
      #
      # @return [String]
      attr_accessor :catalog_item
     
     # The vdc Name for the VM to be provisioned to
      #
      # @return [String]
      attr_accessor :vdc

      # The Name for the VM to be provisioned
      #
      # @return [String]
      attr_accessor :vm_name

      # The username for the user
      #
      # @return [String]
      attr_accessor :username

      def initialize(region_specific=false)
        @access_key              = UNSET_VALUE
        @host_ip              = UNSET_VALUE
        @catalog_item              = UNSET_VALUE
        @vdc              = UNSET_VALUE
        @vm_name              = UNSET_VALUE
        @username              = UNSET_VALUE
	  end
    end
  end
end
