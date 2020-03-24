[CmdletBinding()]
param(
    [Parameter()]
    [string]
    $CmdletModule = (Join-Path -Path $PSScriptRoot `
            -ChildPath "..\Stubs\Office365.psm1" `
            -Resolve)
)
$GenericStubPath = (Join-Path -Path $PSScriptRoot `
    -ChildPath "..\Stubs\Generic.psm1" `
    -Resolve)
Import-Module -Name (Join-Path -Path $PSScriptRoot `
        -ChildPath "..\UnitTestHelper.psm1" `
        -Resolve)

$Global:DscHelper = New-O365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource "EXOSafeLinksRule" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        $secpasswd = ConvertTo-SecureString "test@password1" -AsPlainText -Force
        $GlobalAdminAccount = New-Object System.Management.Automation.PSCredential ("tenantadmin", $secpasswd)

        Mock -CommandName Close-SessionsAndReturnError -MockWith {

        }

        Mock -CommandName Test-MSCloudLogin -MockWith {

        }

        Mock -CommandName Get-PSSession -MockWith {

        }

        Mock -CommandName Remove-PSSession -MockWith {

        }

        Mock -CommandName New-SafeLinksRule -MockWith {
            return @{

            }
        }

        Mock -CommandName Set-SafeLinksRule -MockWith {
            return @{

            }
        }

        Mock -CommandName Remove-SafeLinksRule -MockWith {
            return @{

            }
        }

        Mock -CommandName New-EXOSafeLinksRule -MockWith {
            return @{

            }
        }

        Mock -CommandName Set-EXOSafeLinksRule -MockWith {
            return @{

            }
        }

        # Test contexts
        Context -Name "SafeLinksRule creation." -Fixture {
            $testParams = @{
                Ensure             = 'Present'
                Identity           = 'TestRule'
                GlobalAdminAccount = $GlobalAdminAccount
                SafeLinksPolicy    = 'TestSafeLinksPolicy'
                Enabled            = $true
                Priority           = 0
                RecipientDomainIs  = @('contoso.com')
            }

            Mock -CommandName Get-SafeLinksRule -MockWith {
                return @{
                    Identity = 'SomeOtherPolicy'
                }
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should call the Set method" {
                Set-TargetResource @testParams
            }
        }

        Context -Name "SafeLinksRule update not required." -Fixture {
            $testParams = @{
                Ensure             = 'Present'
                Identity           = 'TestRule'
                GlobalAdminAccount = $GlobalAdminAccount
                SafeLinksPolicy    = 'TestSafeLinksPolicy'
                Enabled            = $true
                Priority           = 0
                RecipientDomainIs  = @('contoso.com')
            }

            Mock -CommandName Get-SafeLinksRule -MockWith {
                return @{
                    Ensure             = 'Present'
                    Identity           = 'TestRule'
                    GlobalAdminAccount = $GlobalAdminAccount
                    SafeLinksPolicy    = 'TestSafeLinksPolicy'
                    Enabled            = $true
                    Priority           = 0
                    RecipientDomainIs  = @('contoso.com')
                    State              = 'Enabled'
                }
            }

            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should Be $true
            }
        }

        Context -Name "SafeLinksRule update needed." -Fixture {
            $testParams = @{
                Ensure             = 'Present'
                Identity           = 'TestRule'
                GlobalAdminAccount = $GlobalAdminAccount
                SafeLinksPolicy    = 'TestSafeLinksPolicy'
                Enabled            = $true
                Priority           = 0
                RecipientDomainIs  = @('contoso.com')
            }

            Mock -CommandName Get-SafeLinksRule -MockWith {
                return @{
                    Ensure             = 'Present'
                    Identity           = 'TestRule'
                    GlobalAdminAccount = $GlobalAdminAccount
                    SafeLinksPolicy    = 'TestSafeLinksPolicy'
                    State              = 'Disabled'
                    Priority           = 0
                    RecipientDomainIs  = @('fabrikam.com')
                }
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should call the Set method" {
                Set-TargetResource @testParams
            }
        }

        Context -Name "SafeLinksRule removal." -Fixture {
            $testParams = @{
                Ensure             = 'Absent'
                Identity           = 'TestRule'
                GlobalAdminAccount = $GlobalAdminAccount
                SafeLinksPolicy    = 'TestSafeLinksPolicy'
                Enabled            = $true
                Priority           = 0
                RecipientDomainIs  = @('contoso.com')
            }

            Mock -CommandName Get-SafeLinksRule -MockWith {
                return @{
                    Identity = 'TestRule'
                }
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should call the Set method" {
                Set-TargetResource @testParams
            }
        }

        Context -Name "ReverseDSC Tests" -Fixture {
            $testParams = @{
                GlobalAdminAccount = $GlobalAdminAccount
            }

            Mock -CommandName Get-SafeLinksRule -MockWith {
                return @{
                    Identity = 'TestRule'
                }
            }

            It "Should Reverse Engineer resource from the Export method" {
                Export-TargetResource @testParams
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
