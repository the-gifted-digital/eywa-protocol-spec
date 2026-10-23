# W38 · target keyword binding report (2026-10-23)

Migration: `2026-10-23_w38_target_keyword_binding.sql` (DRAFT, not applied). Scope: Live pages (`status not in ('Merged','Dropped')`) with `target_keyword_fp is null` in 4 brands: 446 pages.

Dry run against production on 2026-10-23 (read-only): all 139 pages exist, are Live and unbound. No chosen keyword is a target or semantic keyword of another page in its brand, and none is `excluded`. 76 keywords reuse registry rows and 63 are new rows (GSC queries or DataForSEO). `v_page_keyword_conflicts` = 0 for the 4 brands before the run.

| Brand | Unbound | Bound by W38 | No target needed | Cannibal | Keyword-research gap |
|---|---|---|---|---|---|
| vitalsleep-clinic | 69 | 22 | 33 | 12 | 2 |
| clearisma | 89 | 15 | 53 | 21 | 0 |
| tc-smile-dental | 123 | 52 | 26 | 39 | 6 |
| the-face-by-vertex | 165 | 50 | 105 | 7 | 3 |
| **Total** | **446** | **139** | **217** | **79** | **11** |

The keyword and source for each bound page are in the migration's VALUES list. Sources were checked in this order: `gsc` (the page's own query, last 90 days), `gsc-sibling` (the query shows up on a sibling page), `registry`, then `dfs` (Google Ads volume, TH/th).

Semantic keywords were not touched. Several best-fit keywords were not available because another page holds them as a **semantic** keyword, for example VitalSleep `ผ่าตัดนอนกรน`, `คลินิกนอนกรน`, `รักษานอนกรน` and `อาการนอนไหลตาย`. When semantics are re-allocated, these can go to the target pages named below.

---

## Cannibal cases (operator decision)

In each case the intent is already held by another page. The holder kept the keyword and no second keyword was forced onto the page. The usual options are: merge or 301 into the holder, re-angle the content, or swap which page holds the keyword.

### vitalsleep-clinic (12)
| Page | Competes for | Holder |
|---|---|---|
| CPAP-snoring-obstructive-sleepapnea2 | รักษานอนกรน | snoringclinc-osa (W38: รักษาโรคนอนกรน) |
| osa-sudden-death-sleep-test | กรนหยุดหายใจ | snoring-treatment-cpap |
| sunds-obstructive-sleep-apnea-snoring | ใหลตาย | suds-sudden-unexpected-death-syndrome-sudden-death |
| sudden-unexplained-nocturnal-death-syndrome | ใหลตาย / โรคใหลตาย | suds-sudden-unexpected-death-syndrome-sudden-death |
| occlusal-splint-snoring-obstructive-sleep-apnea | occlusal splint / ที่ครอบฟัน แก้กรน | occlusal-splint-obstructive-sleep-apnea-mandibular-advancement-device |
| snoring-cpap-rf-bot-oral-appliance | รักษาโรคนอนกรน | snoringclinc-osa |
| snoring-erectile-dysfunction-health | นอนกรน + สมรรถภาพทางเพศ | snore-erectile-dysfunction |
| snoring-health-care-non-surgery | แก้นอนกรน แบบไม่ผ่าตัด | snoring-treatment-cpap/snoring-non-surgery |
| snoring-treatment-healthcare | แก้นอนกรน แบบไม่ผ่าตัด | snoring-treatment-cpap/snoring-non-surgery |
| tips-snoring-new-years-gift | วิธีแก้นอนกรน | how-to-stop-snoring |
| snoring-sleep-test-myofunctional-therapy | แก้นอนกรน | snoring-solutions-anti-snoring-devices-products-for-snoring |
| snoring-therapy-myofunctional-therapy | myofunctional therapy | myofuction-therapy / snoring-myofunctional-therapy-health |

The ใหลตาย cluster has 8 Live pages. The 3 holders (`suds-…`, `sleepdead-…`, `sleep-sleep-apnea-sunds`) plus 2 W38 binds (cause angle, symptom angle) leave 2 cannibals. Consolidating the cluster is recommended.

