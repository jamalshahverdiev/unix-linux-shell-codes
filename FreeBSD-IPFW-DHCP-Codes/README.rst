**********************************************************
Write or Delete IPFW and DHCP commands and restart service
**********************************************************

.. image:: https://cdn.rawgit.com/odb/official-bash-logo/master/assets/Logos/Identity/PNG/BASH_logo-transparent-bg-color.png

This folder contain the following components:

* dhcp_reservate_and_add_rule.sh - List of IP addresses for all Nagios clients.
* delete_dhcp_and_ipfw.sh - Takes username as argument then delete DHCP reservation and IPFW rules from CLI and from configuration.
* count - Counter file to increase IPFW rule number for each new user.
* dhcpd.conf - DHCP configuration template file to test dhcp_reservate_and_add_rule.sh and delete_dhcp_and_ipfw.sh scripts.
* ipfw.conf - IPFW configuration template file to test dhcp_reservate_and_add_rule.sh and delete_dhcp_and_ipfw.sh scripts.



=====
Usage
=====

The purpose of this article is to show how to automatically install the Nagios server and the NRPE clients using the prearranged python scripts. First of all, you must activate root access on all hosts (server and clients).

After you have activated the root access and performed the system update on all machines, you must perform one additional step on FreeBSD. Install bash and copy the shell executable from /usr/local/bin/bash to /bin/bash.


In a terminal:

.. code-block:: bash
    
    # pkg install -y bash vim
    # cp /usr/local/bin/bash /bin/bash 
    # chsh -s /usr/local/bin/bash root ; reboot


Now we can prepare a Linux desktop, install the git package on it and copy all necessary scripts from the repository.

.. code-block:: bash

    # git clone https://github.com/jamalshahverdiev/full-automated-nagios.git 
    
Execute the python-installer.sh to automatically install python2.7, python3.4, and all necessary libraries.

.. code-block:: bash

    # cd full-automated-nagios
    # ./python-installer.sh


Please, execute the following  to start the installation:

.. code-block:: bash

    # ./run.py
    The Program is going to install and configure the Nagios server automatically.
    It is supposed that you have already added all IP addresses of client hosts to the 'clients.txt' file.
    Users must be 'root' with the same passwords on all hosts ...

    =====================================================================================

    Choose one of following options:
    1. To install and configure Nagios server, type 1 and press 'Enter'.
    2. To install and configure 'Nrpe' agents on all client hosts, type 2 and press 'Enter'.
    3. To exit type 3 and press 'Enter'.

    Please choose the installation option: 1
