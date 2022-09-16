$global:LinuxOffers = New-Object System.Collections.ArrayList

foreach($line in Get-Content "$($PSScriptRoot)\RawLinuxOffers.txt") { # TODO join safer for unix and windows?
    $offerDetails = $line.Split(":");

    $global:LinuxOffers.Add([Tuple]::Create($offerDetails[0], $offerDetails[1]))
}

$global:LinuxOffers = $global:LinuxOffers | Sort-Object -unique