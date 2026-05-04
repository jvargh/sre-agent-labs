const pptxgen = require("pptxgenjs");
const path = require("path");

const pres = new pptxgen();
pres.layout = "LAYOUT_16x9";
pres.author = "SRE Agent Workshop";
pres.title = "Promotion Playbook";

// Theme: Midnight Executive
const NAVY = "1E2761";
const ICE = "CADCFC";
const WHITE = "FFFFFF";
const HEADER_FONT = "Georgia";
const BODY_FONT = "Calibri";

// Helper: slide number footer
function addFooter(slide, num) {
  slide.addText(`${num} / 8`, {
    x: 8.8, y: 5.2, w: 1, h: 0.3,
    fontSize: 9, color: ICE, fontFace: BODY_FONT, align: "right",
  });
}

// ── Slide 1: Title ──
(() => {
  const s = pres.addSlide();
  s.background = { color: NAVY };
  // Accent bar top
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.06, fill: { color: ICE } });
  s.addText("Lab 1", {
    x: 0.8, y: 1.2, w: 8.4, h: 0.7,
    fontSize: 20, fontFace: BODY_FONT, color: ICE, bold: true,
  });
  s.addText("Promotion Playbook", {
    x: 0.8, y: 1.8, w: 8.4, h: 1.2,
    fontSize: 42, fontFace: HEADER_FONT, color: WHITE, bold: true,
  });
  s.addText("Privileged + Autonomous Safely", {
    x: 0.8, y: 3.0, w: 8.4, h: 0.6,
    fontSize: 22, fontFace: HEADER_FONT, color: ICE, italic: true,
  });
  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 3.9, w: 2.5, h: 0.03, fill: { color: ICE } });
  s.addText("L300 SRE Agent Workshop", {
    x: 0.8, y: 4.1, w: 8.4, h: 0.5,
    fontSize: 14, fontFace: BODY_FONT, color: ICE,
  });
})();

// ── Slide 2: Why This Matters ──
(() => {
  const s = pres.addSlide();
  s.background = { color: WHITE };
  addFooter(s, 2);
  s.addText("Why This Matters", {
    x: 0.8, y: 0.4, w: 8.4, h: 0.7,
    fontSize: 36, fontFace: HEADER_FONT, color: NAVY, bold: true,
  });

  // Two-column layout
  // Left: L200 recap
  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 1.5, w: 3.8, h: 3.2, fill: { color: "F0F3FA" } });
  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 1.5, w: 0.08, h: 3.2, fill: { color: ICE } });
  s.addText("L200 Ended With", {
    x: 1.1, y: 1.6, w: 3.3, h: 0.5,
    fontSize: 18, fontFace: HEADER_FONT, color: NAVY, bold: true,
  });
  s.addText([
    { text: '"Start in Reader / Review mode"', options: { fontSize: 16, fontFace: BODY_FONT, color: "444444", italic: true, breakLine: true } },
    { text: "", options: { fontSize: 10, breakLine: true } },
    { text: "Safe default. Minimal permissions.", options: { fontSize: 14, fontFace: BODY_FONT, color: "666666", breakLine: true } },
    { text: "Human approves every action.", options: { fontSize: 14, fontFace: BODY_FONT, color: "666666" } },
  ], { x: 1.1, y: 2.2, w: 3.3, h: 2.2, valign: "top" });

  // Right: L300 mission
  s.addShape(pres.shapes.RECTANGLE, { x: 5.4, y: 1.5, w: 3.8, h: 3.2, fill: { color: NAVY } });
  s.addText("L300 Starts With", {
    x: 5.7, y: 1.6, w: 3.3, h: 0.5,
    fontSize: 18, fontFace: HEADER_FONT, color: ICE, bold: true,
  });
  s.addText([
    { text: '"Justify every step away\nfrom that default."', options: { fontSize: 16, fontFace: BODY_FONT, color: WHITE, italic: true, breakLine: true } },
    { text: "", options: { fontSize: 10, breakLine: true } },
    { text: "Scoped privilege escalation.", options: { fontSize: 14, fontFace: BODY_FONT, color: ICE, breakLine: true } },
    { text: "Autonomous only with hooks.", options: { fontSize: 14, fontFace: BODY_FONT, color: ICE } },
  ], { x: 5.7, y: 2.2, w: 3.3, h: 2.2, valign: "top" });
})();

