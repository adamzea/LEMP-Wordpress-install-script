# LEMP-Wordpress-install-script
A script to install NGINX, MariaDB, PHP, and Wordpress on a Debian virtual machine or server.

After starting a new virtual machine or Debian Linux machine, copy this script to the server as "LEMPscript".
Point a domain name to the IP address of the server using your DNS records.

```bash
$ git clone https://github.com/adamzea/LEMP-Wordpress-install-script.git
$ cd /LEMP-WOrdpress-install-script/
```

Make the file executable with:
```bash
$ chmod u+x LEMPscript
```

Run the script with:
```bash
$ ./LEMPscript
```

The script will request the domain name as well as database names/passwords to set up everything. At the end, it will run Certbot to activate SSL via LetsEncrypt so that part will need the domain name to be pointing at the server properly. 
