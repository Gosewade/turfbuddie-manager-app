# TurfBuddie Manager (owner app) v1.1

Ek owner, multiple ventures: Turf, Pickleball, Snooker. Home / Slots / AI Buddie / Payouts / Insights.
Abhi demo data pe chalta hai. Pehla venture: "Welcome Venture" (Turf).

## APK build (GitHub Actions)
Repo mein push karo -> Actions -> "Build APK" -> Artifacts -> `turfbuddie-manager-apk`.

## Backend attach karna
Sab kuch `lib/repository.dart` se jata hai. `ManagerRepository` implement karo aur last line
`final ManagerRepository repo = MockRepository();` badlo. `ventureId == null` ka matlab "Sabhi ventures".
