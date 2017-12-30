*****************************************************************************************
Multi platform (FreeBSD, Ubuntu, CentOS) script to install and configure Apache MySQL PHP
*****************************************************************************************

.. image:: https://cdn.rawgit.com/odb/official-bash-logo/master/assets/Logos/Identity/PNG/BASH_logo-transparent-bg-color.png

This script supposes you have installed and configured BASH to all servers. 
SHELL for root user is BASH on all servers and root user can remote login through ssh.
List of IP address you must add to the **iplist** file.

=====
Usage
=====

In a terminal:

.. code-block:: bash
    
    # ./osdetector.sh
    This script will install Apache, PHP and MySQL to all servers which are listed in the file iplist.
    Password for root user must be same for all servers!!!
    But you must write MySQL password at the installation process..
    Please enter password for the MySQL root user:
