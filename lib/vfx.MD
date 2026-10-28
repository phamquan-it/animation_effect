Game turn-based (đối kháng theo lượt kiểu võ lâm, pokemon, FF, Dragon Quest) thường **rất cần VFX** vì gameplay chậm — VFX chính là thứ "gánh" cảm giác đã tay. Dưới đây là danh sách VFX nên có, chia theo **mức độ ưu tiên**:

---

## 🔥 Bắt buộc phải có (core VFX)

| VFX | Mô tả | Ghi chú |
|---|---|---|
| **Damage number** | Số sát thương bay lên ✅ đã làm | Máu, crit, hồi máu |
| **Hit spark** | Tia lửa/đốm sáng nổ ra tại điểm trúng đòn | 3–5 frame, cực ngắn |
| **Skill cast** | Hiệu ứng khi nhân vật chuẩn bị ra chiêu | Vòng tròn ma pháp, aura |
| **Skill impact** | Hiệu ứng khi chiêu đánh trúng | Nổ, chém, băng, sét... |
| **Turn indicator** | Con trỏ/dấu hiệu biết ai đang tới lượt | Mũi tên nhấp nhô, vòng sáng |
| **HP/MP bar change** | Thanh máu tụt mượt, đổi màu khi thấp | Kèm shake nhẹ |
| **Target selection** | Vòng tròn/khung dưới chân nhân vật được chọn | Nhấp nhô, xoay |

---

## ⚔️ VFX theo hành động combat

| VFX | Khi nào dùng | Kiểu |
|---|---|---|
| **Slash** | Chém thường | Vệt chéo trắng/xanh |
| **Impact ring** | Đòn đánh trúng | Vòng tròn lan ra |
| **Screen shake** | Đòn mạnh / crit | Rung màn hình 100–200ms |
| **Hit stop** | Đòn nặng | Đóng băng 50–100ms |
| **Slow-mo** | Đòn kết liễu | Time scale 0.3x |
| **Camera zoom** | Skill đặc biệt | Zoom vào target |
| **Camera pan** | Đổi mục tiêu | Di chuyển mượt |
| **Flash trắng** | Đòn chí mạng | Cả màn hình chớp trắng 50ms |
| **Vignette đỏ** | Nhân vật bị thương nặng | Viền đỏ mờ dần |
| **Knockback** | Đòn đẩy lùi | Nhân vật bị đẩy ra sau |
| **Hit combo** | Đòn liên hoàn | Số combo to dần |

---

## ✨ VFX theo kỹ năng / element

| Element | VFX gợi ý |
|---|---|
| **Hỏa** | Lửa cháy, tia lửa, khói đen, chữ số đỏ |
| **Thủy/Băng** | Tinh thể băng, sương mù, chữ số xanh |
| **Lôi** | Tia sét, flash trắng, chữ số vàng chói |
| **Phong** | Lốc xoáy, lá bay, chữ số xanh lá |
| **Thổ** | Đá nứt, bụi mù, chữ số nâu |
| **Độc** | Bong bóng tím, giọt độc, chữ số tím |
| **Quang** | Hào quang trắng/vàng, chữ số trắng |
| **Ám** | Bóng đen, khói tím đen, chữ số đen |

---

## 🎬 VFX cho lượt (turn flow)

| VFX | Mục đích |
|---|---|
| **Turn banner** | Chữ "LƯỢT CỦA BẠN" / "ENEMY TURN" trượt vào |
| **Turn order bar** | Dãy avatar thứ tự hành động, nhấp nhô ai tới lượt |
| **Countdown timer** | Vòng tròn đếm ngược khi chọn chiêu |
| **Action menu pop** | Menu chiêu bay lên từ dưới |
| **Skill icon glow** | Icon chiêu phát sáng khi hover/chọn |
| **Skill cooldown sweep** | Vòng xám quét qua icon khi đang hồi |
| **Buff/debuff icon** | Icon nhỏ trên đầu nhân vật, nhấp nhô |
| **Turn transition** | Chuyển lượt: fade đen, quét ngang |

---

## 💀 VFX khi thắng/thua

| VFX | Mô tả |
|---|---|
| **Victory pose** | Nhân vật giơ tay, hiệu ứng hào quang |
| **Defeat fade** | Nhân vật quỳ, mờ dần, ngã |
| **Reward explosion** | Vàng/rương nổ ra |
| **EXP gain** | Số EXP bay lên + thanh EXP đầy dần |
| **Level up** | Cột sáng, hào quang, chữ "LEVEL UP!" |
| **Loot drop** | Item rơi ra với trail |
| **Rank reveal** | Chữ S/A/B/C hiện từ từ |
| **Star rating** | Sao bay vào từng cái 1 |
| **Confetti** | Giấy màu khi thắng lớn |
| **Screen flash** | Chớp trắng khi thắng |

---

