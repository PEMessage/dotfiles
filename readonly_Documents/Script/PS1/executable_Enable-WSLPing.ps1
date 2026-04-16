# See:
# https://github.com/microsoft/WSL/issues/4171#issuecomment-1336131977
# https://superuser.com/questions/1449775/windows-wsl-2-cant-ping-host-machine


# Source - https://superuser.com/a/1752574
# Posted by pabouk - Ukraine stay strong
# Retrieved 2026-01-28, License - CC BY-SA 4.0
#
# Get-NetFirewallRule -All | Where-Object {$_.Name -match 'vm-monitoring'} to see name we want

Enable-NetFirewallRule -Name 'vm-monitoring-icmpv4'
Enable-NetFirewallRule -Name 'vm-monitoring-icmpv6'

