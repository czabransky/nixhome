$symbols = '!@#$%^&*'.ToCharArray()
$characterList = 'a'..'z' + 'A'..'Z' + '0'..'9' + $symbols

function GeneratePassword {
    param(
        [ValidateRange(12,256)]
        [int]$Length = 14,

        [switch]$PlainText
    )

    do {
        $password = -join (1..$Length | ForEach-Object {
            $characterList[
                [System.Security.Cryptography.RandomNumberGenerator]::GetInt32(
                    0, $characterList.Length
                )
            ]
        })

        $hasLower = $password -cmatch '[a-z]'
        $hasUpper = $password -cmatch '[A-Z]'
        $hasDigit = $password -match  '[0-9]'
        $hasSymbol = $password.IndexOfAny($symbols) -ne -1
    }
    until (($hasLower + $hasUpper + $hasDigit + $hasSymbol) -ge 3)

    if ($PlainText) {
        return $password
    }

    return $password | ConvertTo-SecureString -AsPlainText -Force
}
