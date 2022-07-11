Start-Transcript -Path D:\streamlicense\log\all_$(get-date -format 'yyyyMMdd HHmmss').txt

$admin="ncsoftadmin@ncsoftcorp.onmicrosoft.com"
$pw=ConvertTo-SecureString -String "EjrqhRdl8()" -AsPlainText -Force
$tenant="ncsoftcorp.onmicrosoft.com"
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $admin, $PW
Connect-AzureAD -Credential $Credential -TenantID $tenant
Connect-MsolService -Credential $Credential

$filepath="D:\\streamlicense\employee.csv"

$gdate=(get-date).ToString("yyyy-MM-dd HH:mm:ss")

$getuser=Import-Csv $filepath
$notmodifyusers=@()

ForEach($user in $getuser){
$userid=$user.emailaddress

$userid
$userobject=get-msoluser -UserPrincipalName $userid
$plans = @{}
$enterprisepack=(get-msoluser -UserPrincipalName $userid).licenses|where-object{$_.accountskuid -eq 'ncsoftcorp:ENTERPRISEPREMIUM'}
$enterprisepack.servicestatus | %{$plans.add($_.serviceplan.servicename, $_.provisioningstatus)}

$plans
$plans.set_item("STREAM_O365_E3","Success")

$disabledPlans=@()
$plans.keys | % {if($plans.get_item($_) -eq "Disabled"){$disabledplans +=$_}}
$disabledPlans
    if ($disabledPlans) {
        $licenseOptions = new-msolLicenseOptions -AccountSkuId "ncsoftcorp:ENTERPRISEPACK" -DisabledPlans $disabledPlans -verbose
        Set-MsolUserLicense -UserPrincipalName $userid -LicenseOptions $licenseOptions
    } 
    else{$notmodifyusers+=$userid}

}
"not modify users"
$notmodifyusers

##https://digitalglue.wordpress.com/2017/03/06/enabling-or-disabling-specific-services-within-your-office365-license-using-powershell/


Stop-Transcript
