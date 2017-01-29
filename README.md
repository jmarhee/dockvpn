# OpenVPN for Docker

Quick instructions:

```
docker-compose up -d
```

Once provisioned, navigate to `http://<Your IP>:10889` to access a single-use download of your OpenVPN config. It will only be available for a single download, requiring that OpenVPN be re-deployed (and thus, re-keyed and new certs generated).

## Using this setup with DigitalOcean
### or any provider supporting provisioning scripts

To use this configuration with a provider such as <a href="https://digitalocean.com">DigitalOcean</a>, use `provision.sh` in your user-data field when you <a href="https://www.digitalocean.com/community/tutorials/an-introduction-to-droplet-metadata">create a new droplet.</a>

## How does it work?

When the `dockvpn` image is started, it generates:

- Diffie-Hellman parameters,
- a private key,
- a self-certificate matching the private key,
- two OpenVPN server configurations (for UDP and TCP),
- an OpenVPN client profile.

Then, it starts two OpenVPN server processes (one on 1194/udp, another
on 443/tcp).

The configuration is located in `/etc/openvpn`, and the Dockerfile
declares that directory as a volume. It means that you can start another
container with the `--volumes-from` flag, and access the configuration.
Conveniently, the modified `dockvpn` image comes with a script called `serveconfig`,
which starts a pseudo HTTPS server on `8080/tcp`. The pseudo server
does not even check the HTTP request; it just sends the HTTP status line,
headers, and body right away.

Because this interface is only exposed to the Docker network, and is configured (by design) to terminate
after serving a single request (ensuring that you are aware if, either, someone has already accessed and downloaded your config, and that you can act if your config is unavailable), it is only accessible to the `vpn-config-ui` container, which will serve 
a single copy of your config to you at `http://<Server IP Address>:10889`. All subsequent requests will fail to download, as
`serveconfig` will have been terminated. 


## OpenVPN details

We use `tun` mode, because it works on the widest range of devices.
`tap` mode, for instance, does not work on Android, except if the device
is rooted.

The topology used is `net30`, because it works on the widest range of OS.
`p2p`, for instance, does not work on Windows.

The TCP server uses `192.168.255.0/25` and the UDP server uses
`192.168.255.128/25`.

The client profile specifies `redirect-gateway def1`, meaning that after
establishing the VPN connection, all traffic will go through the VPN.
This might cause problems if you use local DNS recursors which are not
directly reachable, since you will try to reach them through the VPN
and they might not answer to you. If that happens, use public DNS
resolvers like those of Google (8.8.4.4 and 8.8.8.8) or OpenDNS
(208.67.222.222 and 208.67.220.220).


## Security discussion

For simplicity, the client and the server use the same private key and
certificate. This is certainly a terrible idea. If someone can get their
hands on the configuration on one of your clients, they will be able to
connect to your VPN, and you will have to generate new keys. Which is,
by the way, extremely easy, since each time you `docker-compose` the OpenVPN
compose file, a new key is created. If someone steals your configuration file
(and key), they will also be able to impersonate the VPN server (if they
can also somehow hijack your connection).

It would probably be a good idea to generate two sets of keys.

It would probably be even better to generate the server key when
running the container for the first time (as it is done now), but
generate a new client key each time the `serveconfig` command is
called. The command could even take the client CN as argument, and
another `revoke` command could be used to revoke previously issued
keys.


## Verified to work with ...

People have successfully used this VPN server with clients such as:

- OpenVPN on Linux, (*Note*: `sudo openvpn client.ovpn` will run this configuration)
- Viscosity on OSX (#25),
- Tunnelblick on OSX,
- (some VPN client on Android but I can't remember which).


## Other related/interesting projects

- @besn0847/[alpinevpn](https://github.com/besn0847/alpinevpn), a smaller
  image based on the Alpine distribution
  
