# Reply

A discreet native iPhone keyboard utility (internal codename Samba Reply) with an optional on-device screen-text reader.

## Flow

1. Open the Reply app, complete onboarding, and add the keyboard in Settings.
2. Optionally turn on Conversation Context and start it from Settings → Context. It is off by default.
3. Return to Instagram, Messages, WhatsApp or another chat app.
4. If Context is running, the broadcast extension samples the visible screen and uses Apple Vision OCR on device.
5. Extracted text is stored in the shared App Group. Screenshots are not uploaded.
6. Open the Reply keyboard and tap Reply, Short, Direct, Work or Fix.
7. The keyboard sends the draft, selected mode/style, and the on-screen text (only if Context is on) to the configured backend.
8. Tap a suggestion to insert it into the current text field. The user still presses Send.

## iOS compatibility

This prototype intentionally uses ReplayKit's Broadcast Upload Extension for broad iOS 18+ compatibility. Apple now deprecates that picker in favour of ScreenCaptureKit. Apple's current full-display ScreenCaptureKit iOS sample requires iOS 27, so the project can migrate to ScreenCaptureKit when the deployment target moves to iOS 27.

## Targets

- `SambaReplyApp` companion/setup app
- `SambaReplyKeyboard` custom keyboard extension
- `SambaReplyBroadcast` ReplayKit screen reader extension

All three use App Group `group.com.sixsixss.sambareply`.

## Backend

`backend/supabase/functions/samba-reply/index.ts` is a Supabase Edge Function. Set `OPENAI_API_KEY` as a Supabase secret and deploy the function. Put the resulting function URL in the companion app under Settings → Advanced. Never ship the OpenAI API key in the iPhone app or keyboard extension.

Also set a `REPLY_CLIENT_KEY` secret (any long random string) and enter the same value in the app under Settings → Advanced → Client key. The function checks this on every request so it is not fully open on the public internet — without it set, the function still works but accepts requests from anyone who finds the URL. The function also applies a best-effort per-instance rate limit; it is not a durable distributed limiter, so treat it as a first line of defence, not a guarantee.

## Apple Developer setup before installing on a real iPhone

Create/register these bundle IDs under the same Apple Developer team:

- `com.sixsixss.sambareply`
- `com.sixsixss.sambareply.keyboard`
- `com.sixsixss.sambareply.broadcast`

Enable App Groups for each target and add `group.com.sixsixss.sambareply`. Create matching development or distribution provisioning profiles for all three targets.

## Generate and build

```sh
cd samba-reply
brew install xcodegen
xcodegen generate
xcodebuild -project SambaReply.xcodeproj -scheme SambaReplyApp -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

## Privacy notes

Conversation Context is off by default. Screen capture is user initiated and visibly indicated by iOS with its own recording indicator — the app never hides or replaces that indicator. While running, the extension can see the visible screen, not only the target chat app. Stop Context when finished. OCR is performed on device. Only extracted text is sent to the configured backend when a reply is generated, and only when Context is enabled.

History is off by default; when enabled it stores only the text that was inserted, never the surrounding conversation, and can be protected with Face ID. The app hides its content whenever it is backgrounded so the app switcher never shows sensitive text.
