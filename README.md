# 🛡️ Belang – Safe Language Exchange App (Flutter)

**Belang** is a privacy-first, AI-enhanced language exchange app designed to protect users from unwanted flirtation, harassment, and grooming through layered, adaptive moderation.  
It blends fast, familiar messaging UI with innovative real-time safety features using lightweight on-device AI.

---

## 🌟 Features

- 🌍 **Multilingual Chat** – Connect with users globally
- 🧠 **On-device AI Moderation** – Real-time, private message safety checks
- 🧾 **Regex + Light NLP Filters** – Blocks known inappropriate messages instantly
- ❤️ **Guardi AI** – Animated companion that monitors tone, enforces strikes, and responds to abuse
- ⬇️ **Dynamic Language Packs** – Only downloads models for the user’s chosen languages
- 🔐 **End-to-End Encrypted Messaging**
- 🚫 **Zero Tolerance System** – Escalates repeated violations to permanent bans

---

## 🧱 Tech Stack

- **Flutter** – UI + cross-platform logic
- **Firebase** or custom socket backend (configurable)
- **ONNX / TensorFlow Lite** – For local moderation model execution
- **SHA256 verification + tamper protection**
- **Optional cloud fallback** – Groq or OpenAI for advanced moderation

---

## 🛠️ Setup Instructions

1. **Clone the repository**

```bash
git clone https://github.com/SoufianeJm/lango.git
cd lango
