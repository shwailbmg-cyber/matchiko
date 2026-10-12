# Release (Google Play)

## 1. Signing key (once, keep it safe forever)

Losing this key means you can never update the app. Back it up offline.

```bash
keytool -genkey -v -keystore ~/matchiko-upload.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias upload
```

Create `app/android/key.properties` (git-ignored, never commit it):

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/home/you/matchiko-upload.jks
```

Use Play App Signing (default): Google keeps the app key, this one is
only the upload key.

## 2. Build

```bash
cd app
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols \
  --dart-define-from-file=env/prod.json
```

Keep `build/symbols` for each release (needed to read crash stack traces).
Version: `version:` in `pubspec.yaml` (`1.0.0+1` → name 1.0.0, code 1;
raise the code for every upload).

## 3. Play Console

1. Create the app: name **Matchiko**, default language French, free.
2. Upload `build/app/outputs/bundle/release/app-release.aab` to
   **Testing → Internal testing**, add testers by email.
3. Fill the store listing below, the icon (`app/web/icons/Icon-512.png`),
   a 1024×500 feature graphic and 2+ phone screenshots.
4. Data safety: phone number, name, approximate location (wilaya) are
   collected; no data is sold; users can delete their account in the app
   (Settings → Delete account). Camera: only to scan QR codes.
5. Privacy policy URL: needed before production (legal review pending,
   see LOOP.md notes).

Icons are generated: `cd app && python3 tool/make_icons.py`.

## Store listing

### Français (default)

- **Titre** (30): Matchiko – Foot entre amis
- **Description courte** (80): Trouvez un match près de chez vous, réservez un terrain, payez sur place.
- **Description complète**:

  Matchiko vous aide à jouer au foot plus souvent.

  • Trouvez un match qui cherche des joueurs, du 3 contre 3 au 11 contre 11.
  • Réservez un terrain en quelques secondes, puis payez en espèces au stade.
  • Partagez le prix entre les joueurs, sans calcul.
  • Invitez vos amis et créez votre équipe.
  • Recevez un rappel avant le match.
  • Gagnez de l’XP et des pièces quand vous jouez fair-play.

  Gérants de stade : confirmez les réservations, scannez le QR code du
  joueur et suivez votre journée depuis l’application.

  Disponible dans les 69 wilayas, en français, en arabe et en anglais.

### العربية

- **العنوان**: ماتشيكو – مباريات كرة القدم
- **وصف قصير**: اعثر على مباراة قريبة منك، احجز ملعبًا، وادفع في عين المكان.
- **الوصف الكامل**:

  يساعدك ماتشيكو على لعب كرة القدم أكثر.

  • اعثر على مباراة تبحث عن لاعبين، من 3 ضد 3 إلى 11 ضد 11.
  • احجز ملعبًا في ثوانٍ، ثم ادفع نقدًا في الملعب.
  • قسّم السعر بين اللاعبين بدون حساب.
  • ادعُ أصدقاءك وكوّن فريقك.
  • تلقَّ تذكيرًا قبل المباراة.
  • اربح نقاط الخبرة والقطع عندما تلعب بروح رياضية.

  مسيّرو الملاعب: أكّدوا الحجوزات، امسحوا رمز QR الخاص باللاعب، وتابعوا
  يومكم من التطبيق.

  متوفر في 69 ولاية، بالعربية والفرنسية والإنجليزية.

### English

- **Title**: Matchiko – Football games
- **Short description**: Find a game near you, book a pitch, pay at the stadium.
- **Full description**:

  Matchiko helps you play football more often.

  • Find a game that needs players, from 3v3 to 11v11.
  • Book a pitch in seconds, then pay cash at the stadium.
  • Split the price between players, no maths.
  • Invite your friends and build your team.
  • Get a reminder before the game.
  • Earn XP and coins when you play fair.

  Stadium managers: confirm bookings, scan the player's QR code and run
  your day from the app.

  Available in all 69 wilayas, in French, Arabic and English.
