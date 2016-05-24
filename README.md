# icinga

This cookbook installs Icinga 2 and Icinga Web 2 on an Ubuntu 14.04 LTS server.

<b>Installation Instructions</b>

1. Upload this cookbook to your Chef Server.
2. Create a data bag called "icinga".
3. Create a data bag item called "servers", make it look like this:

{
  "id": "servers",
  "hosts": {
    "Server1": "1.2.3.4",
    "Server2": "5.6.7.8"
  }
}

This will add the servers listed to the monitoring service and monitor via ping.

4. Create a data bag item called "users", make it look like this:

{
  "id": "users",
  "users": {
    "Joe": "JoeSmith@email.com"
  }
}

5. Bootstrap an Ubuntu 14.04 LTS server with this cookbook in its run list.

This will send emails to the email addresses listed if servers listed in step 3 go down or come up.
