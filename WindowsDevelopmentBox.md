# How to set up your windows development box

1. Download and install vagrant for your operating system.

    https://www.vagrantup.com/downloads.html

1. Download and install virtualbox for your operating system.

    https://www.virtualbox.org/

1. Download and install a windows box.

    for instance:

    https://vagrantcloud.com/opentable/boxes/win-2012r2-standard-amd64-nocm

        vagrant init opentable/win-2012r2-standard-amd64-nocm
        vagrant up --provider virtualbox
        vagrant halt

    configure your Vagrantfile accordingly. For instance:

    `````ruby
        Vagrant.configure(2) do |config|
            #...
            config.vm.box = "opentable/win-2012r2-standard-amd64-nocm"
            config.vm.box_check_update = false
            config.vm.network "public_network"

            #...
            config.vm.provider "virtualbox" do |vb|
                vb.gui = true
                vb.memory = "8192"
                vb.customize ["modifyvm", :id, "--vram", "256"]
            end
            #...
        end
    `````

        vagrant up --provider virtualbox

    1. Install the latest virtual guest additions.

    1. Install chocolatey

    [https://chocolatey.org](https://chocolatey.org)

    from powershell

        iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

    1. restart powershell and test chocolatey

        choco
        Chocolatey v0.9.9.11

    1. Install Git
    
        choco install git

    Since this installer adds to the SYSTEM PATH only the GITDIR/cmd it
    is not possible to execute bash without specifying the full path.

    Please add to your SYSTEM PATH the following paths

          GITDIR
          GITDIR/bin
          GITDIR/migw64/bin

    Where GITDIR is the directory where chocolatey installed Git. for instance:

          C:/Program Files/Git

    1. Install Visual Studio 2015 Community

          choco install visualstudio2015community
