const pptxgen = require("pptxgenjs");
const path = require("path");

// ── Theme ──
const C = {
  primary: "028090",
  secondary: "00A896",
  accent: "02C39A",
  dark: "1B2A4A",
  light: "F5F7FA",
  text: "1E293B",
  muted: "64748B",
  white: "FFFFFF",
};

const FONT_H = "Calibri";
const FONT_B = "Calibri Light";

// ── Helpers ──
function titleSlide(pres, title, subtitle) {
  const s = pres.addSlide();
  s.background = { fill: C.dark };
  // accent bar
  s.addShape(pres.ShapeType.rect, { x: 0, y: 0, w: 0.15, h: "100%", fill: { color: C.accent } });
  s.addText(title, { x: 0.8, y: 1.5, w: 8.5, h: 1.5, fontSize: 36, fontFace: FONT_H, color: C.white, bold: true });
  s.addText(subtitle, { x: 0.8, y: 3.2, w: 8.5, h: 0.8, fontSize: 20, fontFace: FONT_B, color: C.accent });
  // bottom bar
  s.addShape(pres.ShapeType.rect, { x: 0, y: 5.1, w: "100%", h: 0.15, fill: { color: C.accent } });
  return s;
}

function contentSlide(pres, heading) {
  const s = pres.addSlide();
  s.background = { fill: C.light };
  // top bar
  s.addShape(pres.ShapeType.rect, { x: 0, y: 0, w: "100%", h: 0.08, fill: { color: C.primary } });
  s.addText(heading, { x: 0.6, y: 0.3, w: 9, h: 0.7, fontSize: 26, fontFace: FONT_H, color: C.primary, bold: true });
  return s;
}

function bulletBlock(items, opts = {}) {
  const fs = opts.fontSize || 16;
  const color = opts.color || C.text;
  const arr = [];
  items.forEach((t, i) => {
    if (i > 0) arr.push({ text: "", options: { breakLine: true, fontSize: 4 } });
    arr.push({ text: t, options: { bullet: true, fontSize: fs, fontFace: FONT_B, color: color, breakLine: true } });
  });
  return arr;
}

function deferralSlide(pres) {
  const s = contentSlide(pres, "Level 300 — What We're NOT Covering Today");
  const topics = [
    "Custom Python tools",
    "MCP custom connectors",
    "Skills authoring",
    "Custom Agents in YAML",
    "Custom tools + Code Interpreter",
    "Agent Hooks",
    "Knowledge base deep dive",
    "Cross-tenant connectors, VNET isolation",
    "Plugin Marketplace",
    "Agent Playground",
  ];
  s.addText(bulletBlock(topics, { fontSize: 14 }), { x: 0.6, y: 1.2, w: 9, h: 3.8, valign: "top" });
  s.addText("These are Level 300 deep-dives — scheduled for follow-up workshops.", {
    x: 0.6, y: 4.9, w: 9, h: 0.4, fontSize: 13, fontFace: FONT_B, color: C.muted, italic: true,
  });
  return s;
}

