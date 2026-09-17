# BROADCAST 2026-09-17 — writer brief เป็นสคริปต์กลางแล้ว (DR-068)

**ถึง:** vth-biodent · deezy-dental (และแบรนด์ที่จะมาถัดไป) · **จาก:** smile-scape

## สิ่งที่เปลี่ยน

`npm run brief -- <fp>` (ใบสั่งงานต่อหน้าจาก DB) ไม่ใช่สคริปต์ที่แต่ละแบรนด์ถือสำเนาอีกต่อไป — สำเนาเดียวอยู่ที่

```
eywa-protocol-spec/scripts/writer-brief/page-brief.mjs        # รับ --brand <brand_id> · ไม่มี npm dependency
eywa-protocol-spec/scripts/writer-brief/brands/<brand_id>.json # ข้อยกเว้น/ข้อห้ามเฉพาะแบรนด์ (optional)
eywa-protocol-spec/scripts/writer-brief/README.md
```

รันจาก `web/` ของแบรนด์ (ให้สคริปต์เห็น `src/lib/template-keys.ts` + layouts สำหรับรายงาน "block ที่ไม่ render"):

```bash
cd web
node ../../eywa-protocol-spec/scripts/writer-brief/page-brief.mjs --brand vth-biodent vth-6.1.3
node ../../eywa-protocol-spec/scripts/writer-brief/page-brief.mjs --brand deezy-dental deezy-3.1 --write
```

## ทำไม

สามแบรนด์ สามสถานะ กับสิ่งที่ Pamrel §4 บอกว่าต้องมีเหมือนกัน: VTH มีสคริปต์ (hardcode `vth-`) · Deezy ไม่มี (เขียนมือจากเอกสาร) · smile-scape ไม่มีทั้งสคริปต์และเอกสาร — และ `NEW_BRAND_BOOTSTRAP` Step 5.5 สั่งให้คัดลอกไปแก้ 5 จุด "ไม่ปรับแล้วสคริปต์จะโกหกเงียบ ๆ" ซึ่งคือปัญหาเดียวกับที่ citation gates เจอก่อน 08-24 และแก้ด้วยการย้ายเข้า protocol พร้อม `--brand`

## สิ่งที่ brief เวอร์ชันกลางพ่นเพิ่มจากของ VTH

- `supports_claim` ของทุก citation ที่ผูกไว้ — ประโยคที่ผ่านการตรวจแล้วว่าหน้าพูดได้แค่ไหน (ของเดิมมีแค่ชื่อเปเปอร์)
- ลิงก์ contextual ขาออกพร้อม anchor/variant ที่วางแผนไว้ · anchor ขาเข้าที่ใช้อยู่
- entity ข้างเคียง · semantic keyword ที่ผูก (ตัวหนังสือ ไม่ใช่ fingerprint)
- ธงจาก marker ใน `reconciliation_notes`: `CITATION EXEMPTION` · `ENTITY GAP` · `[no-target: …]` · `ยุบเข้า`/`MERGED` · คำสั่ง `ห้าม` ของ operator
- `forbidden_topics` ต่อแบรนด์ — smile-scape ใส่ "บัตรทอง/ข้าราชการ" และ "ลดหย่อนภาษี" ไว้ (operator 2026-09-17)
- คำสั่งเกตกลาง 3 ตัวจาก `scripts/citation-gates/` ก่อน แล้วค่อยเกต npm ของแบรนด์ **เฉพาะที่มีจริงใน `package.json`**

## สิ่งที่แบรนด์ต้องทำ

| แบรนด์ | ทำอะไร |
|---|---|
| **vth-biodent** | รันเทียบ `vth-6.1.3` กับ `npm run brief` เดิม (smile-scape เทียบให้แล้ว — ต่างเฉพาะส่วนที่เพิ่ม) → เปลี่ยน `"brief"` ใน `web/package.json` ให้ชี้สคริปต์กลาง → ลบ `web/scripts/page-brief.mjs` · ตรวจ `brands/vth-biodent.json` (`local_sections` `^vth-9` ใส่ไว้ให้แล้ว) |
| **deezy-dental** | ได้ brief โดยไม่ต้อง port — เพิ่ม `"brief"` ใน `package.json` · ถ้ามีหัวข้อต้องห้าม/ข้อยกเว้น ใส่ `brands/deezy-dental.json` (ตอนนี้ `{}`) |
| ทุกแบรนด์ | เอกสาร 2 ไฟล์ (`CONTENT-WRITING-SOP.md` · `template-block-standards.md`) ยังเป็นของแบรนด์ตาม §4 — สคริปต์ไม่แทนเอกสาร |

## ข้อควรรู้

- แบรนด์ที่ยังไม่มี SERP snapshot (smile-scape 0 แถว) จะเห็นธง "ไม่มี SERP" ทุกหน้า — สภาพข้อมูล ไม่ใช่บั๊ก
- `MANIFEST.sha256` ยังไม่ครอบ `writer-brief/` — ฝากคนดูแล gates
- บั๊กที่เจอระหว่างวัน (คนละเรื่อง แต่แจ้งไว้): `scripts/entity-identity/embed-entities.mjs` ข้าม `entity_lifecycle='merged'` แต่ไม่ข้าม `'dropped'` → re-embed entity ที่ถูก drop กลับมา
