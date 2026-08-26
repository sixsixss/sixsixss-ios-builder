import OpenAI from "npm:openai";

const openai = new OpenAI({ apiKey: Deno.env.get("OPENAI_API_KEY") });

const headers = {
  "content-type": "application/json",
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, x-client-info, apikey, content-type, x-reply-client-key",
};

/**
 * Best-effort request throttle. Resets whenever this function instance cold
 * starts and is not shared across concurrent instances, so it is a first
 * line of defence against a runaway client, not a real distributed rate
 * limiter. Fine for a single-user personal app; would need a durable store
 * (e.g. Supabase Postgres or Deno KV) to hold up under real abuse.
 */
const requestLog = new Map<string, { count: number; windowStart: number }>();
const RATE_LIMIT_WINDOW_MS = 60_000;
const RATE_LIMIT_MAX = 20;

function isRateLimited(clientId: string): boolean {
  const now = Date.now();
  const entry = requestLog.get(clientId);
  if (!entry || now - entry.windowStart > RATE_LIMIT_WINDOW_MS) {
    requestLog.set(clientId, { count: 1, windowStart: now });
    return false;
  }
  entry.count += 1;
  return entry.count > RATE_LIMIT_MAX;
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers });
  if (request.method !== "POST") return new Response(JSON.stringify({ error: "POST only" }), { status: 405, headers });

  if (!Deno.env.get("OPENAI_API_KEY")) {
    return new Response(JSON.stringify({ error: "OPENAI_API_KEY is not configured" }), { status: 500, headers });
  }

  // A configured REPLY_CLIENT_KEY secret gates this function so it is not
  // fully open on the public internet. Optional so the function still works
  // before the secret is first set, but should always be set in production.
  const expectedKey = Deno.env.get("REPLY_CLIENT_KEY");
  if (expectedKey) {
    const providedKey = request.headers.get("x-reply-client-key");
    if (providedKey !== expectedKey) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers });
    }
  }

  const clientId = request.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ?? "unknown";
  if (isRateLimited(clientId)) {
    return new Response(JSON.stringify({ error: "Too many requests" }), { status: 429, headers });
  }

  try {
    const body = await request.json();
    const conversation = String(body.conversation ?? "").slice(-9000);
    const draft = String(body.draft ?? "").slice(-1500);
    const mode = String(body.mode ?? "auto");
    const style = String(body.style ?? "automatic");

    const instructions = `You write text-message replies for Samba. Keep them short, natural and human. Never sound corporate or like an AI. Do not use hyphens or dashes. Give exactly 3 distinct options.

Read the whole conversation, not just the last line. If the other person asked a question, answer it directly before adding anything else. Match the energy and pacing of the conversation so far.

Visible controls are deliberately neutral and private:
auto: infer the relationship, context, warmth, humour, seriousness and level of interest from the conversation without naming or exposing those categories.
short: make each option very brief.
direct: clear, confident and straight to the point.
work: warm, simple and professional without sounding corporate.
fix: rewrite Samba's current draft with the same meaning but cleaner and more natural. Ignore the conversation for tone and just improve the draft.

STYLE is a quiet overall dial, independent of mode:
automatic: no additional bias, read the room.
natural: lean warmer and more conversational.
direct: lean brief and to the point.

When auto is selected, quietly adapt to the real context, including personal, social, romantic, friendly or professional conversation where appropriate. Never output metadata, mode names, relationship labels or explanations. Return only a JSON array of 3 strings. No markdown.`;

    const response = await openai.responses.create({
      model: "gpt-5.6-luna",
      instructions,
      input: `MODE: ${mode}\nSTYLE: ${style}\n\nVISIBLE CONVERSATION:\n${conversation}\n\nCURRENT DRAFT:\n${draft}`,
    });

    const raw = response.output_text.trim();
    const arrayText = raw.match(/\[[\s\S]*\]/)?.[0] ?? raw;
    const parsed = JSON.parse(arrayText);
    const suggestions = Array.isArray(parsed)
      ? parsed.map((item) => String(item).trim()).filter(Boolean).slice(0, 3)
      : [];

    if (!suggestions.length) throw new Error("No suggestions returned");
    return new Response(JSON.stringify({ suggestions }), { headers });
  } catch (error) {
    return new Response(JSON.stringify({ error: error instanceof Error ? error.message : "Unknown error" }), { status: 500, headers });
  }
});
