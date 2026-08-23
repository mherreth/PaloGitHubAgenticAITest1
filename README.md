PaloAltoNetworks Terraform Template which uses the panos provider to deploy policies on the VM-Series FW
-------------------------------------------------------------------------------------------------------

This repository contains Terraform templates to deploy policies onto the VM-Series Firewalls using the PaloAltoNetworks
Terraform provider. 

This template does the following:

   - Configures the network interfaces
   - Assigns interfaces to virtual routers 
   - Creates zones and attaches interfaces to the specified zones
   - Creates a service object 
   - Creates various NAT rules 
   - Creates various Security rules

GitHub Actions runner setup:
----------------------------

The workflows in `.github/workflows/` are configured for a Windows self-hosted runner with the labels `self-hosted`, `windows`, and `x64`.

Before running the workflows, add these repository secrets:

- `PANOS_HOSTNAME`
- `PANOS_USERNAME`
- `PANOS_PASSWORD`

To register the runner on a Windows host:

1. In the repository, open **Settings > Actions > Runners > New self-hosted runner**.
2. Choose **Windows** and **x64**.
3. Use the generated registration command from GitHub and provide the token at setup time. Do not store the registration token in this repository or in workflow files.
4. Start the runner with `run.cmd`, or install it as a service if the host should stay online for unattended workflow runs.

Support:
--------

These templates are released under an as-is, best effort, support policy. These scripts should be seen as community supported and Palo Alto Networks will contribute our expertise as and when possible. We do not provide technical support or help in using or troubleshooting the components of the project through our normal support options such as Palo Alto Networks support teams, or ASC (Authorized Support Centers) partners and backline support options. The underlying product used (the VM-Series firewall) by the scripts or templates are still supported, but the support is only for the product functionality and not for help in deploying or using the template or script itself. Unless explicitly tagged, all projects or work posted in our GitHub repository (at https://github.com/PaloAltoNetworks) or sites other than our official Downloads page on https://support.paloaltonetworks.com are provided under the best effort policy.