### clearisma (21)
The site has about 60 blog posts on one topic. Most of the posts that are not reviews repeat an intent that is already held.

| Page | Competes for | Holder |
|---|---|---|
| what-clearisma | จัดฟันใส (GSC "จัด ฟัน ใส" lands here) | clear-aligner (pillar, W38) |
| aligner-faster-braces | จัดฟันใส กี่เดือน | aligner-wear-hours |
| aligner-good-price | จัดฟันใสราคาถูก | price-of-clearisma (W38: จัดฟันใส ราคาไม่แพง) |
| aligner-price-confident | จัดฟันใส ราคา | cost-pay-installment |
| aligner-price-prepare | จัดฟันครั้งแรกกี่บาท | clearaligner-first-orthodontist |
| aligner-good-results · clearaligner-dentals-clinic · clearisma-dental-2024 | จัดฟันใสที่ไหนดี | where-aligner-good |
| aligner-near-me · dental-promotion-clinic | จัดฟันใสใกล้ฉัน | aligner-online-orthodontic-inexpensive |
| clear-aligner-convenient · clinic-bangkok-dental | จัดฟันใส กรุงเทพ | clear-aligner-bkk |
| aligner-round-2 · clear-aligner-2 · dental-care-clear-braces-clear-aliner | จัดฟันรอบสอง | clearaligner-orthodontic-inexpensive |
| beauti-easy-aliner | จัดฟันใส ดีไหม | clearaligner-best-choice (W38) |
| dental-overlapping-teeth | ฟันเก | aligner-crowded-teeth |
| nemo-smile-healtcare-aligner · step-clear-aligner | ขั้นตอนการจัดฟัน | first-braces-preparation |
| types-braces-lifestyle · step-review-retainer-monitor | จัดฟันมีกี่แบบ | types-of-braces |

### tc-smile-dental (39)
| Page | Competes for | Holder |
|---|---|---|
| adult-orthodontics-dental · clear-aligner-adult · clinic-braces-adult | การจัดฟันผู้ใหญ่ / คลินิกจัดฟันที่ไหนดี | braces-working-age / orthodontic-braces-dental (W38) |
| aligner-smart-clear-tooth-extraction | จัดฟัน(ใส)ต้องถอนฟันไหม | braces-tooth-extraction (W38, stronger GSC) |
| all-on-4-dental-implants · allon4-senior-dental · allon4-vs-dentures | all on 4 | dental-implant-digital/dental-implants-all-on-4-dental (W38) |
| artificial-teeth-tooth-dental-implant · implant-cheap-risk · implants-ecomonical-price · lowcost-implant-difference | รากฟันเทียมราคาถูก/ประหยัด | dental-implant-cheap (W38) / review-dental-implants |
| implant-dental-tooth · dental-implant-cost-2 · implant-value-longevity | ราคารากฟันเทียม | dental-implant-cost (implant-dental-tooth ranks p2 for "รากฟันเทียม ราคา": consider a swap) |
| dental-implant-tooth · dental-implants-tooth-beautiful-teeth · implants-confident-smile · implant-false-teeth-tooth | รากฟันเทียม / ข้อดี | dental-implant-digital, implant-5-benefits (W38) |
| clear-aligner-busy · clear-aligner-invisalign-orthodontic | จัดฟันแบบใส | smart-clear-brace |
| clear-aligner-cost | จัดฟันใส ราคา | price-dental-clear-aligner |
| dental-care-tooth-beautiful | จัดฟันมีกี่แบบ | types-braces-suitable |
| crown-dental-good · dental-crown-tooth | ครอบฟัน | crown (W38) |
| denture-jawbone-chewing | กระดูกขากรรไกรละลาย | implant-support-jawbone (W38) |
| dentures-vs-implant | ฟันปลอม ราคา | denture-false-teeth |
| lingual-braces-adult · teeth-braces-lingual | lingual คือ / จัดฟันข้างใน | what-lingual-braces / lingual-braces-good |
| lingual-braces-tooth-beautiful | Brava by Brius | brava-by-brius (W38) |
| root-canal-treatment-teeth-tooth-root | รักษารากฟันราคา | price-dental-root-canal-treatments |
| veneer-beautiful-teeth · veneer-teeth-beautiful | ทำฟันวีเนียร์ | veneers-beautiful-working |
| veneer-cheap-expensive · veneers-price-beauty | วีเนียร์ราคา | veneer-teeth-beautiful-2 (veneers-price-beauty ranks p4: consider a swap) |
| veneer-cheap-risk | ทำวีเนียร์ราคาถูก | veneer-cheap-price (W38) |
| veneer-crown-tooth | ครอบฟัน vs วีเนียร์ | crown-vs-veneer |
| veneer-smile-celebrity | ฟันดารา | veneer-celebrity-5stories |
| where-best-veneer | ทำวีเนียร์ที่ไหนดี | veneer-smile-natural (W38, has GSC) |
| composite-veneer (service) | วีเนียร์คอมโพสิต | composite-veneers-price (blog: service page lost the head) |

