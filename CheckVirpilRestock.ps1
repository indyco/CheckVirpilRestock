$timesToRun = 0
while ($timesToRun -eq 0) {
    $getUrl = Invoke-WebRequest 'https://forum.virpil.com/index.php?/topic/142-worldwide-webstore-restock-date/'
    $restockInfo = $getUrl | ForEach-Object { [regex]::matches( $_, '(?<=<strong>)(.*?)(?=</strong>)' ) } | Select-Object -ExpandProperty value
    $date = $getUrl | ForEach-Object { [regex]::matches( $_, '(?<=<b>)(.*?)(?=</b>)' ) } | Select-Object -ExpandProperty value
    $equipment = $getUrl | ForEach-Object { [regex]::matches( $_, '(?<=<li>\s+)(.*?)(?=\s+</li>)' ) } | Select-Object -ExpandProperty value

    Clear-Host
    ((Get-Date).ToString() -split '\s',2)[1]
    Write-Host $restockInfo[1]

    try {
        # get rid of beginning of element
        $websiteTime = (($restockInfo[3].Substring(($restockInfo[3].IndexOf("~"))+1)).Trim())
        # get AM or PM out of element, join with time (begginning of $websiteTime string), convert to datetime, split into two strings
        $timeWithAMPM = (([DateTime]((($websiteTime.Split("?",2))[0]) + (($websiteTime.Split(">",2))[1]).SubString(0,2)))).ToString() -split '\s',2
        # join date with time (second element in $timeWithAMPM array because of -split), remove number letters like '1st' or '3rd'
        $combinedDateTime = ($date + ' ' + $timeWithAMPM[1]) -replace '[rdst]'

        
        $restockDate = [DateTime]$combinedDateTime

        # if ($timeWithAMPM[1].length -eq 10) {
        #     $restockDate = [DateTime]::ParseExact($combinedDateTime, 'dd.MM.yyyy h:mm:ss tt', $null)
        # }
        # elseif ($timeWithAMPM[1].length -eq 11) {
        #     $restockDate = [DateTime]::ParseExact($combinedDateTime, 'dd.MM.yyyy hh:mm:ss tt', $null)
        # }

        $color = "Red"
        if (($restockDate.AddHours(-7)) -gt (Get-Date)) { # if $restockDate is in the future, write in green
            $color = "Green"
        }

        Write-Host "Local datetime: "$restockDate.AddHours(-7) -ForegroundColor $color
    }
    catch {
        $restockDate = $false
        Write-Host "Local datetime: Unavailable" -ForegroundColor Yellow
    }
    
    Write-Host "Website info: "$date, ($restockInfo[3]).Split("?",2)[0]`n

    $equipment | ForEach-Object { 
        if ($_ -like '*VPC*' ) {
            if ($_ -match 'VPC MongoosT-50CM2 Throttle' -or`  # throttle, base included
                $_ -match 'VPC Constellation ALPHA-R' -or`    # right handed grip
                $_ -match 'VPC Constellation ALPHA-L' -or`    # left handed grip
                $_ -match 'VPC MongoosT-50CM2 Base' -or`      # base for mounted grip setups
                $_ -match 'VPC WarBRD Base') {                # base for desktop grip setups
                Write-Host $_ -ForegroundColor Green
            }
            else {
                Write-Host $_
            }
        }
        elseif ($_ -like '*TBA*') {
            Write-Host "`t`tProducts TBA" -ForegroundColor Yellow
        }
    }

    #time to wait
    Start-Sleep -Seconds 1200
}