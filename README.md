# Sendmail image

***I am using this image for my own needs. Please review carefully the code before using it in production, I deny any responsibility in any consequences on what can occur if you reuse this code or the resulting image.***

This image runs a local sendmail server, configured to allow sending emails from its local network.
It automatically determines the container's IP and opens the SMTP port on this IP (and listens to the corresponding network). If you want to be able to push mails through this network, you will have to specify the SUBNET variable.

By default, it assumes your subnetwork is firewalled so no spam spoofing can be done.
If you want to secure it more closely, you can specify the allowed addresses allowed in the From header and reject everything else.

***Please note that I did not configure incoming emails, and did not, thus address corresponding security issues.***


Environment variables:
 * HOSTNAME: Hostname to use for container identification
 * SUBNET: defines a SUBNET to listen to (defaults to only 127.0.0.1). If set to e.g. 192.168, it will listen to all machines on the 192.168.0.0/16 subnetwork


## Testing the image
You can use the docker compose file to test the image.

* `docker-compose build`
* `docker-compose up -d`
* `docker ps` then get into the curl container (`docker exec -it [the container id] sh`)
* and in the curl container, using curl, you can send an email:
```bash
  tee -a /tmp/mail.txt  > /dev/null <<EOT
  Subject: Terminal Email Send

  Email Content line 1
  Email Content line 2
  EOT

  curl --url 'smtp://sendmail:25'  \
    --mail-from '[an email address]' --mail-rcpt '[a valid email address]' \
    --upload-file /tmp/mail.txt
```
