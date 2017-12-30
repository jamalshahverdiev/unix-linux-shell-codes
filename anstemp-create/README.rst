**********************************************************
Write or Delete IPFW and DHCP commands and restart service
**********************************************************

.. image:: https://cdn.rawgit.com/odb/official-bash-logo/master/assets/Logos/Identity/PNG/BASH_logo-transparent-bg-color.png

This folder contain the following components:

* **dhcp_reservate_and_add_rule.sh** - Takes two arguments. Last octet of user IP and username. It configure DHCP reservation and IPFW for this user.
* **delete_dhcp_and_ipfw.sh** - Takes username as argument. Then delete DHCP reservation and IPFW rules from CLI/configuration.
* **count** - Counter file to increase IPFW rule number for each new user.
* **dhcpd.conf** - DHCP configuration template file to test **dhcp_reservate_and_add_rule.sh** and **delete_dhcp_and_ipfw.sh** scripts.
* **ipfw.conf** - IPFW configuration template file to test **dhcp_reservate_and_add_rule.sh** and **delete_dhcp_and_ipfw.sh** scripts.


=====
Usage
=====

Install bash. If you want to change SHABANG path as in Linux then, copy the shell executable from /usr/local/bin/bash to /bin/bash.

In a terminal:

.. code-block:: bash
    
    # pkg install -y bash vim


Add IPFW rules and reservate DHCP for user "UsernameSurname". Last octet of reservation IP will be "145"

.. code-block:: bash

    # ./delete_dhcp_and_ipfw.sh 145 UsernameSurname 
    

Delete IPFW rules and DHCP reservation for user "UsernameSurname".

.. code-block:: bash

    # ./delete_dhcp_and_ipfw.sh UsernameSurname 