// ── Slide 3: Decision Matrix ──
(() => {
  const s = pres.addSlide();
  s.background = { color: WHITE };
  addFooter(s, 3);
  s.addText("Decision Matrix", {
    x: 0.8, y: 0.3, w: 8.4, h: 0.6,
    fontSize: 36, fontFace: HEADER_FONT, color: NAVY, bold: true,
  });
  s.addText("Per-trigger decision grid — fill this for YOUR service in the exercise", {
    x: 0.8, y: 0.85, w: 8.4, h: 0.35,
    fontSize: 12, fontFace: BODY_FONT, color: "888888", italic: true,
  });

  const headerOpts = { fill: { color: NAVY }, color: WHITE, bold: true, fontSize: 9, fontFace: BODY_FONT, align: "center", valign: "middle" };
  const cellOpts = { fontSize: 9, fontFace: BODY_FONT, color: "333333", align: "center", valign: "middle" };
  const altRow = { ...cellOpts, fill: { color: "F0F3FA" } };

  const rows = [
    [
      { text: "Per-trigger decision", options: headerOpts },
      { text: "Read-only\nchat", options: headerOpts },
      { text: "Sched. task\n(notif. only)", options: headerOpts },
      { text: "Sched. task\n(Azure read)", options: headerOpts },
      { text: "Sched. task\n(Azure write)", options: headerOpts },
      { text: "Resp. plan\n(low sev)", options: headerOpts },
      { text: "Resp. plan\n(P1/P2)", options: headerOpts },
    ],
    [
      { text: "Permission level", options: { ...cellOpts, bold: true, fill: { color: "F0F3FA" } } },
      { text: "Reader", options: altRow },
      { text: "Reader", options: altRow },
      { text: "Reader", options: altRow },
      { text: "Privileged\n(scoped)", options: altRow },
      { text: "Reader", options: altRow },
      { text: "Privileged\n(scoped)", options: altRow },
    ],
    [
      { text: "Run mode", options: { ...cellOpts, bold: true } },
      { text: "Review", options: cellOpts },
      { text: "Autonomous", options: cellOpts },
      { text: "Autonomous", options: cellOpts },
      { text: "Review \u2192\nAutonomous\nafter bake-in", options: cellOpts },
      { text: "Review", options: cellOpts },
      { text: "Autonomous\nw/ Hooks (Lab 9)", options: cellOpts },
    ],
    [
      { text: "Deep investigation", options: { ...cellOpts, bold: true, fill: { color: "F0F3FA" } } },
      { text: "On-demand", options: altRow },
      { text: "Off", options: altRow },
      { text: "Off", options: altRow },
      { text: "Off", options: altRow },
      { text: "Off", options: altRow },
      { text: "On\n(Mode 2)", options: altRow },
    ],
    [
      { text: "Approver pool size", options: { ...cellOpts, bold: true } },
      { text: "n/a", options: cellOpts },
      { text: "0", options: cellOpts },
      { text: "0", options: cellOpts },
      { text: "\u2265 2 SRE\nAgent Admins", options: cellOpts },
      { text: "\u2265 2", options: cellOpts },
      { text: "\u2265 2, on-call\nrotation", options: cellOpts },
    ],
  ];

  s.addTable(rows, {
    x: 0.3, y: 1.35, w: 9.4,
    colW: [1.3, 1.2, 1.2, 1.2, 1.35, 1.2, 1.35],
    rowH: [0.55, 0.55, 0.7, 0.55, 0.6],
    border: { pt: 0.5, color: "CCCCCC" },
    margin: [2, 4, 2, 4],
  });
})();

