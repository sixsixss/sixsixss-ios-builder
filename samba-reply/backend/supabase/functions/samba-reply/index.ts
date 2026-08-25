import OpenAI from "npm:openai";

const openai = new OpenAI({ apiKey: Deno.env.get("OPENAI_API_KEY") });

const headers = {
  "content-type": "application/json",
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers });
  if (request.method !== "POST") return new Response(JSON.stringify({ error: "POST only" }), { status: 405, headers });

  if (!Deno.env.get("OPENAI_API_KEY")) {
    return new Response(JSON.stringify({ error: "OPENAI_API_KEY is not configured" }), { status: 500, headers });
  }

  try {
    const body = await request.json();
    const conversation = String(body.conversation ?? "").slice(-9000);
    const draft = String(body.draft ?? "").slice(-1500);
    const mode = String(body.mode ?? "auto");

    const instructions = `You write text-message replies for Samba. Keep them short, natural and human. Never sound corporate or like an AI. Do not use hyphens or dashes. Match the energy of the conversation. Give exactly 3 distinct options.

Visible controls are deliberately neutral and private:
auto: infer the relationship, context, warmth, humour, seriousness and level of interest from the conversation without naming or exposing those categories.
short: make each option very brief.
direct: clear, confident and straight to the point.
work: warm, simple and professional without sounding corporate.
fix: rewrite Samba's current draft with the same meaning but cleaner and more natural.

When auto is selected, quietly adapt to the real context, including personal, social, romantic, friendly or professional conversation where appropriate. Never output metadata, mode names, relationship labels or explanations. Return only a JSON array of 3 strings. No markdown.`;

    const response = await openai.responses.create({
      model: "gpt-5.6-luna",
      instructions,
      input: `MODE: ${mode}\n\nVISIBLE CONVERSATION:\n${conversation}\n\nCURRENT DRAFT:\n${draft}`,
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
