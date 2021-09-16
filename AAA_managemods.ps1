Add-Type -Path ".\BepInEx\core\Mono.Cecil.dll"
Add-Type -Path ".\BepInEx\core\Mono.Cecil.Pdb.dll"

Function Get-ModTDType {
    param (
        [Mono.Cecil.TypeDefinition]$td
    )

    if ($td.BaseType -ne $null -and $td.BaseType.Name -eq "PartialityMod") {
        return "PartMod"
    }

    $contract_M = $false;
    $contract_P = $false;
    foreach ($method in $td.Methods) {
        if ($method.IsStatic -and $method.Name -eq "Patch" -and $method.HasParameters -and $method.Parameters[0].Name -eq "assembly" -and $method.Parameters[0].ParameterType.Name -eq "AssemblyDefinition" ) {
            $contract_M = $true; break;
        }
    }
    foreach ($prop in $td.Properties) {
        if ($prop.Name -eq "TargetDLLs" -and $prop.GetMethod -ne $null -and $prop.PropertyType.Name.Contains("IEnumerable")) {
            $contract_P = $true; break;
        }
    }
    if ($contract_P -and $contract_M) {
        return "BepPatcher"
    }

    if ($td.HasCustomAttributes)
    {
        foreach ($catr in $td.CustomAttributes)
        {
            if ($catr.AttributeType.Name -eq "MonoModPatch") {
                return "MonoModPatch"
            }
            if ($catr.AttributeType.Namespace -eq "BepInEx") {
                return "BepPlugin"
            }
        }
    }
    if ($td.HasNestedTypes)
    {
        foreach ($ntd in $td.NestedTypes)
        {
            $res = Get-ModTDType -td $ntd
            if ($res -ne "") {
                return $res
            }
        }
    }

    return "";
}

Function Get-ModType {
    param (
        [string]$ModDLL
    )

    $md = [Mono.Cecil.ModuleDefinition]::ReadModule($ModDLL)

    $ModType = "";

    foreach($td in $md.Types) {
        $res = Get-ModTDType -td $td
        if ($res -ne ""){
            $ModType = $res
            break
        }
    }

    if($ModType -eq ""){
        echo "Failed to get mod type of $ModDLL"
        exit
    }

    return $ModType
}

Function Get-ModTargetFolder {
    param (
        [string]$ModType
    )

    switch ($ModType) {
        "BepPatcher" {
            return ".\BepInEx\patchers"
        }
        "MonoModPatch" {
            return ".\BepInEx\monomod"
        }
    }
    
    # Everything else goes in the plugins folder
    return ".\BepInEx\plugins"
}

Function Get-MMName {
    param (
        [string]$DLLName
    )

    $ReplacedName = $DLLName -replace ".dll",""
    return "Assembly-CSharp.$ReplacedName.mm.dll"
}

Function Remove-AllMods {
    $PatchDlls = ls ".\BepInEx\patchers\*.dll" | Where { @("BepInEx.MonoMod.Loader.dll","Dragons.dll","Dragons.HookGenCompatibility.dll","Dragons.PublicDragon.dll") -notcontains $_.Name }
    if($PatchDlls -ne $null) {
        rm $PatchDlls
    }
    rm "$PSScriptRoot\BepInEx\plugins\*.dll"
    rm "$PSScriptRoot\BepInEx\monomod\Assembly-CSharp.*.mm.dll"
}

Function Apply-ModSetup {
    param (
        [string[]]$Dlls
    )

    foreach ($i in $Dlls) {
        $ModPath = ".\Mods\$i"

        $t = Get-ModType -ModDLL $ModPath
        $TargetFolder = Get-ModTargetFolder -ModType $t

        $tname = $i

        if($t -eq "MonoModPatch") {
            $tname = Get-MMName -DLLName $tname
        }

        cp $ModPath "$TargetFolder\$tname"

        echo "Copied $TargetFolder\$tname"
    }
}

$Setups = (cat .\AAA_modsetups.json | ConvertFrom-Json).setups

echo "The current setups are available here:"
$Setups | % {$i=0} {[PSCustomObject]@{index=$i; name=$_.name}; $i++} | Out-Host

$Choice = [int](Read-Host -Prompt "Type the index of the setup you want to enable")
$ChosenOption = $Setups[$Choice]

Remove-AllMods
Apply-ModSetup -Dlls $ChosenOption.mods

echo "$($ChosenOption.name) Enabled!"

Read-Host -Prompt "Press enter to close this window..."