// ── Slide 4: Core L300 Rule ──
(() => {
  const s = pres.addSlide();
  s.background = { color: NAVY };
  addFooter(s, 4);
  s.addText("Core L300 Rule", {
    x: 0.8, y: 0.4, w: 8.4, h: 0.7,
    fontSize: 36, fontFace: HEADER_FONT, color: WHITE, bold: true,
  });

  // Big callout box
  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 1.5, w: 8.4, h: 2.0, fill: { color: "253580" } });
  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 1.5, w: 0.1, h: 2.0, fill: { color: ICE } });

  s.addText("\u26A0", { x: 1.2, y: 1.65, w: 0.6, h: 0.6, fontSize: 32, align: "center", color: ICE });

  s.addText("Run Modes do NOT gate non-Azure tool calls.", {
    x: 2.0, y: 1.6, w: 6.8, h: 0.6,
    fontSize: 22, fontFace: HEADER_FONT, color: WHITE, bold: true,
  });
  s.addText("Email, Teams, MCP — all unaffected by Run Mode settings.", {
    x: 2.0, y: 2.15, w: 6.8, h: 0.4,
    fontSize: 15, fontFace: BODY_FONT, color: ICE,
  });
  s.addText("Hooks do. (Lab 9)", {
    x: 2.0, y: 2.6, w: 6.8, h: 0.4,
    fontSize: 18, fontFace: HEADER_FONT, color: ICE, bold: true, italic: true,
  });

  // Warning example
  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 3.9, w: 8.4, h: 1.3, fill: { color: "1A1F4E" } });
  s.addText([
    { text: "Don't: ", options: { bold: true, color: "FF6B6B", fontSize: 14, fontFace: BODY_FONT, breakLine: false } },
    { text: "Promote to Autonomous on a custom agent that has a ", options: { color: WHITE, fontSize: 14, fontFace: BODY_FONT } },
    { text: "SendOutlookEmail", options: { color: ICE, fontSize: 14, fontFace: "Consolas", bold: true } },
    { text: " tool AND an ", options: { color: WHITE, fontSize: 14, fontFace: BODY_FONT } },
    { text: "az ... write", options: { color: ICE, fontSize: 14, fontFace: "Consolas", bold: true } },
    { text: " tool without a PostToolUse hook.", options: { color: WHITE, fontSize: 14, fontFace: BODY_FONT } },
  ], { x: 1.1, y: 4.0, w: 7.8, h: 1.0, valign: "middle" });
})();

