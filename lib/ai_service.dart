import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _apiKey = 'AIzaSyDvfS6bYHNSmkijwr9pLGK29gdlg41yCcM';
  static final GenerativeModel _model = GenerativeModel(
    model: 'gemini-3.1-flash-lite-preview',
    apiKey: _apiKey,
    systemInstruction: Content.system(
      'You are the AI Support Assistant for Dorm Link, a smart hostel management app tailored for students. '
      'Dorm Link helps students with: '
      '1. Splitting bills with roommates. '
      '2. Expense tracking. '
      '3. Group chats. '
      '4. AR-guided maintenance requests. '
      '5. Power and drain analyzers. '
      'Your goal is to be helpful, professional, and friendly to students. '
      'Answer questions about these features and help troubleshoot hostel-related issues (WiFi, Plumbing, Electrical, etc.) '
      'using the context of a smart hostel environment.',
    ),
    generationConfig: GenerationConfig(
      temperature: 0.7,
      topK: 40,
      topP: 0.95,
      maxOutputTokens: 1024,
    ),
  );

  /// Returns a response from the Gemini API.
  static Future<String> getResponse(
    List<Map<String, String>> conversationHistory,
    String userMessage,
  ) async {
    try {
      final history = conversationHistory.map((m) {
        final role = m['role'] == 'user' ? 'user' : 'model';
        return Content(role, [TextPart(m['content'] ?? '')]);
      }).toList();

      // The Gemini API requires alternating roles (user, model, user, model).
      // Since ChatService saves the user message to history BEFORE calling this,
      // the last message in 'history' is often the same 'userMessage'.
      // We must remove it from the history passed to startChat to avoid consecutive 'user' roles.
      if (history.isNotEmpty && history.last.role == 'user') {
        history.removeLast();
      }

      final chat = _model.startChat(history: history.isEmpty ? null : history);
      final response = await chat.sendMessage(Content.text(userMessage));
      return response.text ??
          'I am sorry, but I could not generate a response at this time.';
    } catch (e) {
      print('Gemini API Error: $e');
      // Fallback to local response if API fails
      return _getLocalResponse(userMessage);
    }
  }

  static String _getLocalResponse(String message) {
    final lower = message.toLowerCase();

    // ── Wi-Fi / Internet ──────────────────────────────────────────────
    if (lower.contains('wifi') ||
        lower.contains('wi-fi') ||
        lower.contains('internet') ||
        lower.contains('network')) {
      return '''I'm sorry to hear you're having Wi-Fi issues. Let's try to fix this:

**Troubleshooting Steps:**
1. Turn off Wi-Fi on your device, wait 10 seconds, then turn it back on
2. Forget the hostel network and reconnect using the password posted in your room
3. Restart your device completely
4. Try moving closer to the router (usually in the hallway)

**If the issue persists:**
- Check if other devices can connect — if not, the router may need a restart
- Visit the front desk so staff can reset the access point for your floor

**Urgency:** Medium
**Estimated Resolution:** 15–30 minutes

Is the issue resolved, or do you need further help?''';
    }

    // ── Plumbing / Tap / Leak ─────────────────────────────────────────
    if (lower.contains('tap') ||
        lower.contains('leak') ||
        lower.contains('water') ||
        lower.contains('plumb') ||
        lower.contains('bathroom') ||
        lower.contains('shower') ||
        lower.contains('drain')) {
      return '''I understand — plumbing issues need quick attention.

**Immediate Steps:**
1. If the tap is leaking, try turning it off firmly (don't over-tighten)
2. Place a towel or bucket under the leak to prevent water damage
3. If water is flooding, turn off the valve under the sink (rotate clockwise)

**What Happens Next:**
- A maintenance ticket has been logged as **High Priority**
- Our plumbing team will visit your room within **1–2 hours**
- If it's an emergency (flooding/burst pipe), please call the front desk immediately

**Urgency:** High
**Estimated Resolution:** 1–2 hours

Is there anything else I can help with?''';
    }

    // ── Air Conditioning / HVAC ───────────────────────────────────────
    if (lower.contains('air condition') ||
        lower.contains('ac') ||
        lower.contains('cold') ||
        lower.contains('hot') ||
        lower.contains('heat') ||
        lower.contains('cool') ||
        lower.contains('temperature')) {
      return '''Let me help you with the air conditioning.

**Quick Fixes:**
1. Check if the AC remote has working batteries
2. Set the temperature between 22–25°C for comfortable cooling
3. Make sure the AC vents are not blocked by furniture or curtains
4. Clean the filter if it looks dusty (slide it out from the front panel)

**If the AC is not responding at all:**
- Check if the circuit breaker for your room is switched on
- A maintenance request has been created for a technician visit

**Urgency:** Medium
**Estimated Resolution:** 2–4 hours (for technician visit)

Would you like to report anything else, or is this resolved?''';
    }

    // ── Washing Machine / Laundry ─────────────────────────────────────
    if (lower.contains('wash') ||
        lower.contains('laundry') ||
        lower.contains('dryer') ||
        lower.contains('machine')) {
      return '''Sorry to hear the washing machine isn't working properly.

**Troubleshooting Steps:**
1. Make sure the door is fully closed — most machines won't start if the door is ajar
2. Check that the water supply tap (behind the machine) is turned on
3. Don't overload — keep clothes below the max fill line
4. Try unplugging the machine for 30 seconds, then plug it back in

**If it still doesn't work:**
- Note the machine number and the error code (if displayed)
- A maintenance request has been logged
- In the meantime, you can use the machines on the other floor

**Urgency:** Low
**Estimated Resolution:** 4–8 hours

Is there anything else you need help with?''';
    }

    // ── Lost Key / Security ───────────────────────────────────────────
    if (lower.contains('key') ||
        lower.contains('lock') ||
        lower.contains('lost') ||
        lower.contains('security') ||
        lower.contains('door')) {
      return '''I understand — losing your room key can be stressful. Here's what to do:

**Immediate Steps:**
1. Go to the **front desk** with your ID — they can issue a temporary key
2. A replacement key will be prepared within **30 minutes**
3. There may be a small replacement fee (check with reception)

**Security Note:**
- Your old key/card will be **deactivated** immediately for safety
- If you suspect someone else has your key, inform the front desk right away
- Security will do an extra check on your floor tonight

**Urgency:** High
**Estimated Resolution:** 30 minutes

Is there anything else I can help with?''';
    }

    // ── Noise Complaint ───────────────────────────────────────────────
    if (lower.contains('noise') ||
        lower.contains('loud') ||
        lower.contains('complaint') ||
        lower.contains('party') ||
        lower.contains('music')) {
      return '''I'm sorry you're dealing with noise disturbance.

**What You Can Do:**
1. Politely ask your neighbours to lower the volume (if you feel comfortable)
2. If the noise continues, report it to the front desk — they'll send staff
3. Quiet hours are **10:00 PM – 7:00 AM** — violations are taken seriously

**What We'll Do:**
- A noise complaint has been logged with your room details
- Security will do a walk-through of your floor
- Repeated offenders will receive a formal warning

**Urgency:** Medium
**Estimated Resolution:** 15–30 minutes

Would you like to add anything else to this complaint?''';
    }

    // ── Electrical ────────────────────────────────────────────────────
    if (lower.contains('electric') ||
        lower.contains('power') ||
        lower.contains('light') ||
        lower.contains('socket') ||
        lower.contains('outlet')) {
      return '''Electrical issues need careful handling — please don't try to fix wiring yourself.

**Safe Steps:**
1. Check your room's circuit breaker (usually near the door) — flip it off and on
2. Try a different socket to see if the problem is with one outlet
3. If lights are flickering, turn them off and report it

**⚠️ Safety Warning:**
- Do NOT touch exposed wires or damaged sockets
- If you smell burning or see sparks, **leave the room immediately** and call the front desk

**What Happens Next:**
- An electrician will be dispatched to your room
- Estimated arrival: **1–2 hours**

**Urgency:** High

Is there anything else you need?''';
    }

    // ── Billing / Payment ─────────────────────────────────────────────
    if (lower.contains('bill') ||
        lower.contains('payment') ||
        lower.contains('charge') ||
        lower.contains('invoice')) {
      return '''For billing and payment queries:

**Common Questions:**
- Your invoice is available at the front desk or via email
- Payments can be made by card, bank transfer, or cash at reception
- If you see an unexpected charge, bring your receipt to the front desk

**Dispute a Charge:**
1. Note the charge amount and date
2. Visit reception with your booking confirmation
3. Disputes are typically resolved within **24–48 hours**

**Urgency:** Low
**Estimated Resolution:** 24–48 hours

Would you like help with anything else?''';
    }

    // ── Food / Dining ─────────────────────────────────────────────────
    if (lower.contains('food') ||
        lower.contains('meal') ||
        lower.contains('dining') ||
        lower.contains('breakfast') ||
        lower.contains('lunch') ||
        lower.contains('dinner')) {
      return '''Here's the dining information:

**Meal Times:**
- 🍳 Breakfast: 7:00 AM – 9:30 AM
- 🥗 Lunch: 12:00 PM – 2:00 PM
- 🍽️ Dinner: 6:30 PM – 9:00 PM

**Common Issues:**
- For dietary requirements or allergies, inform the kitchen staff in advance
- If you received the wrong meal, return to the counter for a replacement
- Food quality complaints can be filed at reception

**Urgency:** Low

Is there anything else I can help with?''';
    }

    // ── Room / Housekeeping ───────────────────────────────────────────
    if (lower.contains('room') || lower.contains('clean')) {
      return '''For room and housekeeping requests:

**Housekeeping Schedule:**
- Rooms are cleaned daily between 9:00 AM – 12:00 PM
- If you missed your slot, request a clean at the front desk

**Common Requests:**
- Extra towels or bedding → ask at reception
- Room not cleaned → we'll send housekeeping within 1 hour
- Pest issues → maintenance team will be notified immediately

**Urgency:** Low–Medium
**Estimated Resolution:** 1–2 hours

Would you like to report anything specific?''';
    }

    // ── Default / General ─────────────────────────────────────────────
    return '''Thank you for reaching out. I've noted your concern.

**What Happens Next:**
- Your issue has been logged and forwarded to the relevant team
- A staff member will follow up with you shortly
- For urgent matters, please visit the **front desk** directly

**Urgency:** Medium
**Estimated Resolution:** 2–4 hours

Is there anything else I can help with?''';
  }

  static String detectIssueCategory(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('wifi') ||
        lower.contains('internet') ||
        lower.contains('network')) {
      return 'Internet & Connectivity';
    } else if (lower.contains('water') ||
        lower.contains('plumb') ||
        lower.contains('tap') ||
        lower.contains('shower')) {
      return 'Plumbing';
    } else if (lower.contains('electric') ||
        lower.contains('power') ||
        lower.contains('light')) {
      return 'Electrical';
    } else if (lower.contains('heat') ||
        lower.contains('cool') ||
        lower.contains('ac') ||
        lower.contains('air condition')) {
      return 'HVAC';
    } else if (lower.contains('laundry') ||
        lower.contains('wash') ||
        lower.contains('dryer')) {
      return 'Laundry';
    } else if (lower.contains('noise') || lower.contains('loud')) {
      return 'Noise Complaint';
    } else if (lower.contains('security') ||
        lower.contains('lock') ||
        lower.contains('key')) {
      return 'Security';
    } else if (lower.contains('bill') ||
        lower.contains('payment') ||
        lower.contains('charge')) {
      return 'Billing';
    } else if (lower.contains('food') || lower.contains('meal')) {
      return 'Dining';
    } else if (lower.contains('room') || lower.contains('clean')) {
      return 'Room & Housekeeping';
    }

    return 'General';
  }
}
