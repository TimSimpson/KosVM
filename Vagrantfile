Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"  # 14.04
  config.vm.synced_folder ".", "/vagrant"
  config.vm.provider "virtualbox" do |v|
      v.name = "KosVM"
      v.memory = 1024
      v.cpus = 2
    end
end