// ── Slide 5: The Safety Chain ──
(() => {
  const s = pres.addSlide();
  s.background = { color: WHITE };
  addFooter(s, 5);
  s.addText("The Safety Chain", {
    x: 0.8, y: 0.3, w: 8.4, h: 0.7,
    fontSize: 36, fontFace: HEADER_FONT, color: NAVY, bold: true,
  });

  const boxes = [
    { label: "Reader", sub: "Default start", color: "4CAF50", x: 0.3 },
    { label: "Privileged\n(scoped)", sub: "Justified escalation", color: "2196F3", x: 2.6 },
    { label: "Autonomous\nw/ Hooks", sub: "Lab 9 hooks required", color: "FF9800", x: 4.9 },
    { label: "\u2718 NEVER", sub: "Autonomous without\nhooks on write tools", color: "E53935", x: 7.2 },
  ];

  boxes.forEach((b, i) => {
    const yTop = 1.5;
    s.addShape(pres.shapes.RECTANGLE, {
      x: b.x, y: yTop, w: 2.1, h: 1.6,
      fill: { color: b.color },
      shadow: { type: "outer", blur: 4, offset: 2, angle: 135, color: "000000", opacity: 0.12 },
    });
    s.addText(b.label, {
      x: b.x, y: yTop + 0.15, w: 2.1, h: 0.85,
      fontSize: 16, fontFace: HEADER_FONT, color: WHITE, bold: true, align: "center", valign: "middle",
    });
    s.addText(b.sub, {
      x: b.x, y: yTop + 0.95, w: 2.1, h: 0.55,
      fontSize: 10, fontFace: BODY_FONT, color: WHITE, align: "center", valign: "top",
    });

    // Arrow between boxes
    if (i < 3) {
      s.addText("\u2192", {
        x: b.x + 2.1, y: yTop + 0.4, w: 0.5, h: 0.6,
        fontSize: 28, color: NAVY, align: "center", valign: "middle", fontFace: BODY_FONT,
      });
    }
  });

  // Bottom note
  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 3.7, w: 8.4, h: 1.4, fill: { color: "FFF3E0" } });
  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 3.7, w: 0.08, h: 1.4, fill: { color: "FF9800" } });
  s.addText([
    { text: "Key principle: ", options: { bold: true, fontSize: 14, fontFace: BODY_FONT, color: NAVY } },
    { text: "Each step right requires explicit justification. Never skip steps. Hooks (Lab 9) are the safety net that makes Autonomous viable for write operations.", options: { fontSize: 14, fontFace: BODY_FONT, color: "444444" } },
  ], { x: 1.1, y: 3.8, w: 7.8, h: 1.1, valign: "middle" });
})();

// ── Slide 6: Paired Exercise ──
(() => {
  const s = pres.addSlide();
  s.background = { color: WHITE };
  addFooter(s, 6);
  s.addText("Paired Exercise", {
    x: 0.8, y: 0.3, w: 6, h: 0.7,
    fontSize: 36, fontFace: HEADER_FONT, color: NAVY, bold: true,
  });
  s.addShape(pres.shapes.RECTANGLE, { x: 8.0, y: 0.35, w: 1.5, h: 0.5, fill: { color: ICE } });
  s.addText("15 min", {
    x: 8.0, y: 0.35, w: 1.5, h: 0.5,
    fontSize: 16, fontFace: BODY_FONT, color: NAVY, bold: true, align: "center", valign: "middle",
  });

  s.addText("Fill the Decision Matrix for YOUR service", {
    x: 0.8, y: 1.2, w: 8.4, h: 0.5,
    fontSize: 20, fontFace: HEADER_FONT, color: NAVY, italic: true,
  });

  const steps = [
    { num: "1", text: "Identify your service's triggers (alerts, scheduled tasks, chat interactions)" },
    { num: "2", text: "For each trigger, determine the Permission Level needed (Reader vs Privileged)" },
    { num: "3", text: "Set the Run Mode — start with Review unless audit data justifies Autonomous" },
    { num: "4", text: "Name specific approvers from your team (\u2265 2 SRE Agent Admins for write)" },
    { num: "5", text: "Decide Deep Investigation settings per trigger type" },
  ];

  steps.forEach((step, i) => {
    const y = 1.9 + i * 0.6;
    s.addShape(pres.shapes.OVAL, { x: 0.8, y: y, w: 0.4, h: 0.4, fill: { color: NAVY } });
    s.addText(step.num, {
      x: 0.8, y: y, w: 0.4, h: 0.4,
      fontSize: 14, fontFace: BODY_FONT, color: WHITE, bold: true, align: "center", valign: "middle",
    });
    s.addText(step.text, {
      x: 1.4, y: y, w: 8.0, h: 0.4,
      fontSize: 14, fontFace: BODY_FONT, color: "333333", valign: "middle",
    });
  });

  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 4.7, w: 8.4, h: 0.6, fill: { color: "F0F3FA" } });
  s.addText("Trainer reviews 3 examples live after the exercise.", {
    x: 1.0, y: 4.7, w: 8.0, h: 0.6,
    fontSize: 13, fontFace: BODY_FONT, color: NAVY, italic: true, valign: "middle",
  });
})();