## 🎯 VFX đặc biệt nên có để "chất"

| VFX | Đặc điểm |
|---|---|
| **Critical hit** | Slow-mo + zoom + flash trắng + damage to + shake |
| **Ultimate / Limit Break** | Cutscene mini: background đổi, nhân vật pose, chữ to |
| **Combo counter** | Số combo tăng dần góc màn hình |
| **Perfect dodge** | Nhân vật mờ + để lại afterimage |
| **Counter attack** | Chớp sáng + phản đòn tự động |
| **Chain skill** | 2 nhân vật đánh liên tiếp, kết nối bằng vệt sáng |
| **Summon** | Vòng triệu hồi, tia sáng từ đất |
| **Status effect** | Icon nhấp nhô + hiệu ứng bao quanh nhân vật |
| **Death** | Nhân vật tan thành hạt, biến mất |
| **Revive** | Cột sáng, nhân vật từ từ đứng dậy |

---

## 📊 Ưu tiên triển khai (theo phase)

### Phase 1 — MVP (chơi được)
- ✅ Damage number
- ✅ Hit spark
- ✅ Turn indicator
- ✅ HP bar animation
- ✅ Target selection

### Phase 2 — Cảm giác đã tay
- Screen shake
- Hit stop
- Skill impact
- Slash effect
- Flash trắng khi crit

### Phase 3 — Đẹp
- Skill cast aura
- Particle element (lửa, băng, sét)
- Buff/debuff icon
- Victory / defeat animation
- Level up

### Phase 4 — "Chất" như võ lâm
- Ultimate cutscene
- Combo counter
- Camera zoom / pan
- Slow-mo
- Afterimage (perfect dodge)
- Rank / star reveal

---

## 🛠 Gợi ý dùng trong Flutter

| VFX | Cách làm |
|---|---|
| Damage number | ✅ Đã làm — `DamageNumber` |
| Sunburst | ✅ Đã làm — `SunburstAura` |
| Triple arrow | ✅ Đã làm — `TripleArrowDash` |
| Screen shake | `Transform.translate` với `sin(t * freq)` |
| Hit stop | `AnimationController` pause toàn cục |
| Slow-mo | `timeScale` — dùng `Ticker` chung |
| Flash trắng | `Container(color: Colors.white.withOpacity(t))` |
| Vignette | `RadialGradient` viền đỏ |
| Particle | `CustomPainter` + list particle |
| Trail | `CustomPainter` lưu lịch sử vị trí |
| Camera zoom | `Transform.scale` cả Stack |
| Camera pan | `Transform.translate` cả Stack |
| Afterimage | Vẽ nhiều bản sao mờ với delay |
| Loot drop | Parabolic motion + gravity |
| Confetti | `confetti` package |

---

## 🎨 Cấu trúc thư mục gợi ý

```
lib/
└── vfx/
    ├── damage/
    │   ├── damage_number.dart
    │   └── damage_text_style.dart
    ├── impact/
    │   ├── hit_spark.dart
    │   ├── impact_ring.dart
    │   └── slash_effect.dart
    ├── aura/
    │   ├── sunburst_aura.dart
    │   └── sunburst_painter.dart
    ├── camera/
    │   ├── screen_shake.dart
    │   └── camera_controller.dart
    ├── screen/
    │   ├── flash_overlay.dart
    │   └── vignette_overlay.dart
    ├── turn/
    │   ├── turn_banner.dart
    │   └── turn_indicator.dart
    ├── skill/
    │   ├── skill_cast.dart
    │   └── skill_impact.dart
    ├── reward/
    │   ├── level_up.dart
    │   └── loot_drop.dart
    └── vfx_manager.dart
```

---

## 💡 Mẹo phối hợp VFX cho "combo ảo ma"

Một đòn **crit chí mạng** nên có **5 lớp VFX chồng nhau** để tạo cảm giác nặng đô:

1. **Hit stop** 80ms — đóng băng mọi thứ
2. **Screen shake** mạnh 150ms
3. **Flash trắng** 50ms
4. **Sunburst** nổ tại điểm trúng
5. **Damage number** crit to gấp đôi, style `crit`
6. **Slow-mo** 200ms sau đó
7. **Camera zoom** nhẹ vào target

Cả 7 lớp chạy **cùng lúc hoặc lệch vài chục ms** → cảm giác "đấm 1 phát trời long đất lở".

---

Bạn muốn mình viết VFX nào tiếp theo? Mình gợi ý làm **`VfxManager`** trước — để gom tất cả lại, sau đó thêm dần từng VFX con vào dễ hơn. Hoặc bạn chọn cụ thể:

- **Hit spark** (nổ tia lửa)
- **Screen shake** (rung màn hình)
- **Slash effect** (vệt chém)
- **Turn indicator** (mũi tên nhấp nhô)
- **Level up** (cột sáng)
- **Combo counter** (số combo)