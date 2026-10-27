# tim-17
Jobly - studentski poslovi
# Jobly

## Članovi tima
* Nikola Vasiljević 68/24SI (GitHub: nikola-vasiljevic04)
* Vojislav Popovic 121/24SI (GitHub: wojo16)

## Opis sistema
Jobly je moderni informacioni sistem za omladinsku i studentsku zadrugu. Sistem povezuje studente koji traže privremene poslove sa poslodavcima kojima je potrebna radna snaga. Studenti putem mobilne aplikacije pretražuju poslove i apliciraju, dok poslodavci i referenti u zadruzi koriste backoffice aplikaciju za kreiranje oglasa, pregled kandidata i upravljanje njihovim radnim statusom.

## Zahtevi

**1. Uloge**  
Sistem ima dve uloge: student (koji pretražuje poslove i šalje prijave) i poslodavac / referent (koji postavlja oglase i upravlja prijavama kandidata).

**2. Stanja**  
Glavni pojam sistema je *Prijava na posao*, koja prolazi kroz četiri stanja: na čekanju (poslata), prihvaćena (student je odabran), odbijena i završena (posao odrađen i isplaćen).

**3. Pravila**  
Svaki oglas ima tačan broj traženih radnika. Server donosi konačnu odluku i odbija prijavu studenta ukoliko se u međuvremenu broj preostalih slobodnih mesta za taj posao popunio.

**4. Rad bez mreže**  
Student može bez internet konekcije da povuče (otkaže) svoju prijavu u mobilnoj aplikaciji, a sistem će tu izmenu sinhronizovati sa serverom čim mreža postane dostupna.

**5. Posao za osoblje**  
Poslodavci na velikom ekranu backoffice aplikacije koriste napredni tabelarni i kanban prikaz kako bi uporedo pregledali veliki broj prijavljenih kandidata za različite oglase i masovno menjali njihove statuse.

**6. Javni sadržaj**  
Osnovni podaci o aktuelnim i otvorenim poslovima (naziv pozicije, grad i satnica) prikazuju se na javnom vebu bez potrebe za prijavom, kako bi bili dostupni web pretraživačima.