### the-face-by-vertex (7)
| Page | Competes for | Holder |
|---|---|---|
| face-lift-product | emface | emface-facial-lifting |
| nemotec-angle-reduction-3d-computer | ตัดกราม / nemotec v | facial-surgery/angle-reduction, jaw-surgery/nemotec-v |
| veneer-teeth-dental | veneer ราคา | promotion-veneer |
| dental-center/airflow · dental-center/gbt-airflow (services) | ขูดหินปูน air flow | air-flow-tooth-dental (blog) |
| dental-center/nemo-smile-veneer-dsd | ออกแบบรอยยิ้ม | facial-smile-design (W38, 10 vs 5 imp) |
| facial-surgery/v-line-angle-reduction | v line / วีไลน์ | facial-surgery/v-line-facial-surgery-face-design, …/v-line-chin-surgery-jaw-angle-reduction |

**Pattern to raise with the operator:** in TC and TFV, service pages lost their head term to blog posts. Examples are TC `composite-veneer`, `lingual-braces-lingual-orthodontics` and `biolux-active`, and TFV `dental-center/airflow`. A swap in which the service takes the head and the blog takes an angle needs an operator call. That is not done here.

---

## Keyword-research gaps (11)

DataForSEO (Google Ads, TH/th, 2026-10-23) returned no volume for any seed. The registry and GSC had nothing usable either.

| Brand | Page | Seeds tried |
|---|---|---|
| vitalsleep-clinic | sleep-apnea-cancer | หยุดหายใจขณะหลับ มะเร็ง, นอนกรน มะเร็ง, นอนกรนเสี่ยงมะเร็ง |
| vitalsleep-clinic | services/exosella-exomind-emsella | exosella (proprietary program name) |
| tc-smile-dental | crowns-material-effect | วัสดุครอบฟัน, ครอบฟัน วัสดุ |
| tc-smile-dental | implant-age-face | ฟันหาย หน้าแก่, สูญเสียฟัน หน้าแก่ |
| tc-smile-dental | implant-tooth-old | รากฟันเทียม ผู้สูงอายุ, รากฟันเทียมผู้สูงอายุ |
| tc-smile-dental | invisalign-teeth-orthodontics | จัดฟันใส ข้อจำกัด, ข้อจำกัดจัดฟันใส |
| tc-smile-dental | nano-tmj | nano tmj |
| tc-smile-dental | dental-implants-intra-lock | intra lock implant |
| the-face-by-vertex | 5-types-of-jaw-surgeries | ผ่าตัดขากรรไกร มีกี่แบบ / มีกี่วิธี |
| the-face-by-vertex | face-surgery/rhinoplasty-nose-surgery-v-active-nose | แก้จมูก, เสริมจมูก v active |
| the-face-by-vertex | jaw-surgery/invisible-pins-orthognatic-surgery-maxillary | หมุดละลาย |