// ── Slide 7: What We Defer to L400 ──
(() => {
  const s = pres.addSlide();
  s.background = { color: NAVY };
  addFooter(s, 7);
  s.addText("What We Defer to L400", {
    x: 0.8, y: 0.4, w: 8.4, h: 0.7,
    fontSize: 36, fontFace: HEADER_FONT, color: WHITE, bold: true,
  });

  const items = [
    { lab: "Lab 9", title: "Agent Hooks", desc: "Stop hooks, PostToolUse hooks — the safety net for Autonomous mode" },
    { lab: "Lab 10", title: "Audit & Observability", desc: "IncidentActivitySnapshot workbook, token-spend tracking" },
    { lab: "Lab 11", title: "Enterprise Topology", desc: "VNET isolation, cross-tenant connectors, Agent Identity sidecar" },
    { lab: "Lab 12", title: "Config-as-Code", desc: "Agent IaC PR workflow, YAML-defined custom agents in source control" },
  ];

  items.forEach((item, i) => {
    const y = 1.4 + i * 0.95;
    s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: y, w: 8.4, h: 0.8, fill: { color: "253580" } });
    s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: y, w: 0.08, h: 0.8, fill: { color: ICE } });
    s.addText(item.lab, {
      x: 1.1, y: y, w: 0.7, h: 0.8,
      fontSize: 18, fontFace: HEADER_FONT, color: ICE, bold: true, valign: "middle",
    });
    s.addText(item.title, {
      x: 1.9, y: y + 0.05, w: 7.0, h: 0.4,
      fontSize: 16, fontFace: HEADER_FONT, color: WHITE, bold: true,
    });
    s.addText(item.desc, {
      x: 1.9, y: y + 0.4, w: 7.0, h: 0.35,
      fontSize: 12, fontFace: BODY_FONT, color: ICE,
    });
  });
})();

// ── Slide 8: References ──
(() => {
  const s = pres.addSlide();
  s.background = { color: WHITE };
  addFooter(s, 8);
  s.addText("References", {
    x: 0.8, y: 0.3, w: 8.4, h: 0.7,
    fontSize: 36, fontFace: HEADER_FONT, color: NAVY, bold: true,
  });

  const refs = [
    { cat: "Capabilities", links: [
      "Incident Response Plans — sre.azure.com/docs/capabilities/incident-response-plans",
      "Deep Investigation — sre.azure.com/docs/capabilities/deep-investigation",
      "Agent Hooks — sre.azure.com/docs/capabilities/agent-hooks",
    ]},
    { cat: "Tutorials", links: [
      "Manage Permissions — sre.azure.com/docs/tutorials/agent-config/*",
      "Setup Response Plan — sre.azure.com/docs/tutorials/agent-config/*",
    ]},
    { cat: "Concepts", links: [
      "Agent Identity — sre.azure.com/docs/concepts/agent-identity",
      "Agent Reasoning — sre.azure.com/docs/concepts/agent-reasoning",
    ]},
  ];

  let y = 1.2;
  refs.forEach((section) => {
    s.addText(section.cat, {
      x: 0.8, y: y, w: 8.4, h: 0.4,
      fontSize: 16, fontFace: HEADER_FONT, color: NAVY, bold: true,
    });
    y += 0.4;
    section.links.forEach((link) => {
      s.addText([{ text: link, options: { bullet: true, fontSize: 11, fontFace: BODY_FONT, color: "555555" } }], {
        x: 1.0, y: y, w: 8.2, h: 0.3,
      });
      y += 0.3;
    });
    y += 0.15;
  });
})();

const outPath = path.join(__dirname, "lab-01-promotion-playbook.pptx");
pres.writeFile({ fileName: outPath }).then(() => {
  console.log("Created: " + outPath);
}).catch(err => {
  console.error("Error:", err);
  process.exit(1);
});
