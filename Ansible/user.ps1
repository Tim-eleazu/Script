$username = "\LocalAdmin" 
$password = ConvertTo-SecureString '234325' -AsPlainText -Force
$credential = [System.management.automation.pscredential]::new($username, $password)
$script = {Get-Date}
Invoke-Command -ComputerName 10.1.0.6 -Credential $credential -ScriptBlock $script