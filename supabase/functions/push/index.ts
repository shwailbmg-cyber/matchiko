// Sends one push per new notification (Database Webhook on
// notifications INSERT → this function). Secrets (supabase secrets set):
//   PUSH_WEBHOOK_SECRET   shared with the webhook header x-webhook-secret
//   FCM_SERVICE_ACCOUNT   Firebase service account JSON (FCM HTTP v1)
// SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are set by Supabase.
import { createClient } from "npm:@supabase/supabase-js@2.58.0";

type Lang = "en" | "fr" | "ar";
type Row = { user_id: string; kind: string; payload: Record<string, unknown> };

const texts: Record<string, Record<Lang, (p: Record<string, string>) => [string, string]>> = {
  still_coming: {
    en: (p) => ["Still coming?", `Your game starts at ${p.time}. Tell the others.`],
    fr: (p) => ["Tu viens toujours ?", `Ton match commence à ${p.time}. Préviens les autres.`],
    ar: (p) => ["هل ستأتي؟", `مباراتك تبدأ على الساعة ${p.time}. أخبر الآخرين.`],
  },
  spot_open: {
    en: (p) => ["A spot is open", `${p.pitch} at ${p.time}`],
    fr: (p) => ["Une place est libre", `${p.pitch} à ${p.time}`],
    ar: (p) => ["مكان شاغر", `${p.pitch} على الساعة ${p.time}`],
  },
  booking_confirmed: {
    en: (p) => ["Booking confirmed", `See you at ${p.time}.`],
    fr: (p) => ["Réservation confirmée", `Rendez-vous à ${p.time}.`],
    ar: (p) => ["تم تأكيد الحجز", `نلتقي على الساعة ${p.time}.`],
  },
  rate_game: {
    en: () => ["How was the game?", "Rate the players and the pitch."],
    fr: () => ["C’était comment ?", "Note les joueurs et le terrain."],
    ar: () => ["كيف كانت المباراة؟", "قيّم اللاعبين والملعب."],
  },
  friend_request: {
    en: (p) => ["Friend request", `${p.name} wants to be your friend.`],
    fr: (p) => ["Demande d’ami", `${p.name} veut être ton ami.`],
    ar: (p) => ["طلب صداقة", `${p.name} يريد أن يكون صديقك.`],
  },
};

/** Constant-time string compare (the webhook secret). */
function same(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let d = 0;
  for (let i = 0; i < a.length; i++) d |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return d === 0;
}

const b64url = (b: ArrayBuffer | Uint8Array | string) =>
  btoa(typeof b === "string" ? b : String.fromCharCode(...new Uint8Array(b)))
    .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

let cached: { token: string; until: number } | undefined;

/** OAuth token for FCM from the service account (JWT bearer grant). */
async function accessToken(sa: { client_email: string; private_key: string }) {
  if (cached && cached.until > Date.now()) return cached.token;
  const now = Math.floor(Date.now() / 1000);
  const claim = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };
  const unsigned = `${b64url(JSON.stringify({ alg: "RS256", typ: "JWT" }))}.${b64url(JSON.stringify(claim))}`;
  const pem = sa.private_key.replace(/-----[^-]+-----|\s/g, "");
  const key = await crypto.subtle.importKey(
    "pkcs8",
    Uint8Array.from(atob(pem), (c) => c.charCodeAt(0)),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(unsigned));
  const r = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${unsigned}.${b64url(sig)}`,
    }),
  });
  if (!r.ok) throw new Error(`oauth ${r.status}`);
  const j = await r.json();
  cached = { token: j.access_token, until: Date.now() + 50 * 60 * 1000 };
  return cached.token;
}

Deno.serve(async (req) => {
  const secret = Deno.env.get("PUSH_WEBHOOK_SECRET") ?? "";
  if (req.method !== "POST" || !secret || !same(req.headers.get("x-webhook-secret") ?? "", secret)) {
    return new Response("forbidden", { status: 403 });
  }
  const { record } = (await req.json()) as { record?: Row };
  const t = record && texts[record.kind];
  if (!record || !t) return new Response("ignored");

  const db = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  const [{ data: profile }, { data: tokens }] = await Promise.all([
    db.from("profiles").select("lang").eq("id", record.user_id).single(),
    db.from("push_tokens").select("token").eq("user_id", record.user_id),
  ]);
  if (!tokens?.length) return new Response("no devices");

  const lang: Lang = ["en", "fr", "ar"].includes(profile?.lang) ? profile!.lang : "fr";
  const p = Object.fromEntries(Object.entries(record.payload ?? {}).map(([k, v]) => [k, String(v ?? "")]));
  const [title, body] = t[lang](p);
  const sa = JSON.parse(Deno.env.get("FCM_SERVICE_ACCOUNT")!);
  const auth = await accessToken(sa);

  for (const { token } of tokens) {
    const r = await fetch(`https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`, {
      method: "POST",
      headers: { authorization: `Bearer ${auth}`, "content-type": "application/json" },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          // Only ids, never personal data: the app loads the rest itself.
          data: { kind: record.kind, game_id: p.game_id ?? "" },
        },
      }),
    });
    // UNREGISTERED: the app was uninstalled or the token expired.
    if (r.status === 404) {
      await db.from("push_tokens").delete().eq("token", token);
    }
  }
  return new Response("sent");
});
