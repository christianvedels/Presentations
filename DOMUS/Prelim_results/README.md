# Visual classification of the 366 Civitates plates

Every plate in `Data/Labelling/full_pages/` was inspected visually (Claude, 16 Sep 2026) and
answered on three questions. Nothing outside this folder was modified.

1. **Is there more than one city on the plate?**
2. **Is the city seen from above** (plan or bird's-eye, so the roofs of individual houses are visible)?
3. **Is it something other than a city** (text page, regional map, palace, landscape, costume plate,
   antiquarian reconstruction)?

## Files

| File | Content |
|---|---|
| `plate_classification.csv` | One row per plate. Columns `q1_more_than_one_city`, `q2_seen_from_above`, `q3_not_a_city` answer the three questions; `view_type`, `n_city_views`, `notes` give the detail; `usable_for_house_count` is a derived recommendation; `chiara_plate_type` / `chiara_include` is the current plate-quality layer from `Rscripts/Buringh_Match`; `cnn_total`, `cnn_houses`, `vit_total` are the DOMUS counts; `rumsey_cities` is the David Rumsey metadata. |
| `summary_s1.csv` … `summary_s10.csv` | The tables reproduced below. |
| `classification_raw.csv` | The raw calls (pipe-separated), keyed by the running index `k`. |
| `contact_sheets/sheet_01.jpg` … `sheet_41.jpg` | 9 plates per sheet, labelled with `k` and the filename, so every call can be checked against the image. `sheet_index.csv` maps `k` to file and sheet. |
| `make_sheets.py`, `merge_classification.R` | The scripts that produced the sheets and the merged table. |

## Coding scheme

`view_type`

- `plan_birdseye` – plan or oblique bird's-eye; individual roofs visible. `from_above = yes`.
- `oblique_distant` – elevated viewpoint but far away; roofs merge into texture. `from_above = partly`.
- `profile` – skyline seen from ground level or the water. `from_above = no`.
- `landscape` – town is a small element in a landscape (Hoefnagel's Spanish and Italian plates). `from_above = no`.
- `mixed` – several panels with different perspectives, or one city shown twice. `from_above = partly`.
- `none` – no city view at all.

`q3_not_a_city`: `yes` = nothing to count; `partly` = a city is present but the plate is dominated by
something else (castle, siege, palace elevation, genre scene).

`usable_for_house_count`: `yes` (single city, from above) · `after cropping` (multi-city) ·
`with caution` (single city, distant oblique or mixed) · `no` (profile, landscape, non-city).

## Results

**Q1 – more than one city.** 103 of 344 city plates (30 pct.) show two or more towns; 22 plates are
not city views at all. Multi-city plates carry 2–6 towns; the Swiss plate (k = 31) has 13.

| q1 | plates |
|---|---|
| no | 241 |
| yes | 103 |
| n/a (not a city) | 22 |

**Q2 – seen from above.**

| q2 | plates |
|---|---|
| yes (plan / bird's-eye) | 162 |
| partly (distant oblique or mixed) | 75 |
| no (profile / landscape) | 107 |
| n/a | 22 |

Crossed with Q1: **147 plates are a single city seen from above** – the clean cases. Only 15 multi-city
plates are fully from above; most multi-city plates are stacked profiles (52) or mixed (36).

**Q3 – not a city.** 30 plates (`yes`) plus 13 borderline (`partly`). The 30 are: 1 text page (Antwerp,
k = 263), 1 heraldic table (Hainaut, k = 139), 3 regional maps (Denmark, Øresund, Hven), 8 antiquarian
reconstructions (ancient Rome ×4 incl. Vol. II 49 and the composite, Ostia, Jerusalem-at-the-time-of-Christ
×3 incl. composite), 7 palaces/castles (Nonsuch, Caprarola, Escorial, St-Germain/Fontainebleau, Ambras,
Sáros, the Alhambra), 2 costume/figure plates (Dithmarschen, San Adrián), 1 event (St Mark's/palace fire), and 7 pure
landscapes (Baia, Agnano, Solfatara, Cádiz, Zirl, Kalwaria, Strait of Messina).

**Perspective drives the DOMUS count.** Among single-city, genuine city views:

| view_type | plates | median CNN total | median CNN houses |
|---|---|---|---|
| plan_birdseye | 139 | 1,394 | 1,258 |
| oblique_distant | 34 | 400 | 292 |
| profile | 22 | 305 | 208 |
| landscape | 27 | 227 | 170 |

A bird's-eye view yields roughly 4–6 times the count of a profile or landscape view of a comparable
town. This is the same pattern Chiara found in the repeated-view diagnostic (detailed vs distant ≈ 4×),
now visible across the whole atlas. Pooling view types in one regression mixes a measurement of the city
with a measurement of the engraver's viewpoint.

**Per volume** (genuine city views): Vol. III is the cleanest (37 of 55 plates are plans, mostly the
Van Deventer-derived Low Countries plans). Vol. V and VI (Hoefnagel's Spain/Italy, Central Europe) are
heavy on landscapes and distant obliques.

## Implications for the Buringh validation

1. **28 plates I mark `not a city` are currently `include_in_analysis = TRUE`** in
   `plate_quality_status_ANALYSIS_USED.csv` (`summary_s9.csv`). Most are `not_reviewed_assumed_city_view`.
   The costly ones are the reconstructions with large counts: ancient Rome (CNN 2,600–4,200) and
   Adrichom's Jerusalem (900–1,800) – both get matched to Buringh's Rome/Jerusalem if the name matcher
   fires. Vol. II 49 Rome (k = 106) is also a reconstruction and is currently `detailed_city_view`.
2. **99 multi-city plates carry the default `not_reviewed_assumed_city_view`** (`summary_s10.csv`).
   The crosswalk handles them by summing Buringh populations; the classification here gives the
   panel count needed to crop them into city-specific images instead.
3. **A `from_above` indicator (or the three-level `view_type`) should enter the regression**, either
   as a restriction to the 147 clean plates or as a fixed effect. Re-running the 1550 regression on the
   147 plates tests whether the pooled elasticity of 0.7 survives when viewpoint is held constant.
4. Two exact duplicates in the scan: Bardowick (k = 280 and 282) and the composite sheets for ancient
   Rome (231) and Jerusalem (236).

## Caveats

- Calls were made from ~560-px thumbnails. The `yes/no/partly` split for Q2 is robust at that scale;
  `oblique_distant` vs `plan_birdseye` is a judgement call for perhaps 15–20 plates. Check against the
  contact sheets before relying on a single plate.
- Town identifications in `notes` for the small Hoefnagel strips (k = 244–248, 261) and some German
  double plates (k = 208, 210, 271) are read from the cartouches and may be off; the filename and
  `rumsey_cities` columns are authoritative for names.
- Plate k = 334 (Polná) is a truncated JPEG in the source folder; the bottom of the image is missing.

## Log-log regression by view type (Buringh 1550)

`reg_by_view.R` re-runs Chiara's baseline regression (`regression_sample_BASELINE_COMPLETE_MULTICITY.csv`,
year 1550, `log_pop ~ log_total`) on subsets defined by the classification above. Output in
`loglog_by_view_type_1550.csv`, `loglog_view_type_FE_1550.csv`, `loglog_plan_vs_other_1550_cnn.png`.

| sample | model | n | slope | SE | R2 |
|---|---|---|---|---|---|
| Broad baseline (Chiara) | CNN | 251 | 0.58 | 0.07 | 0.20 |
| Drop non-city plates | CNN | 237 | 0.58 | 0.07 | 0.21 |
| Single-city, any view | CNN | 179 | 0.69 | 0.08 | 0.29 |
| **Single-city, plan/bird's-eye only** | **CNN** | **112** | **1.13** | **0.14** | **0.37** |
| Single-city, oblique distant only | CNN | 28 | 0.93 | 0.31 | 0.26 |
| Single-city, profile only | CNN | 19 | -0.37 | 0.47 | 0.04 |
| Single-city, plan/bird's-eye only | ViT | 112 | 1.25 | 0.15 | 0.38 |
| Single-city, profile only | ViT | 19 | -0.35 | 0.43 | 0.04 |

With view-type fixed effects on the 179 single-city plates the slope is 1.03 (CNN, SE 0.12) and
1.10 (ViT, SE 0.13). Restricted to plates seen from above, the elasticity of population with respect
to counted buildings is not distinguishable from 1; profile views carry no signal (n = 19).
