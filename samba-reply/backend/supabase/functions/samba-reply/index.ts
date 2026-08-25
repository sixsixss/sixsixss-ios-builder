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
    const mode = String(body.mode ?? "chill");

    const instructions = `You write text-message replies for Samba. Keep them short, natural and human. Never sound corporate or like an AI. Do not use hyphens or dashes. Match the energy of the conversation. Give exactly 3 distinct options.\n\nModes:\nchill: relaxed, direct, low effort, confident.\nflirt: playful and interested without sounding needy or oversexual.\nfunny: deadpan, unserious, lightly trollish, natural.\nbusiness: warm, direct, simple, confident.\nfix: rewrite Samba's draft in the same meaning but cleaner and more natural.\n\nReturn only a JSON array of 3 strings. No markdown.`;

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
