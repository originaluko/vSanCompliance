# vSanCompliance
This is an early working version to check vSAN Compliance against a set of rules
 
Copy and updated the rules.json file in the module directory with your rules to check

## Usage

Connect-VIServer vcenter.domain.local
Import-Module vSanCompliance
Get-vSanCompliance -json rules.json | ft -autosize

(Make sure you PowerShell windows's width is wide enought to accommodate the results)