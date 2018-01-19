Configuration WindowsWebServer {

param(
        [Parameter(Mandatory=$true)]
        [string] $patToken,
	
	[Parameter(Mandatory=$true)]
        [string] $projectName,
	
        [Parameter(Mandatory=$true)]
        [string] $vstsUrl
	
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, xWebAdministration

    Node localhost {

        WindowsFeature WebServerRole
        {
		    Name = "Web-Server"
		    Ensure = "Present"
        }

        WindowsFeature WebManagementConsole
        {
            Name = "Web-Mgmt-Console"
            Ensure = "Present"
        }

        WindowsFeature WebManagementService
        {
            Name = "Web-Mgmt-Service"
            Ensure = "Present"
        }

        WindowsFeature ASPNet45
        {
		    Ensure = "Present"
		    Name = "Web-Asp-Net45"
        }

        WindowsFeature HTTPRedirection
        {
            Name = "Web-Http-Redirect"
            Ensure = "Present"
        }

        WindowsFeature CustomLogging
        {
            Name = "Web-Custom-Logging"
            Ensure = "Present"
        }

        WindowsFeature LogginTools
        {
            Name = "Web-Log-Libraries"
            Ensure = "Present"
        }

        WindowsFeature RequestMonitor
        {
            Name = "Web-Request-Monitor"
            Ensure = "Present"
        }

        WindowsFeature Tracing
        {
            Name = "Web-Http-Tracing"
            Ensure = "Present"
        }

        WindowsFeature BasicAuthentication
        {
            Name = "Web-Basic-Auth"
            Ensure = "Present"
        }

        WindowsFeature WindowsAuthentication
        {
            Name = "Web-Windows-Auth"
            Ensure = "Present"
        }

        WindowsFeature ApplicationInitialization
        {
            Name = "Web-AppInit"
            Ensure = "Present"
        }

        WindowsFeature IISManagement  
        {  
            Ensure          = 'Present'
            Name            = 'Web-Mgmt-Console'
            DependsOn       = '[WindowsFeature]WebServerRole'
        } 
  
        xWebsite DefaultSite   
        {  
            Ensure          = 'Present'
            Name            = 'Default Web Site'
            PhysicalPath    = 'C:\inetpub\wwwroot' 
            DependsOn       = '[WindowsFeature]WebServerRole'
        }

	    Script DownloadWebDeploy
        {
            TestScript = {
                Test-Path "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
            }
            SetScript ={
                $source = "http://download.microsoft.com/download/0/1/D/01DC28EA-638C-4A22-A57B-4CEF97755C6C/WebDeploy_amd64_en-US.msi"
                $dest = "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
                Invoke-WebRequest $source -OutFile $dest
            }
            GetScript = { @{Result = "WebDeployDownload"} }
		    DependsOn = "[WindowsFeature]WebServerRole"
        }

	    Package InstallWebDeploy
        {
            Ensure = "Present"  
            Path  = "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
            Name = "Microsoft Web Deploy 3.6"
            ProductId = "{6773A61D-755B-4F74-95CC-97920E45E696}"
		    Arguments = "/quiet ADDLOCAL=ALL"
		    DependsOn = "[Script]DownloadWebDeploy"
        }

        Service StartWebDeploy
        {
		    Name = "WMSVC"
		    StartupType = "Automatic"
		    State = "Running"
		    DependsOn = "[Package]InstallWebDeploy"
        }

      }
}
