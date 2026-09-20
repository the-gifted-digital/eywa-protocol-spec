# ทุกเว็บ: ตาราง AI ใน protocol ตรงกับ DB แล้ว — 1 สร้างจริง · 4 ประกาศเลิก · 3 รอตัวเติม

จาก vth-biodent · operator สั่งให้ทำเอกสารให้ตรงความจริง "เพื่อไม่ให้เกิดคำถามซ้ำ" · Bible **v3.35** · Schema **v1.24** · Decision Records **v1.42** (DR-073/074/075)

---

## ทำไมต้องมีฉบับนี้

Bible v2.4 ประกาศ Category F ไว้ 5 ตาราง · Schema Overview นับ Group 7 ไว้ 4 · DB จริงมีอีกอย่าง · วันนี้ (2026-09-20) มีคนถามว่า "ตารางไหนต้องสร้างเพิ่ม/ลบ" — คำตอบไม่ควรต้องหาใหม่ทุกครั้ง ต่อไปนี้คือคำตอบเดียวในเอกสารทั้ง 3 ฉบับ

## สถานะจริง (ตรวจกับ `information_schema` 2026-09-20)

| ตาราง | ใน DB | สถานะ | ที่อยู่ของคำตอบ |
|---|---|---|---|
| `seo_ai_agent_visits` | ✅ | **สร้าง 2026-09-20 (DR-074)** — schema ลดจาก Table 32 เหลือที่ Worker เติมได้จริง | Bible Table 32 (นิยามใหม่) · Schema §9.5 |
| `seo_llm_query_simulations` | ✅ 0 แถว | ถูกต้อง รอ runner (prompt probing) | Bible Part 21 · Schema §9.3 |
| `seo_llm_citations` | ✅ 0 แถว | ถูกต้อง รอ runner | Schema §9.2 |
| `seo_brand_mentions` | ✅ 0 แถว | ถูกต้อง รอ runner (ครึ่ง AI) + monitor (ครึ่งเว็บ) | Schema §9.1 |
| `seo_entity_embeddings` | ✅ 701 | ใช้อยู่ (dedupe) | — |
| `seo_ai_platforms` | ❌ | **เลิก — ไม่เคยสร้าง ห้ามสร้าง** → `tsa_param.agent_platform` (13 ค่า, surface `server_only`) | DR-074 §2.2 |
| `seo_predicted_prompts` | ❌ | **เลิก** → `seo_llm_query_simulations` มี prompt bank อยู่แล้ว | DR-074 |
| `seo_ai_response_analysis` | ❌ | **เลิก** → คอลัมน์อยู่บน `seo_llm_citations` แล้ว | DR-074 |
| `seo_x_voice_search` | ❌ | **ไม่สร้าง** จนกว่าจะมี voice surface | Bible Table 33 |

## สิ่งที่แก้ในเอกสาร

- **Bible v3.35** — header + changelog · §1.8 pointer 3 จุด (`seo_ai_platforms` / `seo_ai_agent_visits` / `seo_predicted_prompts`) · Part 13 "Detect AI agents" = implemented · "Track everything" = กฎการอ่าน 2 ข้อ · หัวข้อ `seo_ai_response_analysis` / `seo_x_voice_search` ประทับสถานะ · Appendix แถว 29–33 + Table 29/30/31/33 ประทับ SUPERSEDED/NOT BUILT · **Table 32 = นิยามจริง** (ฉบับ v2.4 พับเก็บใน `<details>`) · KPI "Predicted Prompts coverage" ชี้ตารางที่มีจริง
- **Schema Overview v1.24** — Group 7 = 5 ตาราง · §9.5 ใหม่ (`seo_ai_agent_visits` + view) · changelog · base tables 43 → 44
- **Decision Records v1.42** — DR-073 (ai_referral) · DR-074 (retrieval log) · DR-075 (entry_referrer) เข้า ledger แล้ว พร้อม hash ทั้งสองแบรนด์

## กฎที่ตามมา (สำหรับทุก session)

1. "AI platform ไหน" มี registry เดียว = `tsa_param.agent_platform` · เพิ่ม platform = เพิ่มค่าในแถวนั้น แล้วเพิ่มกฎใน `web/worker/ai-agent.ts` ที่ vth-biodent ก่อน ส่ง hash ให้แบรนด์อื่น
2. `channel.ts` และ `ai-agent.ts` ของ vth-biodent เป็น reference implementation — port verbatim + header ระบุ hash + test ที่แดงเมื่อ drift (deezy ทำแล้ว c038191 / e174741 / 0be7110)
3. retrieval fetch = "ถูกอ่านเพื่อตอบ" ไม่ใช่ "ถูกอ้าง" — คำว่า cited เป็นของ `seo_llm_citations` เท่านั้น
4. ก่อนส่ง DDL ให้ operator: เช็ค `information_schema` ทุกชื่อคอลัมน์ที่อ้าง — วันนี้เสีย 2 รอบกับ `brand_scope` (text[] ไม่ใช่ jsonb) และ `primary_entity_fp`
5. (เพิ่มโดย deezy) สคริปต์ที่ step ใน `deploy.yml` เรียก ต้องมีอยู่**บน runner** ไม่ใช่แค่บนเครื่อง operator — path `../../../eywa-protocol-spec` ทำ deploy ของ deezy ล้ม 2 วัน (#566–#568) โดยไม่มีอะไรแดงนอกจาก Actions · แก้ = checkout `eywa-protocol-spec` เข้า `$GITHUB_WORKSPACE/spec` + ตั้ง `EYWA_SPEC` (vth `deploy-preview.yml` ตั้งแต่ 08-24, deezy `c0c0c78`) · แบรนด์ที่ copy step CI ของเราต้องเอา checkout นี้ไปด้วย

## ถัดไป (ยังไม่ทำ ไม่ใช่ schema)

runner สำหรับ prompt probing → เติม 3 ตารางที่ว่าง = KPI #8/#11 · รอ operator ตัดสินงบ API และขนาดคลัง prompt เริ่มต้น · จะออก DR แยกพร้อม schema ของ prompt bank ก่อนเขียนแถวแรก
