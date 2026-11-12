# Very Yummy Coffee: voice order prototype

Order drinks out loud and watch the order build on screen while you are still
talking. Corrections such as "actually, make that one iced" or "the other one"
are applied to the right drink mid-sentence.

Web only (Chrome). It does not use the Very Yummy Coffee backend: the menu is a
copy of the drinks in `api/fixtures/menu.json`.

## Run it

```sh
cd applications/voice_order_app
flutter run -d chrome
```

Paste an OpenAI API key on the first screen, or pass it at build time to skip
that screen:

```sh
flutter run -d chrome --dart-define=OPENAI_API_KEY=sk-...
```

"Play a sample order instead" replays a recorded order with no key, microphone
or network. Nothing in the replay is worked out by a model.

## How it works

1. **Speech to text.** Microphone audio (24 kHz PCM) streams over a WebSocket
   to an OpenAI Realtime transcription session using `gpt-realtime-whisper`,
   which sends text back continuously instead of waiting for a pause.
   See `lib/speech/openai_realtime_transcriber.dart`.
2. **Decisions.** Every time the transcript changes, the whole transcript is
   sent to OpenAI's Decisions API (`POST /v1/decisions`, `gpt-6-luna`). That
   API only returns typed answers, never a list, so the order is modelled as
   six numbered slots with five `choice` questions each: drink, size, shots,
   milk and temperature. See `lib/decisions/order_questions.dart`.
3. **Screen.** `VoiceOrderBloc` keeps at most two decision requests running,
   always sends the newest transcript next, and drops any reply that arrives
   after a newer one. Options that change light up briefly.

Because the whole transcript is sent each time, corrections need no special
handling: the model simply answers for the order as it now stands.

## Known gaps

- The API key is used directly from the browser. That is fine for a local
  prototype and not for anything deployed.
- Syrups and food are not in the voice menu.
- The GitHub Actions workflow for this package has not been generated
  (`.github/update_github_actions.sh`).
