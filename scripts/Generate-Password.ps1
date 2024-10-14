# Define character sets
$lowercase = 'abcdefghijklmnopqrstuvwxyz'.TocharArray()
$uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.TocharArray()
$numbers = '0123456789'.TocharArray()
$special = '!@#$%^&*()-_=+[]{}|;:,.<>?/'.TocharArray()

# Create a function to generate a random password
function Generate-Password {
    param (
        [int]$length = 12 # Minimum length of 12 characters
    )

    # Ensure each required type is included at least once
    $passwordChars = New-Object char[] $length

    $passwordChars[0] = ($lowercase | Get-Random) # At least 1 lowercase
    $passwordChars[1] = ($uppercase | Get-Random) # At least 1 uppercase
    $passwordChars[2] = ($numbers   | Get-Random) # At least 1 number
    $passwordChars[3] = ($special   | Get-Random) # At least 1 special character

    # Fill remaining length with random characters from all sets
    $allChars = $lowercase + $uppercase + $numbers + $special
    for ($i = 4; $i -lt $length; $i++) {
        $passwordChars[$i] = ($allChars | Get-Random)
    }

    # Shuffle the characters to randomize positions
    $passwordChars = ($passwordChars | Sort-Object {Get-Random})

    return [System.Text.Encoding]::UTF8.GetString($passwordChars)
}