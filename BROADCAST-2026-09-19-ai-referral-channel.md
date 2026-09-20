# ทุกเว็บ: ChatGPT ส่งคนมา convert อยู่แล้ว 4.3% ของ bond ทั้งหมด — และทุกแถวถูกจัดเป็น `other_campaign`

จาก vth-biodent · แจ้งเพราะ `tsa_param` เป็นตารางกลาง + กติกา classifier ต้องตรงกันทุกแบรนด์ · DR-073 (เสนอ) · ต่อจาก DR-054/055

---

## เกิดอะไรขึ้น

Pillar 2 ของ protocol คือ "ให้ AI อ้างเรา" แต่ระบบวัดผลตอบไม่ได้ว่าเกิดขึ้นไหม — ทั้งที่มันเกิดขึ้นแล้วทั้งสองแบรนด์ อ่านจาก `tsa_bond.utm->>'utm_source'` เมื่อ 2026-09-19:

```
deezy   1,771 bonds · จาก ChatGPT 77 (28 วันล่าสุด 55) = 4.3% · โทร 3 · อยู่ใน other_campaign ทั้ง 77 = 100% ของ bucket นั้น   ← คิวคุณ
vth        70 bonds · จาก ChatGPT  3                    = 4.3% · อยู่ใน other_campaign
```

**ทำไมมองไม่เห็น:** ChatGPT ต่อ `?utm_source=chatgpt.com` (ไม่มี medium) ท้ายทุกลิงก์ที่มันอ้าง · `classifyChannel` เห็น "source ที่ไม่รู้จัก ไม่มี medium" → `other_campaign` · `classifySource` เห็น tag ที่ไม่รู้จัก → `other` · ลิงก์ที่เปิดจากแอป ChatGPT ไม่มี referrer เลย tag จึงเป็นสัญญาณเดียวที่มี · GA4 เองจัดเป็น channel "AI Assistant" อยู่แล้ว snapshot ของเราเถียง GA4 ทุกแถว

กับดักที่สอง: `gemini.google.com` ตรง regex search-host (`google\.`) → รายงานเป็น **organic Google** (vth: 6 session) — ของ deezy ก็ regex เดียวกันที่ `TsaSignals.astro:113`

## มติที่เสนอ (DR-073 — ฉบับเต็มอยู่ที่ `eywa-vth-biodent/docs/proposed-protocol-changes/DR-073-ai-referral-channel.md`)

1. **`entry_channel` เพิ่ม 1 ค่า: `ai_referral`** — มาจาก AI assistant แบบไม่จ่ายเงิน วางคู่ `organic_search` ในทุกรายงาน
   สงวนไว้ยังไม่เพิ่ม: `paid_ai` — medium ที่บอกว่าจ่าย + source เป็น AI → ลง `other_campaign` (เห็นอยู่ ไม่ปนกับ paid_search และไม่ปนกับ ai_referral)
2. **`entry_source` เพิ่ม 5 ค่า: `chatgpt` `perplexity` `gemini` `copilot` `claude`** — ปิดเหมือนเดิม ตัวที่ไม่อยู่ในลิสต์ = `other` จนกว่า `tsa_param` จะบอก · ชื่อตาม `seo_ai_platforms` ในสคีมา
3. **ลำดับใน classifier:** gclid → **tag เป็น AI + medium ไม่ใช่ paid → `ai_referral`** → medium block (เพิ่ม: paid + AI source → `other_campaign`) → referrer: internal → **AI host → `ai_referral`** → search host → social host → referral · **AI ต้องมาก่อน search host ไม่งั้น gemini เป็น google**
4. **GTM ไม่ต้องแตะ** — param เดิม tag เดิม ค่าใหม่ไหลผ่านได้เลย ไม่ต้อง publish container ไม่ต้องลงทะเบียน dimension (deezy ยังไม่ส่ง `entry_source` ก็ไม่เป็นไร `ai_referral` บน `entry_channel` พอสำหรับข้อนี้)
5. DNI: `ai_referral` ไม่มีเบอร์ของตัวเอง ตกเบอร์แบรนด์เหมือน `direct`

## สิ่งที่ vth ทำแล้ว — ใช้เป็นต้นแบบ

