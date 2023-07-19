##################################################
# QMK

function qmk-ps([Parameter(ValueFromRemainingArguments = $true)]$Rest) {
    C:\QMK_MSYS\shell_connector.cmd -c "qmk $Rest"
}

function flash() {
    qmk-ps compile -kb moonlander -km q
    qmk-ps flash -kb moonlander -km q
}

##################################################
# Zoom

function zoom([string]$target = "mob") {
    $knownTargets = @{};
    $knownTargets.Add("mob", "${env:mob_zoomuri}");
    $zoomUri = "zoommtg://zoom.us/join?confno="
    if ($knownTargets.Contains($target)) {
        $parts = $knownTargets[$target] -Split ":"
    }else {
        $parts = $target -Split ":"
    }

    $zoomUri = $zoomUri + $parts[0]
    if ($parts.Length -gt 1) {
        $zoomUri = $zoomUri + "&pwd=" + $parts[1]
    }
    start $zoomUri
}