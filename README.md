# RTX 3070 Ti — stable undervolt for Dell 12V @ 18A (216 W) PSU

MSI Afterburner profiles for the RTX 3070 Ti (`DEV_2482`) that stay within what a
Dell 12 V / 18 A brick can deliver: flat V/F curve from **825 mV**
(1830 → 1845 → 1860 MHz), **Power Limit 70%** (~203 W of 290 W TDP).

```
tests/      TEST1 / TEST2 / TEST3 — profiles to install, in this order
tools/      Install-GpuProfile.ps1 — installer for the target PC
original/   stock dump of the 3070 Ti profile (PL 100%, not for brick use)
docs/       curve screenshots and Afterburner window captures
reference/  monitoring/OSD settings (no OC inside)
```

Usage on a PC with an RTX 3070 Ti (Afterburner closed):

```powershell
.\tools\Install-GpuProfile.ps1 -Test 1   # then 2, then 3
```

Then in Afterburner: profile `1` → `Apply` → confirm the flat line from 825 mV
in Curve Editor. Profile `3` in each file is a low-power rescue (~1680 MHz).

Details, PSU limits, test procedure: `AGENTS.md`.
