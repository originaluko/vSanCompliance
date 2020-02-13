Function Get-vSanCompliance { 
    <#
            .SYNOPSIS
            Report on DRS Group and vSAN Policy compliancy.

            .DESCRIPTION
            Report on DRS Group and vSAN Policy compliancy.

            Validate Compliancy via defined rules within a JSON configuration file.

            .EXAMPLE
            Get-vSanCompliance -json "rules.json"
            Retuns all VMs and validate their compliancy against rules.json configuration file.

            .INPUTS
            JSON configuration file.

            .NOTES
            Author:  Mark Ukotic
            Website: http://blog.ukotic.net
            Twitter: @originaluko
            GitHub:  https://github.com/originaluko/

            .LINK
            https://github.com/originaluko/vSanCompliance

    #>
    
    [CmdletBinding()]
    [OutputType([object])]
    Param (

        [Parameter(Mandatory)]
        [System.IO.FileInfo]$json

    )

    Begin {
        $jsonConfig = Get-Content -Raw -Path $json | ConvertFrom-Json
    }

    Process {

        $policy = get-vm | Get-SpbmEntityConfiguration
        
        $Results = foreach ($vm in $policy) {
        
            $drsGroup = Get-DrsClusterGroup -vm $vm.Name

            $compliant = foreach ($rule in $jsonConfig.Rules) { 
                if ($drsGroup -match $rule.DRS -and $vm.storagepolicy.name -match $rule.vSAN) { 
                    Write-output "Compliant"
                    break
                }
                elseif ($NULL -eq $drsGroup -and $NULL -eq $vm.storagepolicy.name) { 
                    Write-output "Undefined (No Rules)"
                    break
                }
                elseif ($NULL -eq $drsGroup) { 
                    Write-output "Non-Compliant (Missing DRS Rule)"
                    break
                }
                elseif ($NULL -eq $vm.storagepolicy.name) {
                    Write-output "Non-Compliant (Missing vSAN Policy)"
                    break
                }
            
            }
        
            if ($NULL -eq $compliant) {
                $compliant = "Non-Compliant (Unknown Rule)"
            }

            [PSCustomObject]@{
                'VM Name'            = $vm.Name
                'DRS Group'          = $drsGroup
                'vSAN Policy'        = $vm.storagepolicy
                'vSAN Compliant'     = $vm.ComplianceStatus
                'Overall Compliancy' = $compliant
            }
        }
        Write-Output $Results    
    }
}