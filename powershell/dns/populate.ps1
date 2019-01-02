# Script populating the local DNS Server with diverse entries
# Powershell must be started as Administrator

$zoneName="test.chris.local"
$DNSServer="127.0.0.1"

Function addDNSa($RecordName,$RecordData,$RecordTTL)
{
    $newTTL = [System.TimeSpan]::FromMinutes($RecordTTL)
    try{
        Add-DnsServerResourceRecord -A -Name $RecordName -IPv4Address "$($RecordData)" -ZoneName $zoneName -AllowUpdateAny  -TimeToLive $newTTL
    }catch{
        $e = $_.Exception
        Write-warning $e.Message
        $error[0]|format-list -force
    }
}
Function addDNSaaaa($RecordName,$RecordData,$RecordTTL)
{
    $newTTL = [System.TimeSpan]::FromMinutes($RecordTTL)
    try{
        Add-DnsServerResourceRecord -AAAA -Name $RecordName -IPv6Address "$($RecordData)" -ZoneName $zoneName -AllowUpdateAny  -TimeToLive $newTTL
    }catch{
        $e = $_.Exception
        Write-warning $e.Message
        $error[0]|format-list -force
    }
}
Function addDNScname($RecordName,$RecordData,$RecordTTL)
{
    $newTTL = [System.TimeSpan]::FromMinutes($RecordTTL)
    try{
        Add-DnsServerResourceRecord -CName -Name $RecordName -HostNameAlias "$($RecordData)" -ZoneName $zoneName -AllowUpdateAny  -TimeToLive $newTTL
    }catch{
        $e = $_.Exception
        Write-warning $e.Message
        $error[0]|format-list -force
    }
}
Function addDNStxt($RecordName,$RecordData,$RecordTTL)
{
    $newTTL = [System.TimeSpan]::FromMinutes($RecordTTL)
    try{
        Add-DnsServerResourceRecord -Txt -Name $RecordName -DescriptiveText "$($RecordData)" -ZoneName $zoneName -AllowUpdateAny  -TimeToLive $newTTL
    }catch{
        $e = $_.Exception
        Write-warning $e.Message
        $error[0]|format-list -force
    }
}

addDNSa `
    -RecordName "test2" `
    -RecordData "192.168.1.2" `
    -RecordTTL 10
addDNSa `
    -RecordName "test3" `
    -RecordData "192.168.1.3" `
    -RecordTTL 10
addDNSa `
    -RecordName "test4" `
    -RecordData "192.168.1.4" `
    -RecordTTL 10
addDNScname `
    -RecordName "cname" `
    -RecordData "www.google.com." `
    -RecordTTL 10
addDNScname `
    -RecordName "cname2" `
    -RecordData "www.google.com." `
    -RecordTTL 10
addDNStxt `
    -RecordName "text" `
    -RecordData "DNS BLABLA BLA" `
    -RecordTTL 100
addDNSa `
    -RecordName "test7" `
    -RecordData "192.168.7.1" `
    -RecordTTL 10
addDNSa `
    -RecordName "test7" `
    -RecordData "192.168.7.2" `
    -RecordTTL 10
addDNSa `
    -RecordName "test7" `
    -RecordData "192.168.7.3" `
    -RecordTTL 10
addDNSa `
    -RecordName "test7" `
    -RecordData "192.168.7.4" `
    -RecordTTL 10
addDNSa `
    -RecordName "crashtest3" `
    -RecordData "192.168.0.3" `
    -RecordTTL 10
addDNSaaaa `
    -RecordName "crashtest3" `
    -RecordData "2001:0db8::3" `
    -RecordTTL 10


Write-Host -BackgroundColor DarkCyan "############################################"
Write-Host -BackgroundColor DarkCyan "#                TEST 1                    #"
Write-Host -BackgroundColor DarkCyan "############################################"

$RecordType="A"
$RecordName="text"
$RecordTTL="11"
$RecordData="172.16.0.1"

. test2.ps1

Write-Host -BackgroundColor DarkCyan "############################################"
Write-Host -BackgroundColor DarkCyan "#                TEST 2                    #"
Write-Host -BackgroundColor DarkCyan "############################################"

$RecordType="A"
$RecordName="test2"
$RecordTTL="12"
$RecordData="172.16.0.2"

. test2.ps1

Write-Host -BackgroundColor DarkCyan "############################################"
Write-Host -BackgroundColor DarkCyan "#                TEST 3                    #"
Write-Host -BackgroundColor DarkCyan "############################################"

$RecordType="CNAME"
$RecordName="test3"
$RecordTTL="13"
$RecordData="www.alias.net."

. test2.ps1

Write-Host -BackgroundColor DarkCyan "############################################"
Write-Host -BackgroundColor DarkCyan "#                TEST 4                    #"
Write-Host -BackgroundColor DarkCyan "############################################"

$RecordType="CNAME"
$RecordName="test4"
$RecordTTL="14"
$RecordData="www.alias.net."

. test2.ps1

Write-Host -BackgroundColor DarkCyan "############################################"
Write-Host -BackgroundColor DarkCyan "#                TEST 5                    #"
Write-Host -BackgroundColor DarkCyan "############################################"

$RecordType="A"
$RecordName="cname"
$RecordTTL="15"
$RecordData="10.10.10.10"

. test2.ps1

Write-Host -BackgroundColor DarkCyan "############################################"
Write-Host -BackgroundColor DarkCyan "#                TEST 6                    #"
Write-Host -BackgroundColor DarkCyan "############################################"

$RecordType="A"
$RecordName="test6"
$RecordTTL="15"
$RecordData="10.0.0.1,10.0.0.2,10.0.0.3"

. test2.ps1

Write-Host -BackgroundColor DarkCyan "############################################"
Write-Host -BackgroundColor DarkCyan "#                TEST 7                    #"
Write-Host -BackgroundColor DarkCyan "############################################"

$RecordType="A"
$RecordName="test7"
$RecordTTL="17"
$RecordData="10.1.7.11,10.1.7.12"

. test2.ps1

Write-Host -BackgroundColor DarkCyan "############################################"
Write-Host -BackgroundColor DarkCyan "#                TEST 8                    #"
Write-Host -BackgroundColor DarkCyan "############################################"

$RecordType="CNAME"
$RecordName="cname2"
$RecordTTL="18"
$RecordData="www.alias.net."

. test2.ps1

Write-Host -BackgroundColor DarkCyan "############################################"
Write-Host -BackgroundColor DarkCyan "#               CRASH TEST 1               #"
Write-Host -BackgroundColor DarkCyan "############################################"

$RecordType="CNAME"
$RecordName="test4"
$RecordTTL="21"
$RecordData="www.alias.net.,www2.alias.net"

. test2.ps1

Write-Host -BackgroundColor DarkCyan "############################################"
Write-Host -BackgroundColor DarkCyan "#               CRASH TEST 2               #"
Write-Host -BackgroundColor DarkCyan "############################################"

$RecordType="A"
$RecordName="cname"
$RecordTTL="22"
$RecordData="330.10.10.10"

. test2.ps1

Write-Host -BackgroundColor DarkCyan "############################################"
Write-Host -BackgroundColor DarkCyan "#               CRASH TEST 3               #"
Write-Host -BackgroundColor DarkCyan "############################################"

$RecordType="A"
$RecordName="crashtest3"
$RecordTTL="23"
$RecordData="10.10.10.10"

. test2.ps1
