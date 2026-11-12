$baseUrl = "http://localhost:8080/smart-hotel-management"
$loginSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$loginGet = Invoke-WebRequest -Uri "$baseUrl/login" -WebSession $loginSession -UseBasicParsing
if ($loginGet.Content -match 'name="csrfToken"\s+value="([^"]+)"') { $csrf = $matches[1] }
$loginBody = @{ csrfToken = $csrf; email = "john.doe@example.com"; password = "customer123" }
$loginResult = Invoke-WebRequest -Uri "$baseUrl/login" -Method POST -Body $loginBody -WebSession $loginSession -UseBasicParsing

$bookForm = Invoke-WebRequest -Uri "$baseUrl/customer/book?roomId=1" -WebSession $loginSession -UseBasicParsing
if ($bookForm.Content -match 'name="csrfToken"\s+value="([^"]+)"') { $bookCsrf = $matches[1] }

$bookBody = @{
    csrfToken = $bookCsrf
    roomId = "1"
    checkIn = (Get-Date).AddDays(30).ToString("yyyy-MM-dd")
    checkOut = (Get-Date).AddDays(33).ToString("yyyy-MM-dd")
    guests = "2"
    guestName = "Johnathan Doe"
    guestEmail = "john.doe@example.com"
    guestPhone = "+91 91234 56789"
    specialRequests = "Quiet room please."
    paymentOption = "DEMO"
}
$bookResult = Invoke-WebRequest -Uri "$baseUrl/customer/book" -Method POST -Body $bookBody -WebSession $loginSession -UseBasicParsing
Write-Host "Target URL: $($bookResult.BaseResponse.ResponseUri)"
$alerts = $bookResult.Content -split "`n" | Select-String "alert-danger" -Context 0,2 | Out-String
Write-Host "Alerts: $alerts"

