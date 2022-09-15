$LinuxOffers = New-Object System.Collections.ArrayList

foreach($line in Get-Content "src\PSRule.Rules.Azure\rules\RawLinuxOffers.txt") {
    $offerDetails = $line.Split(":");

    $LinuxOffers.Add([Tuple]::Create($offerDetails[0], $offerDetails[1]))
}

$LinuxOffers = $LinuxOffers | Sort-Object -unique