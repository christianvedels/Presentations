# Styleguide: Offentlige foredrag (Public Talks)

Dette dokument supplerer den generelle `XX_Template/Styleguide.md` med tilpasninger specifikt for offentlige foredrag (ikke kursusforelæsninger). Det er baseret på eksisterende foredrag i mappen (`Bruddet_paa_Aggertangen`, `Hvad_er_meningen_med_AI`, osv.).

---

## 0) Grundlæggende info

- **Foredragsholder:** Christian Vedel
- **Tilhørsforhold:** Syddansk Universitet, Økonomisk Institut
- **Kontakt:** christian-vs@sam.sdu.dk
- **Sprog:** Dansk (medmindre andet er specificeret)

---

## 1) Hvad er anderledes for offentlige foredrag?

| Element | Kursusforelæsning | Offentligt foredrag |
|---|---|---|
| Øvelsesslides | Obligatoriske | **Udelades** |
| "Rejs hånden"-slides | Obligatoriske | **Udelades** |
| Matematisk notation | Fuld formelnotation | Minimalt, kun hvor nødvendigt |
| Tone | Faglig, pædagogisk | Fortællende, engagerende |
| "Hvem er jeg"-slide | Valgfri | **Obligatorisk** |
| Afslutningsslide | "Næste gang" | **Tak + kontaktinfo** |
| Referencer | Separat sektion | Fodnoter med `.footnote[]` |
| Talernoter | Svarnøgler (skjult) | Korte stikord med `???` |
| Visuelle elementer | Funktionelle figurer | Historiske billeder og illustrationer liberalt |

---

## 2) Teknisk setup (samme som template)

- Output: `xaringan::moon_reader`
- 16:9 ratio
- `insert-logo.html` via `after_body`
- `self_contained: false`
- xaringanExtra: panelset, tile-view, progress bar
- CSS-klasser: `.pull-left`, `.pull-right`, `.pull-left-wide`, `.pull-right-narrow` osv.

---

## 3) Deck-niveau struktur

### Titelslide (SKAL)
```rmd
class: center, inverse, middle
# [Titel på foredrag]
## [Undertitel]
### Christian Vedel,<br>Syddansk Universitet, Økonomisk Institut
### [Lejlighed, dato]
```

### "Hvem er jeg"-slide (SKAL for offentlige foredrag)
```rmd
class: middle
.pull-left[
# Christian Vedel
- **Økonomisk** historiker v. SDU
- PhD, [år]: "[afhandlingstitel]"
- Forskning: Geografi og transport; maskinlæring og kausal inference
]
.pull-right[
![Billede](Figures/portræt.jpg)
]
```

### Agenda/overblik (SKAL)
Brug samme struktur som template men med danske overskrifter.

### Sektionsdividers (SKAL)
Samme som template: `class: inverse, middle, center`

### Afslutningsslide (SKAL)
```rmd
---
class: middle
# Tak for opmærksomheden

.pull-left[
**Spørgsmål?**

- **Email:** christian-vs@sam.sdu.dk
- **Twitter/X:** @ChristianVedel
- **BlueSky:** @christianvedel.bsky.social
- Paperet: [link]
]

.pull-right[
![Billede](...)
]
```

---

## 4) Indholdsregler for offentlige foredrag

### Narrativ over punktlister
- Foretruk korte, sætningsformede bullets frem for nøgleord.
- Fortæl en historie — brug eksempler og anekdoter til at illustrere pointer.
- Et billede (historisk foto, maleri, kortillustration) er ofte bedre end en bullet-liste.

### Matematik
- Undgå formler, medmindre de er uomgængelige.
- Hvis formler bruges, forklar dem i ord på samme slide.
- Brug `.small123[]` til formler så de ikke dominerer.

### Talernoter (???)
- Korte stikord og fortællelinjer til foredragsholderen.
- Fx: `??? "Her er det vigtigt at understrege..."`
- Aldrig løsningsforslag (det er der ingen øvelser at løse).

### Referencer
- Brug `.footnote[.small123[...]]` til kildehenvisninger.
- Ingen separat referenceslide (eller kun en meget kort en sidst).

### Visuelle elementer
- Historiske fotografier og malerier er velegnede — de engagerer et alment publikum.
- Kort (maps) er særligt effektive for dansk geografisk-historisk stof.
- Figurer fra paperet bruges, men med forklarende tekst på siden.

---

## 5) Tidsstruktur

For et 45-minutters foredrag, råd:
- Titelslide + "hvem er jeg": ~2 min
- Sektionsdividers bruges som naturlige pauser
- Planlæg ~1-1.5 min per slide i gennemsnit
- Ca. 30-38 slides er passende for 45 min
- Sæt tid af til spørgsmål (5-10 min) ud over foredragstiden

---

## 6) Konsistenstjekliste før publicering

1. Titelslide: navn, tilhørsforhold, dato opdateret
2. "Hvem er jeg"-slide til stede
3. Sektionsdividers på plads
4. Ingen øvelses- eller RYH-slides
5. Alle figurer renders og stier virker
6. Afslutningsslide med kontaktinfo
7. Talernoter (???) til de vigtigste slides
8. Sprog konsistent (dansk)
9. Ingen placeholder-tekst tilbage
10. Knittes til HTML uden fejl
