*********************
Full Automated Nagios
*********************

.. image:: https://img.shields.io/pypi/pyversions/Django.svg

Python script to install/configure Nagios server and Nrpe agents to all client servers.

Program components are the following:

* clients.txt - List of IP addresses for all Nagios clients.
* nagios-clients.py - Automatic installation of Nagios Server.
* nagios-server.py - Automatic installation of Nagios Clients.
* run.py - Installation lunch script with an interactive menu.



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
