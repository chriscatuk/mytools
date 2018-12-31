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
addDNSa `
    -RecordName "test1" `
    -RecordData "192.168.1.1" `
    -RecordTTL 10
addDNSa `
    -RecordName "test2" `
    -RecordData "192.168.1.1" `
    -RecordTTL 10
addDNSaaaa `
    -RecordName "test2" `
    -RecordData "2001:0db8:::1" `
    -RecordTTL 20
addDNScname `
    -RecordName "cname" `
    -RecordData "www.google.com." `
    -RecordTTL 10

