$getUrl = Invoke-WebRequest 'https://forum.virpil.com/index.php?/topic/142-worldwide-webstore-restock-date/'
$y = $getUrl | ForEach-Object { [regex]::matches( $_, '(?<=<strong>)(.*?)(?=</strong>)' ) } | Select-Object -ExpandProperty value

$pos = $y[4].IndexOf(":")
$websiteTime = ($y[4].Substring($pos+1)).Trim() #gives us "6pm GMT"
$websiteTimeNoGMT = $websiteTime -replace ".{4}$" #gets rid of "GMT"
$long = ([DateTime]$websiteTimeNoGMT).ToString().Length #total length
if ($long -eq 20) {
    $timeWithAMPM = ([DateTime]$websiteTimeNoGMT).ToString().Substring($long -10) #removes date
    $finalDateTime = $y[3],$timeWithAMPM
    $finalDate = [DateTime]::ParseExact($finalDateTime, 'dd.MM.yyyy h:mm:ss tt', $null)
}
elseif ($long -eq 21) {
    $timeWithAMPM = ([DateTime]$websiteTimeNoGMT).ToString().Substring($long -11) #removes date
    $finalDateTime = $y[3],$timeWithAMPM
    $finalDate = [DateTime]::ParseExact($finalDateTime, 'dd.MM.yyyy hh:mm:ss tt', $null)
}
#$timeOnly = $timeWithAMPM -replace ".{3}$" #removes last 3 chars (so space + AM)

Write-Host $y[1]
if (($finalDate.AddHours(-7)) -lt $now) {
    Write-Host "Local datetime: "$finalDate.AddHours(-7) -ForegroundColor Red
    Write-Host $y[2], $y[3], $y[4] -ForegroundColor Red
}
elseif (($finalDate.AddHours(-7)) -ge $now) {
    Write-Host "Local datetime: "$finalDate.AddHours(-7) -ForegroundColor Green
    Write-Host "Website info: "$y[2], $y[3], $y[4]`n
}



$x = $getUrl | ForEach-Object { [regex]::matches( $_, '(?<=<li>\s+)(.*?)(?=\s+</li>)' ) } | Select-Object -ExpandProperty value
$x | ForEach-Object { 
    if ($_ -like '*VPC*' ) {
        if ($_ -match`
        'VPC MongoosT-50CM2 Throttle' -or`  # throttle, base included
        'VPC Constellation ALPHA-R' -or`    # right handed grip
        'VPC Constellation ALPHA-L' -or`    # left handed grip
        'VPC MongoosT-50CM2 Base' -or`      # base for mounted grip setups
        'VPC WarBRD Base') {                # base for desktop grip setups
            Write-Host $_ -ForegroundColor Green
        }
        else {
            Write-Host $_
        }
}}
