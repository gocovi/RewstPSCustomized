function Get-TOTPCode {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Secret
    )

    function Get-TimeByteArray($WINDOW) {
        $span = (New-TimeSpan -Start (Get-Date -Year 1970 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0) -End (Get-Date).ToUniversalTime()).TotalSeconds
        $unixTime = [Convert]::ToInt64([Math]::Floor($span / $WINDOW))
        $byteArray = [BitConverter]::GetBytes($unixTime)
        [array]::Reverse($byteArray)
        return $byteArray
    }

    function Convert-HexToByteArray($hexString) {
        $byteArray = $hexString -replace '^0x', '' -split "(?<=\G\w{2})(?=\w{2})" | % { [Convert]::ToByte( $_, 16 ) }
        return $byteArray
    }

    function Convert-IntToHex([int]$num) {
        return ('{0:x}' -f $num)
    }

    function Add-LeftPad($str, $len, $pad) {
        if (($len + 1) -ge $str.Length) {
            while (($len - 1) -ge $str.Length) {
                $str = ($pad + $str)
            }
        }
        return $str;
    }

    function Convert-Base32ToHex($base32) {
        $base32chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
        $bits = "";
        $hex = "";

        for ($i = 0; $i -lt $base32.Length; $i++) {
            $val = $base32chars.IndexOf($base32.Chars($i));
            $binary = [Convert]::ToString($val, 2)
            $staticLen = 5
            $padder = '0'
            # Write-Host $binary
            $bits += Add-LeftPad $binary.ToString()  $staticLen  $padder
        }


        for ($i = 0; $i + 4 -le $bits.Length; $i += 4) {
            $chunk = $bits.Substring($i, 4)
            # Write-Host $chunk
            $intChunk = [Convert]::ToInt32($chunk, 2)
            $hexChunk = Convert-IntToHex($intChunk)
            # Write-Host $hexChunk
            $hex = $hex + $hexChunk
        }
        return $hex;

    }

    $HMAC = New-Object -TypeName System.Security.Cryptography.HMACSHA1
    $HMAC.key = Convert-HexToByteArray(Convert-Base32ToHex(($SECRET.ToUpper())))
    $TimeBytes = Get-TimeByteArray 30
    $RandomHash = $HMAC.ComputeHash($TimeBytes)
    
    $Offset = $RandomHash[($RandomHash.Length - 1)] -band 0xf
    $FullOTP = ($RandomHash[$Offset] -band 0x7f) * [math]::pow(2, 24)
    $FullOTP += ($RandomHash[$Offset + 1] -band 0xff) * [math]::pow(2, 16)
    $FullOTP += ($RandomHash[$Offset + 2] -band 0xff) * [math]::pow(2, 8)
    $FullOTP += ($RandomHash[$Offset + 3] -band 0xff)

    $ModNumber = [math]::pow(10, 6)
    $TOTP = $FullOTP % $ModNumber
    $TOTP = $TOTP.ToString("0" * 6)

    $TOTP
}