// ═══════════════════════════════════════════
// DECK 1 — Concepts
// ═══════════════════════════════════════════
function buildDeck1() {
  const pres = new pptxgen();
  pres.layout = "LAYOUT_16x9";
  pres.author = "Dallas — SRE Agent L200 Workshop";

  // S1 Title
  titleSlide(pres, "Module 1: What & Why —\nSRE Agent Concepts", "Level 100  |  30 minutes");

  // S2 The Problem
  {
    const s = contentSlide(pres, 'The 3 AM, 5-Tabs Problem');
    s.addText([
      { text: "The on-call reality today:", options: { fontSize: 18, fontFace: FONT_H, color: C.text, bold: true, breakLine: true } },
      { text: "", options: { breakLine: true, fontSize: 6 } },
      { text: "Alert fires at 3 AM → open Azure Portal, Log Analytics, App Insights, Grafana, wiki…", options: { bullet: true, fontSize: 15, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Copy-paste queries, correlate timestamps manually, guess at root cause", options: { bullet: true, fontSize: 15, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Context scattered across 5+ browser tabs and Slack threads", options: { bullet: true, fontSize: 15, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Previous incidents forgotten — team re-learns lessons each time", options: { bullet: true, fontSize: 15, fontFace: FONT_B, color: C.text, breakLine: true } },
    ], { x: 0.6, y: 1.2, w: 5.5, h: 3.0, valign: "top" });

    // right box — how SREA changes it
    s.addShape(pres.ShapeType.rect, { x: 6.5, y: 1.2, w: 3.3, h: 3.2, fill: { color: C.primary }, rectRadius: 0.1 });
    s.addText([
      { text: "How SRE Agent Changes This", options: { fontSize: 16, fontFace: FONT_H, color: C.accent, bold: true, breakLine: true } },
      { text: "", options: { breakLine: true, fontSize: 6 } },
      { text: "One conversation replaces 5 tabs", options: { bullet: true, fontSize: 13, fontFace: FONT_B, color: C.white, breakLine: true } },
      { text: "Automated log correlation & analysis", options: { bullet: true, fontSize: 13, fontFace: FONT_B, color: C.white, breakLine: true } },
      { text: "Persistent memory of past incidents", options: { bullet: true, fontSize: 13, fontFace: FONT_B, color: C.white, breakLine: true } },
      { text: "Proactive background intelligence", options: { bullet: true, fontSize: 13, fontFace: FONT_B, color: C.white, breakLine: true } },
    ], { x: 6.7, y: 1.35, w: 2.9, h: 2.9, valign: "top" });
  }

  // S3 What is SRE Agent
  {
    const s = contentSlide(pres, "What is SRE Agent?");
    s.addText([
      { text: "An AI operations teammate", options: { fontSize: 22, fontFace: FONT_H, color: C.primary, bold: true, breakLine: true } },
      { text: "", options: { breakLine: true, fontSize: 10 } },
      { text: "Not a chatbot — it takes real actions on your Azure infrastructure", options: { fontSize: 16, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Not a script runner — it reasons about context, correlates signals, and adapts", options: { fontSize: 16, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Not a replacement — it augments your team's expertise with speed and memory", options: { fontSize: 16, fontFace: FONT_B, color: C.text, breakLine: true } },
    ], { x: 0.6, y: 1.3, w: 9, h: 3.5, valign: "top" });
  }

  // S4 Deep Context — Three Pillars
  {
    const s = contentSlide(pres, "Deep Context — Three Pillars");
    const pillars = [
      { title: "Context Analysis", desc: "Correlates logs, metrics, config, and topology in real time", x: 0.5 },
      { title: "Persistent Memory", desc: "Remembers past incidents, runbooks, and environment-specific facts", x: 3.6 },
      { title: "Background Intelligence", desc: "Proactively monitors and surfaces issues before alerts fire", x: 6.7 },
    ];
    pillars.forEach((p) => {
      s.addShape(pres.ShapeType.rect, { x: p.x, y: 1.3, w: 2.8, h: 3.0, fill: { color: C.white }, line: { color: C.primary, width: 1.5 }, rectRadius: 0.05 });
      s.addShape(pres.ShapeType.rect, { x: p.x, y: 1.3, w: 2.8, h: 0.08, fill: { color: C.accent } });
      s.addText(p.title, { x: p.x + 0.15, y: 1.6, w: 2.5, h: 0.6, fontSize: 16, fontFace: FONT_H, color: C.primary, bold: true });
      s.addText(p.desc, { x: p.x + 0.15, y: 2.3, w: 2.5, h: 1.5, fontSize: 13, fontFace: FONT_B, color: C.text, valign: "top" });
    });
  }

  // S5 Architecture — Connect → Enhance → Achieve
  {
    const s = contentSlide(pres, "Architecture: Connect → Enhance → Achieve");
    const phases = [
      { label: "CONNECT", desc: "Connectors link to Azure Monitor, Log Analytics, App Insights, Resource Graph, 3rd-party tools", color: C.primary, x: 0.4 },
      { label: "ENHANCE", desc: "Skills, Knowledge Bases, Custom Tools — extend the agent's capabilities and memory", color: C.secondary, x: 3.5 },
      { label: "ACHIEVE", desc: "Response Plans & Scheduled Tasks execute diagnostics, remediation, and proactive checks", color: C.accent, x: 6.6 },
    ];
    phases.forEach((p) => {
      s.addShape(pres.ShapeType.rect, { x: p.x, y: 1.4, w: 2.8, h: 2.8, fill: { color: p.color }, rectRadius: 0.05 });
      s.addText(p.label, { x: p.x, y: 1.55, w: 2.8, h: 0.6, fontSize: 20, fontFace: FONT_H, color: C.white, bold: true, align: "center" });
      s.addText(p.desc, { x: p.x + 0.2, y: 2.3, w: 2.4, h: 1.6, fontSize: 12, fontFace: FONT_B, color: C.white, valign: "top" });
    });
    // arrows
    s.addText("→", { x: 3.15, y: 2.2, w: 0.5, h: 0.6, fontSize: 32, fontFace: FONT_H, color: C.dark, align: "center" });
    s.addText("→", { x: 6.25, y: 2.2, w: 0.5, h: 0.6, fontSize: 32, fontFace: FONT_H, color: C.dark, align: "center" });
  }

  // S6 Glossary
  {
    const s = contentSlide(pres, "Key Glossary");
    const terms = [
      ["Agent", "The SRE Agent resource — your AI operations teammate"],
      ["Connector", "A bridge linking the agent to an Azure or third-party data source"],
      ["Tool", "A discrete action the agent can invoke (read logs, restart, query, etc.)"],
      ["Skill", "A reusable prompt template that bundles tools + instructions for a scenario"],
      ["Custom Agent", "A sub-agent you define in YAML to handle a specialized domain"],
      ["Knowledge Base", "Persistent memory: runbooks, environment facts, past learnings"],
      ["Response Plan", "An automated investigation/remediation workflow triggered by alerts"],
      ["Scheduled Task", "A recurring background job (health check, drift detection, etc.)"],
      ["Run Mode", "Review (human-in-the-loop) or Autonomous (execute-then-report)"],
    ];
    const col1 = terms.slice(0, 5);
    const col2 = terms.slice(5);

    function termBlock(arr) {
      const out = [];
      arr.forEach((t, i) => {
        if (i > 0) out.push({ text: "", options: { breakLine: true, fontSize: 4 } });
        out.push({ text: t[0], options: { fontSize: 13, fontFace: FONT_H, color: C.primary, bold: true, breakLine: true } });
        out.push({ text: t[1], options: { fontSize: 11, fontFace: FONT_B, color: C.text, breakLine: true } });
      });
      return out;
    }
    s.addText(termBlock(col1), { x: 0.5, y: 1.1, w: 4.5, h: 4.0, valign: "top" });
    s.addText(termBlock(col2), { x: 5.3, y: 1.1, w: 4.5, h: 4.0, valign: "top" });
  }

  // S7 Deferral
  deferralSlide(pres);

  pres.writeFile({ fileName: path.join(__dirname, "concepts.pptx") });
  console.log("  ✓ concepts.pptx");
}

// ═══════════════════════════════════════════
// DECK 2 — Access Control
// ═══════════════════════════════════════════
function buildDeck2() {
  const pres = new pptxgen();
  pres.layout = "LAYOUT_16x9";
  pres.author = "Dallas — SRE Agent L200 Workshop";

  // S1 Title
  titleSlide(pres, "Module 2: Access Control Model", "Level 100  |  30 minutes");

  // S2 Why This Module
  {
    const s = contentSlide(pres, "Why This Module First?");
    s.addShape(pres.ShapeType.rect, { x: 0.6, y: 1.5, w: 9, h: 1.5, fill: { color: C.dark }, rectRadius: 0.05 });
    s.addText("Every later lab depends on understanding who can do what — and when the agent asks for approval.", {
      x: 0.9, y: 1.6, w: 8.4, h: 1.3, fontSize: 20, fontFace: FONT_H, color: C.white, align: "center", valign: "middle",
    });
    s.addText([
      { text: "Before you chat, create connectors, or build response plans — you need to understand:", options: { fontSize: 15, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "", options: { breakLine: true, fontSize: 4 } },
      { text: "User Roles — what humans can do with the agent", options: { bullet: true, fontSize: 14, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Run Modes — whether the agent asks before acting", options: { bullet: true, fontSize: 14, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Agent Permissions — what the agent can read/do on Azure resources", options: { bullet: true, fontSize: 14, fontFace: FONT_B, color: C.text, breakLine: true } },
    ], { x: 0.6, y: 3.3, w: 9, h: 2.0, valign: "top" });
  }

  // S3 Three-Layer Diagram
  {
    const s = contentSlide(pres, "The Three-Layer Access Model");
    const layers = [
      { label: "User Roles", controls: "What a human can do\nwith the agent", where: "Azure IAM on\nagent resource", fill: C.primary },
      { label: "Run Modes", controls: "Whether agent asks\nbefore acting on infra", where: "Per Response Plan &\nper Scheduled Task", fill: C.secondary },
      { label: "Agent Permissions", controls: "What agent can read/do\non Azure resources\n(+ OBO fallback)", where: "RBAC roles on\nagent's UAMI", fill: C.accent },
    ];
    const yStart = 1.3;
    const rowH = 1.1;
    // header
    s.addShape(pres.ShapeType.rect, { x: 0.5, y: yStart, w: 9.2, h: 0.55, fill: { color: C.dark } });
    s.addText("Layer", { x: 0.6, y: yStart, w: 2.4, h: 0.55, fontSize: 13, fontFace: FONT_H, color: C.white, bold: true, valign: "middle" });
    s.addText("What It Controls", { x: 3.1, y: yStart, w: 3.5, h: 0.55, fontSize: 13, fontFace: FONT_H, color: C.white, bold: true, valign: "middle" });
    s.addText("Where It Lives", { x: 6.7, y: yStart, w: 3.0, h: 0.55, fontSize: 13, fontFace: FONT_H, color: C.white, bold: true, valign: "middle" });

    layers.forEach((l, i) => {
      const y = yStart + 0.6 + i * (rowH + 0.1);
      s.addShape(pres.ShapeType.rect, { x: 0.5, y: y, w: 2.5, h: rowH, fill: { color: l.fill }, rectRadius: 0.04 });
      s.addText(l.label, { x: 0.55, y: y, w: 2.4, h: rowH, fontSize: 14, fontFace: FONT_H, color: C.white, bold: true, valign: "middle", align: "center" });
      s.addText(l.controls, { x: 3.1, y: y, w: 3.5, h: rowH, fontSize: 12, fontFace: FONT_B, color: C.text, valign: "middle" });
      s.addText(l.where, { x: 6.7, y: y, w: 3.0, h: rowH, fontSize: 12, fontFace: FONT_B, color: C.text, valign: "middle" });
    });

    // arrow annotations
    s.addText("↕  Layers are independent — changing one does not affect the others", {
      x: 0.5, y: 4.7, w: 9, h: 0.4, fontSize: 12, fontFace: FONT_B, color: C.muted, italic: true,
    });
  }

  // S4 User Roles
  {
    const s = contentSlide(pres, "User Roles");
    const roles = [
      { role: "SRE Agent Reader", perms: "View agent configuration, read session history", color: C.secondary },
      { role: "SRE Agent Standard User", perms: "Chat with agent, run diagnostics, trigger skills", color: C.primary },
      { role: "SRE Agent Administrator", perms: "Approve actions, manage connectors, authorize On-Behalf-Of (OBO)", color: C.dark },
    ];
    roles.forEach((r, i) => {
      const y = 1.3 + i * 1.2;
      s.addShape(pres.ShapeType.rect, { x: 0.5, y: y, w: 0.12, h: 1.0, fill: { color: r.color } });
      s.addText(r.role, { x: 0.8, y: y, w: 4.0, h: 0.5, fontSize: 16, fontFace: FONT_H, color: r.color, bold: true });
      s.addText(r.perms, { x: 0.8, y: y + 0.45, w: 8.5, h: 0.5, fontSize: 14, fontFace: FONT_B, color: C.text });
    });
  }

  // S5 Permission Levels
  {
    const s = contentSlide(pres, "Permission Levels & Always-Assigned RBAC");
    s.addText([
      { text: "Reader (recommended starter)", options: { fontSize: 16, fontFace: FONT_H, color: C.primary, bold: true, breakLine: true } },
      { text: "Read-only diagnostics — the safest starting point for every agent", options: { fontSize: 14, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "", options: { breakLine: true, fontSize: 8 } },
      { text: "Privileged", options: { fontSize: 16, fontFace: FONT_H, color: C.dark, bold: true, breakLine: true } },
      { text: "Resource-type-specific contributor roles — enables remediation actions", options: { fontSize: 14, fontFace: FONT_B, color: C.text, breakLine: true } },
    ], { x: 0.6, y: 1.2, w: 5.0, h: 2.5, valign: "top" });

    s.addShape(pres.ShapeType.rect, { x: 5.8, y: 1.2, w: 4.0, h: 3.5, fill: { color: C.dark }, rectRadius: 0.05 });
    s.addText([
      { text: "Always-Assigned RBAC", options: { fontSize: 14, fontFace: FONT_H, color: C.accent, bold: true, breakLine: true } },
      { text: "", options: { breakLine: true, fontSize: 6 } },
      { text: "Resource Group scope:", options: { fontSize: 12, fontFace: FONT_H, color: C.white, bold: true, breakLine: true } },
      { text: "Reader", options: { bullet: true, fontSize: 12, fontFace: FONT_B, color: C.white, breakLine: true } },
      { text: "Log Analytics Reader", options: { bullet: true, fontSize: 12, fontFace: FONT_B, color: C.white, breakLine: true } },
      { text: "Monitoring Reader", options: { bullet: true, fontSize: 12, fontFace: FONT_B, color: C.white, breakLine: true } },
      { text: "", options: { breakLine: true, fontSize: 6 } },
      { text: "Subscription scope:", options: { fontSize: 12, fontFace: FONT_H, color: C.white, bold: true, breakLine: true } },
      { text: "Monitoring Contributor", options: { bullet: true, fontSize: 12, fontFace: FONT_B, color: C.white, breakLine: true } },
    ], { x: 6.0, y: 1.35, w: 3.6, h: 3.2, valign: "top" });
  }

  // S6 Run Modes
  {
    const s = contentSlide(pres, "Run Modes");
    // Review box
    s.addShape(pres.ShapeType.rect, { x: 0.5, y: 1.4, w: 4.2, h: 2.6, fill: { color: C.white }, line: { color: C.primary, width: 2 }, rectRadius: 0.05 });
    s.addShape(pres.ShapeType.rect, { x: 0.5, y: 1.4, w: 4.2, h: 0.5, fill: { color: C.primary } });
    s.addText("Review Mode (Default)", { x: 0.5, y: 1.4, w: 4.2, h: 0.5, fontSize: 15, fontFace: FONT_H, color: C.white, bold: true, align: "center", valign: "middle" });
    s.addText([
      { text: "Human-in-the-loop gate", options: { bullet: true, fontSize: 13, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Agent proposes → human approves or denies", options: { bullet: true, fontSize: 13, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Recommended for initial deployment", options: { bullet: true, fontSize: 13, fontFace: FONT_B, color: C.text, breakLine: true } },
    ], { x: 0.7, y: 2.1, w: 3.8, h: 1.8, valign: "top" });

    // Autonomous box
    s.addShape(pres.ShapeType.rect, { x: 5.3, y: 1.4, w: 4.2, h: 2.6, fill: { color: C.white }, line: { color: C.accent, width: 2 }, rectRadius: 0.05 });
    s.addShape(pres.ShapeType.rect, { x: 5.3, y: 1.4, w: 4.2, h: 0.5, fill: { color: C.accent } });
    s.addText("Autonomous Mode", { x: 5.3, y: 1.4, w: 4.2, h: 0.5, fontSize: 15, fontFace: FONT_H, color: C.white, bold: true, align: "center", valign: "middle" });
    s.addText([
      { text: "Execute then report", options: { bullet: true, fontSize: 13, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Agent acts immediately, notifies after", options: { bullet: true, fontSize: 13, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Use for trusted, well-tested plans only", options: { bullet: true, fontSize: 13, fontFace: FONT_B, color: C.text, breakLine: true } },
    ], { x: 5.5, y: 2.1, w: 3.8, h: 1.8, valign: "top" });

    s.addShape(pres.ShapeType.rect, { x: 0.5, y: 4.3, w: 9.2, h: 0.6, fill: { color: "FFF3CD" }, rectRadius: 0.03 });
    s.addText("⚠  Run Mode does NOT gate emails, Teams posts, or external queries — those always execute.", {
      x: 0.7, y: 4.3, w: 8.8, h: 0.6, fontSize: 12, fontFace: FONT_B, color: C.text, valign: "middle",
    });
  }

  // S7 OBO + Recommendation
  {
    const s = contentSlide(pres, "On-Behalf-Of (OBO) & Recommendations");
    s.addText([
      { text: "When is OBO used?", options: { fontSize: 18, fontFace: FONT_H, color: C.primary, bold: true, breakLine: true } },
      { text: "When the agent's UAMI lacks permission for a specific action", options: { bullet: true, fontSize: 14, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Only SRE Agent Administrators with work/school Entra accounts can authorize", options: { bullet: true, fontSize: 14, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Token is reused only for that specific task — not cached broadly", options: { bullet: true, fontSize: 14, fontFace: FONT_B, color: C.text, breakLine: true } },
    ], { x: 0.6, y: 1.2, w: 9, h: 2.2, valign: "top" });

    s.addShape(pres.ShapeType.rect, { x: 0.6, y: 3.5, w: 9, h: 1.2, fill: { color: C.primary }, rectRadius: 0.05 });
    s.addText([
      { text: "★  Recommendation: ", options: { fontSize: 15, fontFace: FONT_H, color: C.accent, bold: true } },
      { text: "Start every agent in Review + Reader. Promote permissions later per response plan / task as trust grows.", options: { fontSize: 15, fontFace: FONT_B, color: C.white } },
    ], { x: 0.8, y: 3.6, w: 8.6, h: 1.0, valign: "middle" });
  }

  // S8 Deferral
  deferralSlide(pres);

  pres.writeFile({ fileName: path.join(__dirname, "access-control.pptx") });
  console.log("  ✓ access-control.pptx");
}

// ═══════════════════════════════════════════
// DECK 3 — Operate, Audit, Share
// ═══════════════════════════════════════════
function buildDeck3() {
  const pres = new pptxgen();
  pres.layout = "LAYOUT_16x9";
  pres.author = "Dallas — SRE Agent L200 Workshop";

  // S1 Title
  titleSlide(pres, "Module 8: Operate, Audit, Share", "Level 200  |  20 minutes  |  Click-Through Tour");

  // S2 Session Insights
  {
    const s = contentSlide(pres, "Session Insights");
    s.addText("Monitor → Session Insights", { x: 0.6, y: 1.2, w: 6, h: 0.5, fontSize: 16, fontFace: FONT_H, color: C.muted, italic: true });
    const insights = [
      { label: "Symptoms", desc: "Auto-extracted from the investigation — what the agent detected", color: C.primary },
      { label: "Steps Taken", desc: "Every diagnostic query and action the agent performed", color: C.secondary },
      { label: "Root Cause", desc: "The agent's concluded root cause with supporting evidence", color: C.accent },
      { label: "Pitfalls", desc: "Common misdiagnoses or traps the agent flagged during investigation", color: C.dark },
    ];
    insights.forEach((ins, i) => {
      const y = 1.9 + i * 0.75;
      s.addShape(pres.ShapeType.rect, { x: 0.5, y: y, w: 0.1, h: 0.6, fill: { color: ins.color } });
      s.addText(ins.label, { x: 0.8, y: y, w: 2.2, h: 0.6, fontSize: 15, fontFace: FONT_H, color: ins.color, bold: true, valign: "middle" });
      s.addText(ins.desc, { x: 3.0, y: y, w: 6.8, h: 0.6, fontSize: 13, fontFace: FONT_B, color: C.text, valign: "middle" });
    });
  }

  // S3 Audit Agent Actions
  {
    const s = contentSlide(pres, "Audit Agent Actions");
    s.addText([
      { text: "Full audit trail for every agent action:", options: { fontSize: 16, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "", options: { breakLine: true, fontSize: 6 } },
      { text: "What the agent did — every tool call, query, and remediation step", options: { bullet: true, fontSize: 14, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Who approved — which user authorized the action (Review mode)", options: { bullet: true, fontSize: 14, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Which identity was used — UAMI or OBO token, with scope details", options: { bullet: true, fontSize: 14, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "", options: { breakLine: true, fontSize: 8 } },
      { text: "Tip: Use audit logs for compliance reviews, incident post-mortems, and permission tuning.", options: { fontSize: 13, fontFace: FONT_B, color: C.muted, italic: true, breakLine: true } },
    ], { x: 0.6, y: 1.2, w: 9, h: 3.5, valign: "top" });
  }

  // S4 Share Investigation
  {
    const s = contentSlide(pres, "Share Investigation Threads");
    s.addText("Open thread  →  ⋯ menu  →  Copy link  →  Paste in Teams", {
      x: 0.6, y: 1.3, w: 9, h: 0.6, fontSize: 18, fontFace: FONT_H, color: C.primary, bold: true,
    });

    const steps = [
      { num: "1", text: "Open the investigation thread in SRE Agent" },
      { num: "2", text: 'Click the ⋯ (more) menu at the top of the thread' },
      { num: "3", text: '"Copy link" — generates a shareable deep link' },
      { num: "4", text: "Paste into Teams incident bridge or post-incident review doc" },
    ];
    steps.forEach((st, i) => {
      const y = 2.2 + i * 0.65;
      s.addShape(pres.ShapeType.rect, { x: 0.8, y: y, w: 0.45, h: 0.45, fill: { color: C.primary }, rectRadius: 0.04 });
      s.addText(st.num, { x: 0.8, y: y, w: 0.45, h: 0.45, fontSize: 16, fontFace: FONT_H, color: C.white, bold: true, align: "center", valign: "middle" });
      s.addText(st.text, { x: 1.5, y: y, w: 8, h: 0.45, fontSize: 14, fontFace: FONT_B, color: C.text, valign: "middle" });
    });

    s.addText("Links let anyone with access review the full investigation context — perfect for post-incident reviews.", {
      x: 0.6, y: 4.8, w: 9, h: 0.4, fontSize: 12, fontFace: FONT_B, color: C.muted, italic: true,
    });
  }

  // S5 Memory at Work
  {
    const s = contentSlide(pres, "Memory at Work");
    s.addText([
      { text: "Two key prompts to explore agent memory:", options: { fontSize: 16, fontFace: FONT_B, color: C.text, breakLine: true } },
    ], { x: 0.6, y: 1.2, w: 9, h: 0.5, valign: "top" });

    // prompt boxes
    const prompts = [
      { q: '"What knowledge documents do you have?"', desc: "Lists all knowledge base files — Overview.md and topic files", y: 1.8 },
      { q: '"What have you learned about <app>?"', desc: "Surfaces environment-specific facts, past incident learnings, and runbook content", y: 2.9 },
    ];
    prompts.forEach((p) => {
      s.addShape(pres.ShapeType.rect, { x: 0.6, y: p.y, w: 9, h: 0.9, fill: { color: C.white }, line: { color: C.primary, width: 1 }, rectRadius: 0.04 });
      s.addText(p.q, { x: 0.8, y: p.y + 0.05, w: 8.6, h: 0.4, fontSize: 14, fontFace: FONT_H, color: C.primary, bold: true });
      s.addText(p.desc, { x: 0.8, y: p.y + 0.45, w: 8.6, h: 0.4, fontSize: 12, fontFace: FONT_B, color: C.muted });
    });

    s.addText([
      { text: "Knowledge base pattern:", options: { fontSize: 14, fontFace: FONT_H, color: C.text, bold: true, breakLine: true } },
      { text: "Overview.md (index) + topic-specific files (e.g., app-gateway.md, redis-config.md)", options: { fontSize: 13, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Conceptual overview only — editing knowledge bases is a Level 300 topic.", options: { fontSize: 12, fontFace: FONT_B, color: C.muted, italic: true, breakLine: true } },
    ], { x: 0.6, y: 4.0, w: 9, h: 1.2, valign: "top" });
  }

  // S6 Connector Health
  {
    const s = contentSlide(pres, "Connector Health");
    s.addText("Builder → Connectors → Look for the red badge on collapsed categories", {
      x: 0.6, y: 1.2, w: 9, h: 0.5, fontSize: 15, fontFace: FONT_H, color: C.muted, italic: true,
    });
    s.addText([
      { text: "60-second heartbeat — connectors are checked every minute", options: { bullet: true, fontSize: 15, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Red badge = unhealthy connector — expand the category to see which one", options: { bullet: true, fontSize: 15, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Common causes: expired credentials, network changes, service outages", options: { bullet: true, fontSize: 15, fontFace: FONT_B, color: C.text, breakLine: true } },
      { text: "Fix: Re-authorize or recreate the connector, then verify badge clears", options: { bullet: true, fontSize: 15, fontFace: FONT_B, color: C.text, breakLine: true } },
    ], { x: 0.6, y: 1.9, w: 9, h: 2.5, valign: "top" });

    s.addShape(pres.ShapeType.rect, { x: 2.5, y: 4.3, w: 5.2, h: 0.7, fill: { color: C.dark }, rectRadius: 0.04 });
    s.addText("Healthy connectors = reliable agent actions", {
      x: 2.5, y: 4.3, w: 5.2, h: 0.7, fontSize: 16, fontFace: FONT_H, color: C.accent, bold: true, align: "center", valign: "middle",
    });
  }

  // S7 Deferral
  deferralSlide(pres);

  pres.writeFile({ fileName: path.join(__dirname, "operate-audit-share.pptx") });
  console.log("  ✓ operate-audit-share.pptx");
}

// ═══════════════════════════════════════════
// DECK 4 — Wrap-Up
// ═══════════════════════════════════════════
function buildDeck4() {
  const pres = new pptxgen();
  pres.layout = "LAYOUT_16x9";
  pres.author = "Dallas — SRE Agent L200 Workshop";

  // S1 Title
  titleSlide(pres, "Module 9: Wrap-Up +\nBridge to Level 300", "Level 100  |  15 minutes");

  // S2 Recap — 5 Things
  {
    const s = contentSlide(pres, "5 Things Every Team Member Should Do Day-to-Day");
    const items = [
      "Ask the agent before opening 5 portal tabs",
      "Use Deep Investigation for the gnarly stuff",
      "#remember env-specific facts your team would re-explain",
      "Upload runbooks instead of emailing them",
      "Share investigation thread links in incident bridges",
    ];
    items.forEach((item, i) => {
      const y = 1.3 + i * 0.7;
      s.addShape(pres.ShapeType.rect, { x: 0.6, y: y, w: 0.5, h: 0.5, fill: { color: C.primary }, rectRadius: 0.04 });
      s.addText(String(i + 1), { x: 0.6, y: y, w: 0.5, h: 0.5, fontSize: 18, fontFace: FONT_H, color: C.white, bold: true, align: "center", valign: "middle" });
      s.addText(item, { x: 1.3, y: y, w: 8.4, h: 0.5, fontSize: 15, fontFace: FONT_B, color: C.text, valign: "middle" });
    });
  }

  // S3 L300 Backlog Table
  {
    const s = contentSlide(pres, "Level 300 Backlog — What's Next");
    const rows = [
      ["Topic", "Why Deferred"],
      ["Incident platforms & Response Plans", "Requires platform integration setup"],
      ["Deep Investigation Mode 2", "Advanced multi-step orchestration"],
      ["Privileged permission + Autonomous mode", "Needs trust baseline from L200 labs"],
      ["MCP custom connectors + 80-tool budget", "Advanced connector authoring"],
      ["Skills authoring", "Custom prompt engineering"],
      ["Custom Agents in YAML", "Multi-agent orchestration patterns"],
      ["Custom tools + Code Interpreter", "Python tool development"],
      ["Agent Hooks", "Event-driven automation"],
      ["Knowledge base deep dive", "Advanced memory management"],
      ["Cross-tenant connectors, VNET isolation", "Enterprise network architecture"],
      ["Plugin Marketplace", "Ecosystem & governance"],
      ["Agent Playground", "Experimentation & testing sandbox"],
    ];
    const tableOpts = {
      x: 0.4, y: 1.1, w: 9.4, h: 4.2,
      fontSize: 10,
      fontFace: FONT_B,
      color: C.text,
      border: { type: "solid", pt: 0.5, color: "CBD5E1" },
      colW: [4.5, 4.9],
      autoPage: false,
      rowH: [0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3],
    };
    // Build row options
    const tableRows = rows.map((r, i) => {
      if (i === 0) {
        return [
          { text: r[0], options: { bold: true, fontSize: 11, fontFace: FONT_H, color: C.white, fill: { color: C.dark }, valign: "middle" } },
          { text: r[1], options: { bold: true, fontSize: 11, fontFace: FONT_H, color: C.white, fill: { color: C.dark }, valign: "middle" } },
        ];
      }
      const bg = i % 2 === 0 ? "E8F0FE" : C.white;
      return [
        { text: r[0], options: { fontSize: 10, fontFace: FONT_B, color: C.text, fill: { color: bg }, valign: "middle" } },
        { text: r[1], options: { fontSize: 10, fontFace: FONT_B, color: C.muted, fill: { color: bg }, valign: "middle" } },
      ];
    });
    s.addTable(tableRows, tableOpts);
  }

  // S4 Resources
  {
    const s = contentSlide(pres, "Resources & Reference Links");
    const links = [
      { label: "Foundations", url: "https://learn.microsoft.com/azure/sre-agent/overview" },
      { label: "Concepts", url: "https://learn.microsoft.com/azure/sre-agent/concepts" },
      { label: "Capabilities", url: "https://learn.microsoft.com/azure/sre-agent/capabilities" },
      { label: "Tutorials", url: "https://learn.microsoft.com/azure/sre-agent/tutorials" },
      { label: "Samples & Templates", url: "https://learn.microsoft.com/azure/sre-agent/samples" },
    ];
    links.forEach((l, i) => {
      const y = 1.4 + i * 0.65;
      s.addShape(pres.ShapeType.rect, { x: 0.5, y: y, w: 0.1, h: 0.5, fill: { color: C.accent } });
      s.addText(l.label, { x: 0.8, y: y, w: 2.5, h: 0.5, fontSize: 16, fontFace: FONT_H, color: C.primary, bold: true, valign: "middle" });
      s.addText(l.url, { x: 3.3, y: y, w: 6.5, h: 0.5, fontSize: 13, fontFace: FONT_B, color: C.muted, valign: "middle" });
    });
  }

  // S5 Thank You / Q&A
  {
    const s = pres.addSlide();
    s.background = { fill: C.dark };
    s.addShape(pres.ShapeType.rect, { x: 0, y: 0, w: 0.15, h: "100%", fill: { color: C.accent } });
    s.addText("Thank You!", { x: 0.8, y: 1.0, w: 8.5, h: 1.2, fontSize: 42, fontFace: FONT_H, color: C.white, bold: true });
    s.addText("Questions & Answers", { x: 0.8, y: 2.3, w: 8.5, h: 0.7, fontSize: 24, fontFace: FONT_B, color: C.accent });
    s.addShape(pres.ShapeType.rect, { x: 0.8, y: 3.3, w: 8.5, h: 0.03, fill: { color: C.accent } });
    s.addText("Please complete the post-workshop feedback survey!", {
      x: 0.8, y: 3.6, w: 8.5, h: 0.6, fontSize: 18, fontFace: FONT_B, color: C.white,
    });
    s.addText("aka.ms/sre-agent-l200-feedback", {
      x: 0.8, y: 4.2, w: 8.5, h: 0.5, fontSize: 16, fontFace: FONT_B, color: C.accent,
    });
  }

  pres.writeFile({ fileName: path.join(__dirname, "wrapup.pptx") });
  console.log("  ✓ wrapup.pptx");
}

// ── Main ──
async function main() {
  console.log("Generating SRE Agent L200 slide decks...\n");
  await buildDeck1();
  await buildDeck2();
  await buildDeck3();
  await buildDeck4();
  console.log("\nAll 4 decks generated successfully!");
}

main().catch((e) => { console.error("ERROR:", e); process.exit(1); });
