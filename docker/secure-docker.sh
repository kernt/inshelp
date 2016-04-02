#!/bin/bash
#
#
#
#
#
#
#####################################################

# docker options 
#        --tls=true|false
#         Use TLS; implied by --tlsverify. Default is false.
#
#       --tlscacert= /.docker/ca.pem
#         Trust certs signed only by this CA.
#
#       --tlscert= /.docker/cert.pem
#         Path to TLS certificate file.
#
#       --tlskey= /.docker/key.pem
#         Path to TLS key file.
#
#       --tlsverify=true|false
#         Use TLS and verify the remote (daemon: verify client, client: verify daemon).
#         Default is false.
#

DOCKERCONFCERTSDIR="/etc/certs.d/"

cd  $DOCKERCONFCERTSDIR

openssl genrsa -aes256 -out ca-key.pem 4096

openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem

openssl genrsa -out server-key.pem 4096

openssl req -subj "/CN=$HOST" -sha256 -new -key server-key.pem -out server.csr

echo subjectAltName = IP:10.10.10.20,IP:127.0.0.1 > extfile.cnf

openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem  -CAcreateserial -out server-cert.pem -extfile extfile.cnf

openssl genrsa -out key.pem 4096

openssl req -subj '/CN=client' -new -key key.pem -out client.csr

echo extendedKeyUsage = clientAuth > extfile.cnf

openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem   -CAcreateserial -out cert.pem -extfile extfile.cnf

rm -v client.csr server.csr

chmod -v 0400 ca-key.pem key.pem server-key.pem

chmod -v 0444 ca.pem server-cert.pem cert.pem

exit 0

