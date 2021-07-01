[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
                        -ChildPath "..\..\Unit" `
                        -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
            -ChildPath "\Stubs\Microsoft365.psm1" `
            -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
    -ChildPath "\Stubs\Generic.psm1" `
    -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath "\UnitTestHelper.psm1" `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource "TeamsMessagingPolicy" -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString "Pass@word1)" -AsPlainText -Force
            $GlobalAdminAccount = New-Object System.Management.Automation.PSCredential ("tenantadmin", $secpasswd)

            $Global:PartialExportFileName = "c:\TestPath"
            Mock -CommandName Update-M365DSCExportAuthenticationResults -MockWith {
                return @{}
            }

            Mock -CommandName Get-M365DSCExportContentForResource -MockWith {
                return "FakeDSCContent"
            }
            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -MockWith {
                return "Credential"
            }

            Mock -CommandName New-CsTeamsMessagingPolicy -MockWith {
            }

            Mock -CommandName Set-CsTeamsMessagingPolicy -MockWith {
            }

            Mock -CommandName Remove-CsTeamsMessagingPolicy -MockWith {
            }
        }

        # Test contexts
        Context -Name "When Messaging Policy doesn't exist but should" -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                = "TestPolicy"
                    Description             = "My sample policy"
                    ReadReceiptsEnabledType = "UserPreference"
                    AllowImmersiveReader    = $True
                    AllowGiphy              = $True
                    AllowStickers           = $True
                    AllowUrlPreviews        = $false
                    AllowUserChat           = $True
                    AllowUserDeleteMessage  = $false
                    AllowUserTranslation    = $True
                    AllowRemoveUser         = $false
                    AllowPriorityMessages   = $True
                    GiphyRatingType         = "MODERATE"
                    AllowMemes              = $False
                    AudioMessageEnabledType = "ChatsOnly"
                    AllowOwnerDeleteMessage = $False
                    GlobalAdminAccount      = $GlobalAdminAccount
                    Ensure                  = "Present"
                }

                Mock -CommandName Get-CsTeamsMessagingPolicy -MockWith {
                    return $null
                }
            }

            It "Should return absent from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Absent'
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should create the policy in the Set method" {
                Set-TargetResource @testParams
                Should -Invoke -CommandName New-CsTeamsMessagingPolicy -Exactly 1
            }
        }

        Context -Name "Message Policy exists but is not in the Desired State" -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                = "TestPolicy"
                    Description             = "My sample policy"
                    ReadReceiptsEnabledType = "UserPreference"
                    AllowImmersiveReader    = $True
                    AllowGiphy              = $True
                    AllowStickers           = $True
                    AllowUrlPreviews        = $false
                    AllowUserChat           = $True
                    AllowUserDeleteMessage  = $false
                    AllowUserTranslation    = $True
                    AllowRemoveUser         = $false
                    AllowPriorityMessages   = $True
                    GiphyRatingType         = "MODERATE"
                    AllowMemes              = $False
                    AudioMessageEnabledType = "ChatsOnly"
                    AllowOwnerDeleteMessage = $False
                    GlobalAdminAccount      = $GlobalAdminAccount
                    Ensure                  = "Present"
                }

                Mock -CommandName Get-CsTeamsMessagingPolicy -MockWith {
                    return @{
                        Identity                = "TestPolicy"
                        Description             = "Updated Sample policy"
                        ReadReceiptsEnabledType = "UserPreference"
                        AllowImmersiveReader    = $True
                        AllowGiphy              = $True
                        AllowStickers           = $false
                        AllowUrlPreviews        = $false
                        AllowUserChat           = $True
                        AllowUserDeleteMessage  = $false
                        AllowUserTranslation    = $True
                        AllowRemoveUser         = $false
                        AllowPriorityMessages   = $True
                        GiphyRatingType         = "MODERATE"
                        AllowMemes              = $False
                        AudioMessageEnabledType = "ChatsOnly"
                        AllowOwnerDeleteMessage = $False
                        GlobalAdminAccount      = $GlobalAdminAccount
                        Ensure                  = "Present"
                    }
                }
            }

            It "Should return Present from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should update the settings from the Set method" {
                Set-TargetResource @testParams
                Should -Invoke -CommandName Set-CsTeamsMessagingPolicy -Exactly 1
            }
        }

        Context -Name "Message Policy exists and is already in the Desired State" -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                = "TestPolicy"
                    Description             = "My sample policy"
                    ReadReceiptsEnabledType = "UserPreference"
                    AllowImmersiveReader    = $True
                    AllowGiphy              = $True
                    AllowStickers           = $True
                    AllowUrlPreviews        = $false
                    AllowUserChat           = $True
                    AllowUserDeleteMessage  = $false
                    AllowUserTranslation    = $True
                    AllowRemoveUser         = $false
                    AllowPriorityMessages   = $True
                    GiphyRatingType         = "MODERATE"
                    AllowMemes              = $False
                    AudioMessageEnabledType = "ChatsOnly"
                    AllowOwnerDeleteMessage = $False
                    GlobalAdminAccount      = $GlobalAdminAccount
                    Ensure                  = "Present"
                }

                Mock -CommandName Get-CsTeamsMessagingPolicy -MockWith {
                    return @{
                        Identity                = "Tag:TestPolicy"
                        Description             = "My sample policy"
                        ReadReceiptsEnabledType = "UserPreference"
                        AllowImmersiveReader    = $True
                        AllowGiphy              = $True
                        AllowStickers           = $True
                        AllowUrlPreviews        = $false
                        AllowUserChat           = $True
                        AllowUserDeleteMessage  = $false
                        AllowUserTranslation    = $True
                        AllowRemoveUser         = $false
                        AllowPriorityMessages   = $True
                        GiphyRatingType         = "MODERATE"
                        AllowMemes              = $False
                        AudioMessageEnabledType = "ChatsOnly"
                        AllowOwnerDeleteMessage = $False
                        GlobalAdminAccount      = $GlobalAdminAccount
                        Ensure                  = "Present"
                    }
                }
            }

            It "Should return Present from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should -Be $true
            }
        }

        Context -Name "Policy exists but it should not" -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                      = 'SamplePolicy'
                    GlobalAdminAccount            = $GlobalAdminAccount
                    Ensure                        = "Absent"
                }

                Mock -CommandName Get-CsTeamsMessagingPolicy -MockWith {
                    return @{
                        Identity                      = 'Tag:SamplePolicy'
                        Description                   = "My sample policy"
                        ReadReceiptsEnabledType       = "UserPreference"
                        AllowImmersiveReader          = $True
                        AllowGiphy                    = $True
                        AllowMemes                    = $False
                        AudioMessageEnabledType       = "ChatsOnly"
                        AllowOwnerDeleteMessage       = $False
                        ChannelsInChatListEnabledType = "EnabledUserOverride"
                        Ensure                        = "Present"
                        GlobalAdminAccount            = $GlobalAdminAccount
                    }
                }
            }

            It "Should return Present from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should remove the policy from the Set method" {
                Set-TargetResource @testParams
                Should -Invoke -CommandName Remove-CsTeamsMessagingPolicy -Exactly 1
            }
        }

        Context -Name "ReverseDSC Tests" -Fixture {
            BeforeAll {
                $testParams = @{
                    GlobalAdminAccount = $GlobalAdminAccount
                }

                Mock -CommandName Get-CsTeamsMessagingPolicy -MockWith {
                    return @{
                        Identity                = "TestPolicy"
                        Description             = "My sample policy"
                        ReadReceiptsEnabledType = "UserPreference"
                        AllowImmersiveReader    = $True
                        AllowGiphy              = $True
                        AllowStickers           = $True
                        AllowUrlPreviews        = $false
                        AllowUserChat           = $True
                        AllowUserDeleteMessage  = $false
                        AllowUserTranslation    = $True
                        AllowRemoveUser         = $false
                        AllowPriorityMessages   = $True
                        GiphyRatingType         = "MODERATE"
                        AllowMemes              = $False
                        AudioMessageEnabledType = "ChatsOnly"
                        AllowOwnerDeleteMessage = $False
                        GlobalAdminAccount      = $GlobalAdminAccount
                    }
                }
            }

            It "Should Reverse Engineer resource from the Export method" {
                Export-TargetResource @testParams
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
