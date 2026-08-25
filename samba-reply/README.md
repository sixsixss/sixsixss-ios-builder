# Samba Reply keyboard prototype

A native iPhone companion app with a custom keyboard and an on-device screen-text reader.

## Flow

1. Start `Samba Reply Screen Read` from the companion app.
2. Return to Instagram, Messages, WhatsApp or another chat app.
3. The broadcast extension samples the visible screen and uses Apple Vision OCR on device.
4. Extracted text is stored in the shared App Group. Screenshots are not uploaded.
5. Open the Samba Reply keyboard and tap `Reply`.
6. The keyboard sends the extracted text, current draft and selected mode to the configured backend.
7. Tap one of the three replies to insert it into the current text field. The user still presses Send.

## iOS compatibility

This prototype intentionally uses ReplayKit's Broadcast Upload Extension for broad iOS 18+ compatibility. Apple now deprecates that picker in favour of ScreenCaptureKit. Apple's current full-display ScreenCaptureKit iOS sample requires iOS 27, so the project can migrate to ScreenCaptureKit when the deployment target moves to iOS 27.

## Targets

- `SambaReplyApp` companion/setup app
- `SambaReplyKeyboard` custom keyboard extension
- `SambaReplyBroadcast` ReplayKit screen reader extension

All three use App Group `group.com.sixsixss.sambareply`.

## Backend

`backend/supabase/functions/samba-reply/index.ts` is a Supabase Edge Function. Set `OPENAI_API_KEY` as a Supabase secret and deploy the function. Put the resulting function URL in the companion app. Never ship the OpenAI API key in the iPhone app or keyboard extension.

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

Screen capture is user initiated and visibly indicated by iOS. While it is running, the extension can see the visible screen, not only Instagram. Stop Screen Read when finished. OCR is performed on device. Only extracted text is sent to the configured backend when `Reply` is tapped.
