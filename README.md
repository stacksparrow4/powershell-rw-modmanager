# Powershell Rain World Modmanager

## Why?

[BOI](https://github.com/Rain-World-Modding/BOI) is the current accepted mod manager for Rain World. However, I play the game with a lot of different mod setups - for example I have
a set of Mods I use for Jolly Co-op, one for carnivore + hunter spawns, and one for Monkland. To switch between these with BOI, I have to enable and disable each mod manually.

Powershell Rain World Modmanager is a small(ish) powershell script that carries the basic functionality of BOI. Personally I found the BOI code hard to read, so hopefully this
powershell script also provides a simple, extensible base for any similar issues you might want to solve relating to moving around Rain World Mods.

## How to use

1. Make sure your powershell execution policy allows running the script.
2. The script uses Mono.Cecil.dll and Mono.Cecil.Pdb.dll to figure out where to put mods. Make sure powershell can load these files by opening powershell, going to your Rain World
  directory and running the powershell cmdlet `Unblock-File .\BepInEx\core\Mono.Cecil.dll,.\BepInEx\core\Mono.Cecil.Pdb.dll`. **Make sure to restart your powershell window for these changes to take effect.**
3. Download `AAA_managemods.ps1` and `AAA_modsetups.json` and place them in your root Rain World directory.
4. Edit `AAA_modsetups.json` to your liking. Note: each mod dll must refer to a dll in your Mods folder (should be in the root of your Rain World Directory). The attached `AAA_modsetups.json`
  shows the configuration I use to show you the format for mods.
5. Run the powershell script `AAA_managemods.ps1`.
