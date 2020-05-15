$getUrl = Invoke-WebRequest 'https://forum.virpil.com/index.php?/topic/142-worldwide-webstore-restock-date/'
$restockInfo = $getUrl | ForEach-Object { [regex]::matches( $_, '(?<=<strong>)(.*?)(?=</strong>)' ) } | Select-Object -ExpandProperty value
$equipment = $getUrl | ForEach-Object { [regex]::matches( $_, '(?<=<li>\s+)(.*?)(?=\s+</li>)' ) } | Select-Object -ExpandProperty value

# get rid of "Time: and GMT"
$websiteTime = (($restockInfo[4].Substring(($restockInfo[4].IndexOf(":"))+1)).Trim()) -replace ".{4}$"
# split by space (\s), return only two strings (,2)
$timeWithAMPM = (([DateTime]$websiteTime).ToString() -split '\s',2)
# join date with time (second element in $timeWithAMPM array because of -split)
$combinedDateTime = $restockInfo[3],$timeWithAMPM[1]

if ($timeWithAMPM[1].length -eq 10) {
    $restockDate = [DateTime]::ParseExact($combinedDateTime, 'dd.MM.yyyy h:mm:ss tt', $null)
}
elseif ($timeWithAMPM[1].length -eq 11) {
    $restockDate = [DateTime]::ParseExact($combinedDateTime, 'dd.MM.yyyy hh:mm:ss tt', $null)
}

$color = "Red"
if (($restockDate.AddHours(-7)) -gt (Get-Date)) { # if $restockDate is in the future, write in green
    $color = "Green"
}

Write-Host $restockInfo[1]
Write-Host "Local datetime: "$restockDate.AddHours(-7) -ForegroundColor $color
Write-Host "Website info: "$restockInfo[2], $restockInfo[3], $restockInfo[4]`n

$equipment | ForEach-Object { 
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