- `web/src/lib/channel.ts` — AI_HOSTS + alias table + ลำดับตามข้อ 3 · **tests 52/52** รวม case `utm_source=chatgpt.com` ไม่มี medium / ไม่มี referrer, `gemini.google.com` ต้องไม่เป็น google, paid+AI ต้องเป็น `other_campaign`
- ยังไม่ deploy — รอ `tsa_param` เปลี่ยนก่อน จะได้ขึ้นพร้อมกันทั้งสองแบรนด์

## สิ่งที่ต้องทำ

**Operator (ครั้งเดียว ตารางกลาง):**
```sql
update tsa_param
   set allowed_values = allowed_values || '["chatgpt","perplexity","gemini","copilot","claude"]'::jsonb
 where param_name = 'entry_source' and not allowed_values ? 'chatgpt';

update tsa_param
   set allowed_values = '["paid_search","paid_social","organic_search","organic_social","email","affiliate","display","referral","other_campaign","direct","internal","ai_referral"]'::jsonb
 where param_name = 'entry_channel' and allowed_values is null;
```

**deezy:** แก้ `classifyChannel` ใน `TsaSignals.astro` ให้ตรงข้อ 3 (หรือย้ายไป lib + test แบบ vth) · alias: `chatgpt.com` `chatgpt` `openai` `chat.openai.com` → chatgpt · `perplexity.ai` `perplexity` → perplexity · `gemini.google.com` `gemini` `bard` → gemini · `copilot.microsoft.com` `copilot` → copilot · `claude.ai` `claude` `anthropic` → claude · host: `chatgpt.com` / `chat.openai.com` · `*.perplexity.ai` · `gemini.google.com` / `bard.google.com` · `copilot.microsoft.com` · `claude.ai` (`bing.com` ยังเป็น search)

**ทางเลือก — แก้ประวัติครั้งเดียว** (deterministic จากคอลัมน์ที่เก็บไว้ รันหลัง deploy classifier):
```sql
update tsa_bond
   set entry_channel = 'ai_referral',
       entry_source  = case
         when utm->>'utm_source' in ('chatgpt.com','chatgpt','openai','chat.openai.com') then 'chatgpt'
         when utm->>'utm_source' in ('perplexity.ai','perplexity')                        then 'perplexity'
         when utm->>'utm_source' in ('gemini.google.com','gemini','bard')                 then 'gemini'
         when utm->>'utm_source' in ('copilot.microsoft.com','copilot')                   then 'copilot'
         when utm->>'utm_source' in ('claude.ai','claude','anthropic')                    then 'claude'
         else entry_source end
 where brand_id = 'deezy-dental'   -- หรือ 'vth-biodent'
   and entry_channel = 'other_campaign'
   and lower(utm->>'utm_source') in ('chatgpt.com','chatgpt','openai','chat.openai.com','perplexity.ai','perplexity','gemini.google.com','gemini','bard','copilot.microsoft.com','copilot','claude.ai','claude','anthropic')
   and coalesce(utm->>'utm_medium','') !~* '^(cpc|ppc|paid|paidsearch|paid_search|paid-search|ppc_ads)$';
```
GA4 ย้อนหลังแก้ไม่ได้ นับจาก deploy ไปสองฝั่งจะตรงกัน

## ทำไมต้องเป็นมติกลาง

`tsa_param` เป็นตารางเดียวของ federation — ค่าที่แบรนด์หนึ่งส่งแต่ตารางไม่รู้จัก = ตกเกต vocabulary ของแบรนด์นั้น · ค่าที่ตารางรู้จักแต่อีกแบรนด์ไม่เคยส่ง = channel เดียวกันอ่านเป็นศูนย์ที่นั่น · ต้องรันกติกาเดียวกัน ไม่งั้นรายงานข้ามแบรนด์เทียบ "AI ส่งมา" คนละนิยาม

## ถัดไป (ไม่อยู่ใน DR นี้)

เมื่อ channel อ่านได้ ฝั่ง AI ของ Pillar 2 วัดได้ 3 ชั้น ถูกสุดก่อน: (1) Worker บันทึก fetch จาก `ChatGPT-User` / `Perplexity-User` / `Claude-User` รายหน้า = citation event ตัวจริง ฟรี · (2) DR นี้ — ส่งคนมาไหม convert ไหม จากหน้า/cluster ไหน · (3) prompt probing ลงตาราง `seo_llm_query_simulations` / `seo_llm_citations` ที่ deploy ไว้แล้วแต่ว่าง = KPI #8/#11 ตรง ๆ · vth จะแจ้งแยกเมื่อชั้น 1 ขึ้น
