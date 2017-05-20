# Configuration

For example `ovs_kvm_config.sh` you can change `ethX` to the new style like this `enpXsX` `X` stands for a number.
With `ip addr show` you can see wich interface you currently have.
If you use a networking bridge you should have two interfaces without a ip but there should be a interface with a neme like this
`brX` or `boundX`.

Change it to your needs in the `ovs-config.sh` file.
