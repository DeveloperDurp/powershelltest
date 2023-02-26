#region Configurable Variables

    <#
        .NOTES
        Use this section to configure testing variables. IE if the number of tabs change in the GUI update that variable here.
        All variables need to be global to be passed between contexts

    #>

    $global:FormName = "Chris Titus Tech's Windows Utility"

#endregion Configurable Variables

#region Load Variables needed for testing

    #Config Files
    $global:configs = @{}

    (
        "applications",
        "preset"
    ) | ForEach-Object {
        $global:configs["$PSItem"] = Get-Content .\config\$PSItem.json | ConvertFrom-Json
    }

    #GUI
    $global:inputXML = get-content "./xaml/inputXML.xaml"
    $global:inputXML = $global:inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
    [xml]$global:XAML = $global:inputXML
    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
    $global:reader = (New-Object System.Xml.XmlNodeReader $global:xaml) 
    $global:Form  = [Windows.Markup.XamlReader]::Load( $global:reader )
    $global:xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name "Global:WPF$($_.Name)" -Value $global:Form.FindName($_.Name) -Scope global }

    #dotsource original script to pull in all variables and ensure no errors
    #$script = Get-Content .\winutil.ps1
    #$output = $script[0..($script.count - 14)] | Out-File .\pester.ps1    


#endregion Load Variables needed for testing 

#===========================================================================
# Tests - Application Installs
#===========================================================================

Describe "Application Installs" {
    Context "Application installs" {
        It "Imports with no errors" {
            $global:configs.Applications | should -Not -BeNullOrEmpty
        }
    }
}

#===========================================================================
# Tests - Tweak Presets
#===========================================================================

Describe "Tweak Presets" {
    Context "Json Import" {
        It "Imports with no errors" {
            $global:configs.preset | should -Not -BeNullOrEmpty
        }
    }
}

#===========================================================================
# Tests - GUI
#===========================================================================

Describe "GUI" {
    Context "XML" {
        It "Imports with no errors" {
            $global:XAML | should -Not -BeNullOrEmpty
        }
        It "Title should be $global:FormName" {
            $global:XAML.window.Title | should -Be $global:FormName
        }
    }

    Context "Form" {
        It "Imports with no errors" {
            $global:Form | should -Not -BeNullOrEmpty
        }
        It "Title should match XML" {
            $global:Form.title | should -Be $global:XAML.window.Title
        }
    } 
}

Describe "Test Fail" {
    Context "XML" {
        It "This should fail" {
            "fail" | should -Be "fail"
        }
    }
}