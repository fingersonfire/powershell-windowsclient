Function Get-SubNetItems
{
<# 
	.SYNOPSIS 
		Scan subnet machines
		
	.DESCRIPTION 
		Use Get-SubNetItems to receive list of machines in specific IP range. (Source : https://gallery.technet.microsoft.com/scriptcenter/SubNet-Scan-dad0311f)

	.PARAMETER StartScanIP 
		Specify start of IP range.

	.PARAMETER EndScanIP
		Specify end of IP range.
	
	.PARAMETER MaxJobs
		Specify number of threads to scan.
		
	.PARAMETER ShowAll
		Show even adress is inactive.
	
	.PARAMETER ShowInstantly 
		Show active status of scaned IP address instanly. 
	
	.PARAMETER SleepTime  
		Wait time to check if threads are completed.
 
	.PARAMETER TimeOut 
		Time out when script will be break.

	.EXAMPLE 
		PS C:\>$Result = Get-SubNetItems -StartScanIP 10.10.10.1 -EndScanIP 10.10.10.10 -ShowInstantly -ShowAll
		10.10.10.7 is active.
		10.10.10.10 is active.
		10.10.10.9 is active.
		10.10.10.1 is inactive.
		10.10.10.6 is active.
		10.10.10.4 is active.
		10.10.10.3 is inactive.
		10.10.10.2 is active.
		10.10.10.5 is active.
		10.10.10.8 is inactive.

		PS C:\> $Result | Format-Table IP, Active, WMI, WinRM, Host, OS_Name -AutoSize

		IP           Active   WMI WinRM Host              OS_Name
		--           ------   --- ----- ----              -------
		10.10.10.1    False False False
		10.10.10.2     True  True  True pc02.mydomain.com Microsoft Windows Server 2008 R2 Enterprise
		10.10.10.3    False False False
		10.10.10.4     True  True  True pc05.mydomain.com Microsoft Windows Server 2008 R2 Enterprise
		10.10.10.5     True  True  True pc06.mydomain.com Microsoft Windows Server 2008 R2 Enterprise
		10.10.10.6     True  True  True pc07.mydomain.com Microsoft(R) Windows(R) Server 2003, Standard Edition
		10.10.10.7     True False False
		10.10.10.8    False False False
		10.10.10.9     True  True False pc09.mydomain.com Microsoft Windows Server 2008 R2 Enterprise
		10.10.10.10    True  True False pc10.mydomain.com Microsoft Windows XP Professional

	.EXAMPLE 
		PS C:\Users\mg> Get-SubNetItems -StartScanIP 10.10.10.2 -Verbose
		VERBOSE: Creating own list class.
		VERBOSE: Start scaning...
		VERBOSE: Starting job (1/20) for 10.10.10.2.
		VERBOSE: Trying get part of data.
		VERBOSE: Trying get last part of data.
		VERBOSE: All jobs is not completed (1/20), please wait... (0)
		VERBOSE: Trying get last part of data.
		VERBOSE: All jobs is not completed (1/20), please wait... (5)
		VERBOSE: Trying get last part of data.
		VERBOSE: All jobs is not completed (1/20), please wait... (10)
		VERBOSE: Trying get last part of data.
		VERBOSE: Geting job 10.10.10.2 result.
		VERBOSE: Removing job 10.10.10.2.
		VERBOSE: Scan finished.


		RunspaceId : d2882105-df8c-4c0a-b92c-0d078bcde752
		Active     : True
		Host       : pc02.mydomain.com
		IP         : 10.10.10.2
		OS_Name    : Microsoft Windows Server 2008 R2 Enterprise
		OS_Ver     : 6.1.7601 Service Pack 1
		WMI        : True
		WinRM      : True

	.NOTES 
		Author: Michal Gajda 
#>

	[CmdletBinding(
		SupportsShouldProcess=$True,
		ConfirmImpact="Low" 
	)]	
	param(
		[parameter(Mandatory=$true)]
		[System.Net.IPAddress]$StartScanIP,
		[System.Net.IPAddress]$EndScanIP,
		[Int]$MaxJobs = 20,
		[Switch]$ShowAll,
		[Switch]$ShowInstantly,
		[Int]$SleepTime = 5,
		[Int]$TimeOut = 60
	)

	Begin{}

	Process
	{
		if ($pscmdlet.ShouldProcess("$StartScanIP $EndScanIP" ,"Scan IP range for active machines"))
		{
			if(Get-Job -name *.*.*.*)
			{
				Write-Verbose "Removing old jobs."
				Get-Job -name *.*.*.* | Remove-Job -Force
			}
			
			$ScanIPRange = @()
			if($EndScanIP -ne $null)
			{
				Write-Verbose "Generating IP range list."
				# Many thanks to Dr. Tobias Weltner, MVP PowerShell and Grant Ward for IP range generator
				$StartIP = $StartScanIP -split '\.'
	  			[Array]::Reverse($StartIP)  
	  			$StartIP = ([System.Net.IPAddress]($StartIP -join '.')).Address 
				
				$EndIP = $EndScanIP -split '\.'
	  			[Array]::Reverse($EndIP)  
	  			$EndIP = ([System.Net.IPAddress]($EndIP -join '.')).Address 
				
				For ($x=$StartIP; $x -le $EndIP; $x++) {    
					$IP = [System.Net.IPAddress]$x -split '\.'
					[Array]::Reverse($IP)   
					$ScanIPRange += $IP -join '.' 
				}
			
			}
			else
			{
				$ScanIPRange = $StartScanIP
			}

			Write-Verbose "Creating own list class."
			$class = @"
			public class SubNetItem {
				public bool Active;
				public string Host;
				public System.Net.IPAddress IP;
				public string OS_Name;
				public string OS_Ver;
				public bool WMI;
				public bool WinRM;
			}
"@		

			Write-Verbose "Start scaning..."	
			$ScanResult = @()
			$ScanCount = 0
			Write-Progress -Activity "Scan IP Range $StartScanIP $EndScanIP" -Status "Scaning:" -Percentcomplete (0)
			Foreach($IP in $ScanIPRange)
			{
	 			Write-Verbose "Starting job ($((Get-Job -name *.*.*.* | Measure-Object).Count+1)/$MaxJobs) for $IP."
				Start-Job -Name $IP -ArgumentList $IP,$class -ScriptBlock{ 
				
					param
					(
					[System.Net.IPAddress]$IP = $IP,
					$class = $class 
					)
					
					Add-Type -TypeDefinition $class
					
					if(Test-Connection -ComputerName $IP -Quiet)
					{
						Try
						{
							$HostName = [System.Net.Dns]::GetHostbyAddress($IP).HostName
						}
						Catch
						{
							$HostName = $null
						}
						
						Try
						{
							#I don't use Get-WMIObject because it havent TimeOut options. 
							$WMIObj = [WMISearcher]''  
							$WMIObj.options.timeout = '0:0:10' 
							$WMIObj.scope.path = "\\$IP\root\cimv2"  
							$WMIObj.query = "SELECT * FROM Win32_OperatingSystem"  
							$Result = $WMIObj.get()  

							if($Result -ne $null)
							{
								$OS_Name = $Result | Select-Object -ExpandProperty Caption
								$OS_Ver = $Result | Select-Object -ExpandProperty Version
								$OS_CSDVer = $Result | Select-Object -ExpandProperty CSDVersion
								$OS_Ver += " $OS_CSDVer"
								$WMIAccess = $true					
							}
							else
							{
								$WMIAccess = $false	
							}
						}	
						catch
						{
							$WMIAccess = $false					
						}
						
						if($HostName)
						{
							$Result = Invoke-Command -ComputerName $HostName -ScriptBlock {systeminfo} -ErrorAction SilentlyContinue 
						}
						else
						{
							$Result = Invoke-Command -ComputerName $IP -ScriptBlock {systeminfo} -ErrorAction SilentlyContinue 
						}
						
						if($Result -ne $null)
						{
							if($OS_Name -eq $null)
							{
								$OS_Name = ($Result[2..3] -split ":\s+")[1]
								$OS_Ver = ($Result[2..3] -split ":\s+")[3]
							}	
							$WinRMAccess = $true
						}
						else
						{
							$WinRMAccess = $false
						}
						
						$HostObj = New-Object SubNetItem -Property @{            
		        					Active		= $true
									Host        = $HostName
									IP          = $IP               
		        					OS_Name     = $OS_Name
									OS_Ver      = $OS_Ver               
		        					WMI         = $WMIAccess      
		        					WinRM       = $WinRMAccess      
		        		}
						$HostObj
					}
					else
					{
						$HostObj = New-Object SubNetItem -Property @{            
		        					Active		= $false
									Host        = $null
									IP          = $IP               
		        					OS_Name     = $null
									OS_Ver      = $null               
		        					WMI         = $null      
		        					WinRM       = $null      
		        		}
						$HostObj
					}
				} | Out-Null
				$ScanCount++
				Write-Progress -Activity "Scan IP Range $StartScanIP $EndScanIP" -Status "Scaning:" -Percentcomplete ([int](($ScanCount+$ScanResult.Count)/(($ScanIPRange | Measure-Object).Count) * 50))
				
				do
				{
					Write-Verbose "Trying get part of data."
					Get-Job -State Completed | Foreach {
						Write-Verbose "Geting job $($_.Name) result."
						$JobResult = Receive-Job -Id ($_.Id)

						if($ShowAll)
						{
							if($ShowInstantly)
							{
								if($JobResult.Active -eq $true)
								{
									Write-Host "$($JobResult.IP) is active." -ForegroundColor Green
								}
								else
								{
									Write-Host "$($JobResult.IP) is inactive." -ForegroundColor Red
								}
							}
							
							$ScanResult += $JobResult	
						}
						else
						{
							if($JobResult.Active -eq $true)
							{
								if($ShowInstantly)
								{
									Write-Host "$($JobResult.IP) is active." -ForegroundColor Green
								}
								$ScanResult += $JobResult
							}
						}
						Write-Verbose "Removing job $($_.Name)."
						Remove-Job -Id ($_.Id)
						Write-Progress -Activity "Scan IP Range $StartScanIP $EndScanIP" -Status "Scaning:" -Percentcomplete ([int](($ScanCount+$ScanResult.Count)/(($ScanIPRange | Measure-Object).Count) * 50))
					}
					
					if((Get-Job -name *.*.*.*).Count -eq $MaxJobs)
					{
						Write-Verbose "Jobs is not completed ($((Get-Job -name *.*.*.* | Measure-Object).Count)/$MaxJobs), please wait..."
						Sleep $SleepTime
					}
				}
				while((Get-Job -name *.*.*.*).Count -eq $MaxJobs)
			}
			
			$timeOutCounter = 0
			do
			{
				Write-Verbose "Trying get last part of data."
				Get-Job -State Completed | Foreach {
					Write-Verbose "Geting job $($_.Name) result."
					$JobResult = Receive-Job -Id ($_.Id)

					if($ShowAll)
					{
						if($ShowInstantly)
						{
							if($JobResult.Active -eq $true)
							{
								Write-Host "$($JobResult.IP) is active." -ForegroundColor Green
							}
							else
							{
								Write-Host "$($JobResult.IP) is inactive." -ForegroundColor Red
							}
						}
						
						$ScanResult += $JobResult	
					}
					else
					{
						if($JobResult.Active -eq $true)
						{
							if($ShowInstantly)
							{
								Write-Host "$($JobResult.IP) is active." -ForegroundColor Green
							}
							$ScanResult += $JobResult
						}
					}
					Write-Verbose "Removing job $($_.Name)."
					Remove-Job -Id ($_.Id)
					Write-Progress -Activity "Scan IP Range $StartScanIP $EndScanIP" -Status "Scaning:" -Percentcomplete ([int](($ScanCount+$ScanResult.Count)/(($ScanIPRange | Measure-Object).Count) * 50))
				}
				
				if(Get-Job -name *.*.*.*)
				{
					Write-Verbose "All jobs is not completed ($((Get-Job -name *.*.*.* | Measure-Object).Count)/$MaxJobs), please wait... ($timeOutCounter)"
					Sleep $SleepTime
					$timeOutCounter += $SleepTime				

					if($timeOutCounter -ge $TimeOut)
					{
						Write-Verbose "Time out... $TimeOut. Can't finish some jobs  ($((Get-Job -name *.*.*.* | Measure-Object).Count)/$MaxJobs) try remove it manualy."
						Break
					}
				}
			}
			while(Get-Job -name *.*.*.*)
			
			Write-Verbose "Scan finished."
			Return $ScanResult | Sort-Object {"{0:d3}.{1:d3}.{2:d3}.{3:d3}" -f @([int[]]([string]$_.IP).split('.'))}
		}
	}
	
	End{}
}
