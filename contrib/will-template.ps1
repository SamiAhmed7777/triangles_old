<#!
.SYNOPSIS
    Generate a plain-text outline of a personal will for review.
.DESCRIPTION
    This interactive PowerShell script collects key details that are typically
    included in a simple last will and testament and emits a formatted draft to
    a text file. The output is not legal advice and should be reviewed by a
    qualified attorney before it is executed.
#>
[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Path to write the draft will.")]
    [ValidateNotNullOrEmpty()]
    [string]
    $OutputPath = (Join-Path -Path $PSScriptRoot -ChildPath 'draft-will.txt')
)

function Read-RequiredField {
    param(
        [string]$Prompt,
        [string]$Default
    )

    while ($true) {
        if ($null -ne $Default -and $Default.Trim().Length -gt 0) {
            $response = Read-Host -Prompt "$Prompt [$Default]"
            if ([string]::IsNullOrWhiteSpace($response)) {
                return $Default
            }
        }
        else {
            $response = Read-Host -Prompt $Prompt
        }

        if (-not [string]::IsNullOrWhiteSpace($response)) {
            return $response.Trim()
        }

        Write-Warning 'Please enter a value.'
    }
}

Write-Host 'This script creates a draft will for personal review only.' -ForegroundColor Yellow
Write-Host 'Consult a licensed attorney to ensure the draft meets your legal requirements.' -ForegroundColor Yellow

$testatorName = Read-RequiredField -Prompt 'Full legal name of testator'
$testatorAddress = Read-RequiredField -Prompt 'Current residential address'
$testatorCityStateZip = Read-RequiredField -Prompt 'City, State/Province, Postal Code'
$testatorDateOfBirth = Read-RequiredField -Prompt 'Date of birth (e.g., 01 January 1970)'

$executorName = Read-RequiredField -Prompt 'Executor full legal name'
$executorRelationship = Read-RequiredField -Prompt 'Relationship of executor to testator'
$executorAddress = Read-RequiredField -Prompt 'Executor address'

$alternateExecutorName = Read-RequiredField -Prompt 'Alternate executor full legal name'
$alternateExecutorRelationship = Read-RequiredField -Prompt 'Relationship of alternate executor'
$alternateExecutorAddress = Read-RequiredField -Prompt 'Alternate executor address'

$beneficiaries = @()
while ($true) {
    $beneficiaryName = Read-Host -Prompt 'Beneficiary name (press Enter when finished)'
    if ([string]::IsNullOrWhiteSpace($beneficiaryName)) {
        break
    }

    $beneficiaryRelationship = Read-RequiredField -Prompt "Relationship of $beneficiaryName to testator"
    $beneficiaryShare = Read-RequiredField -Prompt "Share of estate for $beneficiaryName (e.g., percentage or assets)"

    $beneficiaries += [pscustomobject]@{
        Name = $beneficiaryName.Trim()
        Relationship = $beneficiaryRelationship
        Share = $beneficiaryShare
    }
}

if ($beneficiaries.Count -eq 0) {
    Write-Warning 'No beneficiaries were provided. The draft will include a placeholder.'
}

$guardianship = Read-Host -Prompt 'Guardian(s) for minor children or dependents (leave blank if not applicable)'
$specialBequests = Read-Host -Prompt 'Specific bequests or gifts (leave blank if none)'
$funeralPreferences = Read-Host -Prompt 'Funeral or memorial wishes (leave blank if none)'
$additionalNotes = Read-Host -Prompt 'Additional instructions (leave blank if none)'

$beneficiarySection = if ($beneficiaries.Count -gt 0) {
    $beneficiaries | ForEach-Object {
@"
- $($_.Name) ($($_.Relationship)): $($_.Share)
"@
    } | Out-String
}
else {
    "- [Add beneficiary details here]`n"
}

$draft = @"
LAST WILL AND TESTAMENT OF $testatorName

I, $testatorName, born $testatorDateOfBirth and residing at $testatorAddress, $testatorCityStateZip, declare this document to be my Last Will and Testament.

1. REVOCATION OF PRIOR WILLS
   I revoke all prior wills and codicils.

2. APPOINTMENT OF EXECUTOR
   I appoint $executorName ($executorRelationship), whose address is $executorAddress, to serve as Executor of my estate. If $executorName is unable or unwilling to serve, I appoint $alternateExecutorName ($alternateExecutorRelationship), whose address is $alternateExecutorAddress, as Alternate Executor.

3. DISTRIBUTION OF ESTATE
   I direct my Executor to distribute my estate as follows:
$beneficiarySection
4. GUARDIANSHIP OF MINOR CHILDREN OR DEPENDENTS
   $([string]::IsNullOrWhiteSpace($guardianship) ? 'No guardianship instructions provided.' : $guardianship)

5. SPECIFIC BEQUESTS
   $([string]::IsNullOrWhiteSpace($specialBequests) ? 'No specific bequests listed.' : $specialBequests)

6. FUNERAL AND MEMORIAL PREFERENCES
   $([string]::IsNullOrWhiteSpace($funeralPreferences) ? 'No specific instructions provided.' : $funeralPreferences)

7. ADDITIONAL INSTRUCTIONS
   $([string]::IsNullOrWhiteSpace($additionalNotes) ? 'None.' : $additionalNotes)

8. GENERAL PROVISIONS
   My Executor shall have the powers granted by law to settle my estate, including the power to sell, manage, and distribute assets as necessary.

IN WITNESS WHEREOF, I have signed this Last Will and Testament on ______________________.

__________________________________
$testatorName, Testator

WITNESSES

Witness 1: ____________________________   Address: ____________________________
Witness 2: ____________________________   Address: ____________________________

NOTARY (if required):
State/Province of _____________________
County of _____________________________
Subscribed and sworn before me on ____________________ by $testatorName.

__________________________________
Notary Public
My commission expires: ________________

DISCLAIMER: This draft is for discussion purposes only and does not constitute legal advice. Consult a licensed attorney to ensure this document meets all legal requirements in your jurisdiction.
"@

try {
    $null = New-Item -ItemType File -Path $OutputPath -Force
    Set-Content -Path $OutputPath -Value $draft -Encoding UTF8
    Write-Host "Draft will saved to $OutputPath" -ForegroundColor Green
}
catch {
    Write-Error "Failed to write the draft will: $($_.Exception.Message)"
    exit 1
}

Write-Host 'Review the draft with a licensed attorney before relying on it.' -ForegroundColor Yellow