---

## No target needed (217)

| Reason | vitalsleep-clinic | clearisma | tc-smile-dental | the-face-by-vertex |
|---|---|---|---|---|
| Doctor profile / team listing | team/* (7), our-teams, physician, specialists-osa-snoring | — | — | 16 `หมอ*` pages, our-dentist, our-doctor |
| Review / testimonial / before-after | review, review-health-snore, review-home-sleep-test, review-obstructive-sleep-apnea-snoring-1/-2, review-radiofrequency-snoring, review-sleep-test-cpap-boomtharis, review-sleeptest-sleepstudy-polysomnography, review-snoring-jaw-surgery | 38 (all `review-*`, `*-review*`, `case-review-*`, `real-case-*`, smile-review-dent, review, customers) | review-all, before-after, dental-implants-review, 8 `review-*` | 47 (`review-*`, `reviews-*`, `review-before-after*`, angle-reduction-genioplasty-review, angle-reduction-v-active-nose-genioplasty-buccal-fat-pad, cosmetic-surgery-review-big-jaw-angle, jaw-cut-jaw-angle-surgery-review, letmein-thailand-jaw-surgery-face-surgery-review) |
| Promotion | promotion, promotions, promotion-myofunctuional-therapy, promotion-oral-appliance, promotion-rf-bot | google-campaign | promotions, promotion-dental-implants, promotion-gbt, promotion-veneer | price-promotion, promotion-gbt, veneer-dental-promotion |
| News / event / lecture / TV (Let Me In) | imcas-asia-2026, synergy-x-longevity | — | — | 28 (6 `*-letmein*`, let-me-in-thailand-season-3/-4, ืnews-let-me-in-season-4, supermum-news, plus 18 lecture/award/event posts) |
| Policy / legal | cookie-policy, privacy-policy, terms | cookie-policy, pdpa-term, pdpa-user-privacy, privacy-policy-2, terms | cookie-policy, privacy-policy, terms | cookie-policy, privacy-policy, privacy-policy-2, terms |
| Contact / about / brand-nav | contactvitalsleep, snoringosa-snoringclinic | contact-us, how-to-use-clearisma, why-clearisma | about, contact | contact-us |
| Hub / listing | blogs, news | blog-news | blog-new | articles, content-dental, news |
| Opt-in / thank-you / test | — | opt-in, blog-opt-in, review-opt-in, blog-thankyoupage, thankyou-page | tc-smile-opt-in, tcsmile-blog-opt-in, tcsmile-home-opt-in, thank-you-page, test-wpml | opt-in |

Classification notes. Clearisma `doctor-aligner-clear-review` is classed as a review by its slug, but its title reads as an article. TFV `veneer-dental-promotion` is classed as a promotion by its slug, but it is a knowledge article. Reclassify either page if the content is not what the slug says.

---

## Near-duplicate notes (Q9: explanations per pair, do not auto-fix)

- TC `จัดฟันคลินิกไหนดี` (orthodontic-braces-dental) and `จัดฟันกทมที่ไหนดี` (orthodontics-bangkok-adult): the second has a Bangkok qualifier.
- TC `รากฟันเทียมราคาถูก`, `รากฟันเทียมราคาหลักพัน` and the existing `ราคารากฟันเทียม 1 ซี่`: cheap, thousand-baht and per-tooth angles (DR-048).
- TFV `โครงหน้าผู้ชาย` and `โครงหน้าผู้หญิง`: different audiences.
- TFV `vertex clinic` (home) and `vertex dental` (dental-center): both are brand-nav. Set `flag_review` to `brand-nav` if Q6 flags them.
- Clearisma `จัดฟันใส มีกี่แบบ` and the existing `จัดฟันมีกี่แบบ`: aligner-only angle.

## After applying

```sql
select refresh_keyword_near_pairs(); select refresh_page_priority();
select * from v_page_keyword_conflicts where brand_id in ('the-face-by-vertex','tc-smile-dental','clearisma','vitalsleep-clinic'); -- expect 0
```
