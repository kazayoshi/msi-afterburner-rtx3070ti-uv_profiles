# RTX 3070 Ti (DEV_2482) — profile MSI Afterburner na zasilacz Dell 12V @ 18A

## Pliki źródłowe (to repo, ten folder)

- `TEST1_1830MHz_825mV_MEM+0_PL70/VEN_10DE&DEV_2482&SUBSYS_146A10DE&REV_A1&BUS_1&DEV_0&FN_0.cfg`
  — flat 1830 MHz @ 825 mV (+193 w punkcie 825), Mem +0, Power Limit 70%, Fan 65%. Baza.
- `TEST2_1845MHz_825mV_MEM+0_PL70/...` — flat 1845 @ 825, Mem +0, PL 70%, Fan 65%. +15 MHz względem bazy.
- `TEST3_1860MHz_825mV_MEM+500_PL70/...` — flat 1860 @ 825, Mem +500, PL 70%, Fan 70%. Max.
- W każdym pliku testowym sekcje `[Startup]`, `[Profile1]`, `[Profile2]` = test.
  `[Profile3]` = nietknięty stary flat ~1680 (rescue), `[Profile4/5]` = stare krzywe.
- `VEN_10DE&DEV_2482&SUBSYS_146A10DE&REV_A1&BUS_1&DEV_0&FN_0.cfg` (root folderu)
  — oryginał zrzutu z PC: Startup/Profile3/4/5, `Core -225 MHz`, `PL 100%`, krzywe sprzed spłaszczenia.
- `VEN_10DE&DEV_2504...cfg` — **NIE UŻYWAĆ, to RTX 3060** (pozostałość). Nie kopiować na PC z 3070 Ti.
- `VEN_0000...cfg` — generyczny fallback, nie kopiować.
- `Profile1-5.cfg`, `MSIAfterburner.cfg` — tylko monitoring/OSD i ustawienia globalne, **nie zawierają OC**. Nie podmieniać ich dla samego UV.
- `Screenshot ...png` — dokumentacja: flat 1830@825 (+193) i 1680@750 (+230), okno główne 1770 MHz / 818 mV i 1680 MHz / 787 mV.

## Plik docelowy (obcy PC z tą samą kartą)

Docelowa ścieżka na Windows:

`C:\Program Files (x86)\MSI Afterburner\Profiles\VEN_10DE&DEV_2482&SUBSYS_146A10DE&REV_A1&BUS_1&DEV_0&FN_0.cfg`

Uwaga: końcówka `BUS_1&DEV_0&FN_0` zależy od slotu PCIe. Jeśli na obcym PC nazwa pliku z `DEV_2482` ma inny BUS, to:
1. Odpal Afterburner, kliknij Apply, zamknij go i sprawdź który `VEN_10DE&DEV_2482...cfg` zmienił datę — to jest live plik.
2. Podmieniaj **ten** plik (zawartość z folderu TESTx, nazwę zostaw lokalną).

Karta musi być `VEN_10DE & DEV_2482` (RTX 3070 Ti). Przy innym DEV/SUBSYS nie kopiować — krzywa V/F nie pasuje.

## Jak podmienić (kolejność obowiązkowa TEST1 → TEST2 → TEST3)

Preferowana metoda (agent / drugi PC): skrypt `Install-GpuProfile.ps1` z root tego repo.
Sam znajduje live plik po `DEV_2482` (odporny na inny `BUS_x`), robi backup
`<nazwa>.bak-RRRRMMDD-GGMMSS.cfg` w `Profiles\` i wgrywa wybrany test:

```powershell
.\Install-GpuProfile.ps1 -Test 1   # potem 2, potem 3
```

Skrypt wymaga zamkniętego Afterburnera i odmawia pracy gdy nie widzi karty DEV_2482.
Metoda ręczna (fallback):

1. Zamknij MSI Afterburner + RTSS. Zrób backup live `VEN_...cfg` (np. na pulpit).
2. Skopiuj plik z folderu testowego do `Profiles\`, nadpisz (nazwa musi się zgadzać z lokalną).
3. Uruchom Afterburner, kliknij profil `1`, potem `Apply`.
4. Otwórz `Curve Editor`, sprawdź: płaska linia `1830 / 1845 / 1860 MHz` od `825 mV` w prawo.
5. Test: monitoring `Power, GPU voltage, Core clock, Power limit, Temp`. Najpierw 10 min benchmark, potem 30 min gra. Pass = brak crasha/artefaktów, `Power` typowo < 200 W, brak ciągłego `Power limit = 1`.
6. Dopiero po pass idź do kolejnego TESTx. Przycisk `3` = rescue (~1680, niskie zużycie).

## Ograniczenia zasilacza — tego się trzymaj

- Dell 12V @ 18A = **216 W peak**, nie ciągłe. Bezpiecznie: **~185–190 W sustained, max 200 W w odczycie Afterburnera**. Powyżej cegła odcina (szczególnie spiki Ampere +20–30 W na ms).
- Dlatego wszystkie TESTx mają `Power Limit 70%` (~203 W z 290 W TDP) jako bezpiecznik + `Temp Limit 83°C`. Orientacyjne moce: 1680@750 ≈ 160–175 W, 1830@825 ≈ 195–205 W (granica), 1860@825+MEM500 ≈ 210 W peak (klampowane przez PL).
- Sama pamięć 9501 MHz zjada ~45–55 W. Każde +500 do MEM to ok. +8–12 W.
- Fan w testach jest manualny (65/70%) celowo — żeby temperatura nie fałszowała testu mocy. Po testach można zejść niżej, ale nie przed pass.

## Czego unikać (wyłączenie cegły / ubity test)

- NIE ustawiaj `Power Limit 100%` ani stockowej krzywej (290 W) na tej cegle.
- NIE podnoś napięcia lock powyżej 825 mV i NIE idź powyżej 1860 MHz — moc rośnie z V², to prosta droga do odcięcia.
- NIE dokładaj MEM OC przed pass core (najpierw TEST1/2 na Mem +0, potem TEST3).
- NIE testuj na wentylatorze 30–36% pod obciążeniem — dobije do Temp Limit i wynik mocy będzie niemiarodajny.
- NIE przeskakuj kolejności i NIE uznawaj 5 min testu za stabilne.
- NIE kopiuj pliku `VEN_2504` (RTX 3060) ani nie twórz drugiej nazwy pliku w `Profiles\` — Afterburner czyta tylko plik zgodny z aktualnym BUS; zła nazwa = ustawienia się nie zaaplikują mimo że plik leży w folderze.
- NIE edytuj hex `VFCurve` ręcznie — flat = `offset = LOCK - baza` dla każdego punktu ≥ 825 mV; pliki TESTx mają to już policzone i zweryfikowane (0 rozjazdów).
