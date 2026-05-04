const pptxgen = require("pptxgenjs");
const path = require("path");

const pres = new pptxgen();
pres.layout = "LAYOUT_16x9";
pres.author = "SRE Agent Workshop";
pres.title = "Module 11: Enterprise Topology";

// Theme: Ocean Gradient
const DEEP = "065A82";
const TEAL = "1C7293";
const MIDNIGHT = "21295C";
const WHITE = "FFFFFF";
const LIGHT_BG = "F0F6FA";
const HEADER_FONT = "Trebuchet MS";
const BODY_FONT = "Calibri";

function addFooter(slide, num) {
  slide.addText(`${num} / 8`, {
    x: 8.8, y: 5.2, w: 1, h: 0.3,
    fontSize: 9, color: TEAL, fontFace: BODY_FONT, align: "right",
  });
}

// ── Slide 1: Title ──
(() => {
  const s = pres.addSlide();
  s.background = { color: MIDNIGHT };
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.06, fill: { color: TEAL } });
  // Decorative side bar
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 0.15, h: 5.625, fill: { color: DEEP } });

  s.addText("Module 11", {
    x: 0.8, y: 1.2, w: 8.4, h: 0.7,
    fontSize: 20, fontFace: BODY_FONT, color: TEAL, bold: true,
  });
  s.addText("Enterprise Topology", {
    x: 0.8, y: 1.8, w: 8.4, h: 1.2,
    fontSize: 44, fontFace: HEADER_FONT, color: WHITE, bold: true,
  });
  s.addText("VNET  \u00B7  Cross-Tenant  \u00B7  Agent Identity", {
    x: 0.8, y: 3.0, w: 8.4, h: 0.6,
    fontSize: 18, fontFace: BODY_FONT, color: TEAL, italic: true,
  });
  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 3.8, w: 2.5, h: 0.03, fill: { color: TEAL } });
  s.addText("L400 SRE Agent Workshop  \u00B7  90 min", {
    x: 0.8, y: 4.0, w: 8.4, h: 0.5,
    fontSize: 14, fontFace: BODY_FONT, color: TEAL,
  });
})();

// ── Slide 2: Three Pillars ──
(() => {
  const s = pres.addSlide();
  s.background = { color: WHITE };
  addFooter(s, 2);
  s.addText("Three Pillars", {
    x: 0.8, y: 0.3, w: 8.4, h: 0.7,
    fontSize: 36, fontFace: HEADER_FONT, color: MIDNIGHT, bold: true,
  });

  const pillars = [
    { icon: "\uD83D\uDD12", title: "VNET-Isolated\nObservability", desc: "Agent reaches private App Insights / Log Analytics behind private endpoints. NSG & private DNS topology.", color: DEEP },
    { icon: "\uD83D\uDD17", title: "Cross-Tenant\nConnectors", desc: "Agent and monitored resources in different tenants. Managed-identity federation and consent flow.", color: TEAL },
    { icon: "\uD83D\uDC64", title: "Agent Identity\nSidecar", desc: "UAMI, separate Entra app registration when needed, OBO patterns for non-Entra users.", color: MIDNIGHT },
  ];

  pillars.forEach((p, i) => {
    const x = 0.5 + i * 3.15;
    s.addShape(pres.shapes.RECTANGLE, {
      x: x, y: 1.3, w: 2.85, h: 3.8,
      fill: { color: "F4F8FB" },
      shadow: { type: "outer", blur: 4, offset: 2, angle: 135, color: "000000", opacity: 0.08 },
    });
    // Icon circle
    s.addShape(pres.shapes.OVAL, { x: x + 0.95, y: 1.55, w: 0.9, h: 0.9, fill: { color: p.color } });
    s.addText(p.icon, {
      x: x + 0.95, y: 1.55, w: 0.9, h: 0.9,
      fontSize: 28, align: "center", valign: "middle",
    });
    s.addText(p.title, {
      x: x + 0.15, y: 2.65, w: 2.55, h: 0.8,
      fontSize: 16, fontFace: HEADER_FONT, color: MIDNIGHT, bold: true, align: "center", valign: "middle",
    });
    s.addText(p.desc, {
      x: x + 0.2, y: 3.5, w: 2.45, h: 1.3,
      fontSize: 12, fontFace: BODY_FONT, color: "555555", align: "center", valign: "top",
    });
  });
})();

// ── Slide 3: VNET-Isolated Observability ──
(() => {
  const s = pres.addSlide();
  s.background = { color: LIGHT_BG };
  addFooter(s, 3);
  s.addText("VNET-Isolated Observability", {
    x: 0.8, y: 0.3, w: 8.4, h: 0.7,
    fontSize: 32, fontFace: HEADER_FONT, color: MIDNIGHT, bold: true,
  });
  s.addText("capabilities/azure-observability-vnet", {
    x: 0.8, y: 0.9, w: 8.4, h: 0.3,
    fontSize: 11, fontFace: "Consolas", color: TEAL, italic: true,
  });

  // Diagram-style layout: 3 boxes with arrows
  const boxY = 1.6;
  // SRE Agent box
  s.addShape(pres.shapes.RECTANGLE, { x: 0.5, y: boxY, w: 2.2, h: 1.2, fill: { color: DEEP } });
  s.addText("SRE Agent", { x: 0.5, y: boxY, w: 2.2, h: 0.6, fontSize: 15, fontFace: HEADER_FONT, color: WHITE, bold: true, align: "center", valign: "middle" });
  s.addText("(Managed Service)", { x: 0.5, y: boxY + 0.55, w: 2.2, h: 0.5, fontSize: 10, fontFace: BODY_FONT, color: TEAL, align: "center" });

  // Arrow
  s.addText("\u2192", { x: 2.7, y: boxY + 0.2, w: 0.6, h: 0.6, fontSize: 28, color: MIDNIGHT, align: "center", valign: "middle" });

  // Private Endpoint box
  s.addShape(pres.shapes.RECTANGLE, { x: 3.3, y: boxY, w: 2.8, h: 1.2, fill: { color: TEAL } });
  s.addText("Private Endpoint", { x: 3.3, y: boxY, w: 2.8, h: 0.6, fontSize: 15, fontFace: HEADER_FONT, color: WHITE, bold: true, align: "center", valign: "middle" });
  s.addText("VNET + Private DNS Zone", { x: 3.3, y: boxY + 0.55, w: 2.8, h: 0.5, fontSize: 10, fontFace: BODY_FONT, color: WHITE, align: "center" });

  // Arrow
  s.addText("\u2192", { x: 6.1, y: boxY + 0.2, w: 0.6, h: 0.6, fontSize: 28, color: MIDNIGHT, align: "center", valign: "middle" });

  // App Insights / LA box
  s.addShape(pres.shapes.RECTANGLE, { x: 6.7, y: boxY, w: 2.8, h: 1.2, fill: { color: MIDNIGHT } });
  s.addText("App Insights /\nLog Analytics", { x: 6.7, y: boxY, w: 2.8, h: 0.7, fontSize: 14, fontFace: HEADER_FONT, color: WHITE, bold: true, align: "center", valign: "middle" });
  s.addText("(Private, no public access)", { x: 6.7, y: boxY + 0.7, w: 2.8, h: 0.4, fontSize: 10, fontFace: BODY_FONT, color: TEAL, align: "center" });

  // Requirements section
  s.addText("Required Topology", {
    x: 0.8, y: 3.2, w: 8.4, h: 0.5,
    fontSize: 18, fontFace: HEADER_FONT, color: MIDNIGHT, bold: true,
  });

  const reqs = [
    "NSG rules allowing agent's managed VNET to reach private endpoints",
    "Private DNS zone linked to agent's VNET for *.privatelink.monitor.azure.com",
    "Application Insights & Log Analytics workspace with public network access disabled",
    "AMPLS (Azure Monitor Private Link Scope) connecting workspaces to private endpoints",
  ];

  s.addText(reqs.map((r, i) => ({
    text: r,
    options: { bullet: true, fontSize: 12, fontFace: BODY_FONT, color: "444444", breakLine: i < reqs.length - 1 },
  })), { x: 0.8, y: 3.7, w: 8.4, h: 1.6, valign: "top" });
})();

// ── Slide 4: Cross-Tenant Connectors ──
(() => {
  const s = pres.addSlide();
  s.background = { color: WHITE };
  addFooter(s, 4);
  s.addText("Cross-Tenant Connectors", {
    x: 0.8, y: 0.3, w: 8.4, h: 0.7,
    fontSize: 32, fontFace: HEADER_FONT, color: MIDNIGHT, bold: true,
  });
  s.addText("capabilities/cross-tenant-access", {
    x: 0.8, y: 0.9, w: 8.4, h: 0.3,
    fontSize: 11, fontFace: "Consolas", color: TEAL, italic: true,
  });

  // Two-tenant diagram
  // Tenant A
  s.addShape(pres.shapes.RECTANGLE, { x: 0.5, y: 1.5, w: 4.0, h: 2.8, fill: { color: "E8F4F8" } });
  s.addShape(pres.shapes.RECTANGLE, { x: 0.5, y: 1.5, w: 4.0, h: 0.45, fill: { color: DEEP } });
  s.addText("Primary Tenant (Agent Home)", { x: 0.5, y: 1.5, w: 4.0, h: 0.45, fontSize: 12, fontFace: HEADER_FONT, color: WHITE, bold: true, align: "center", valign: "middle" });

  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 2.2, w: 3.4, h: 0.55, fill: { color: DEEP } });
  s.addText("SRE Agent + UAMI", { x: 0.8, y: 2.2, w: 3.4, h: 0.55, fontSize: 13, fontFace: BODY_FONT, color: WHITE, align: "center", valign: "middle" });

  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 3.0, w: 3.4, h: 0.55, fill: { color: TEAL } });
  s.addText("Managed-Identity Federation", { x: 0.8, y: 3.0, w: 3.4, h: 0.55, fontSize: 12, fontFace: BODY_FONT, color: WHITE, align: "center", valign: "middle" });

  // Tenant B
  s.addShape(pres.shapes.RECTANGLE, { x: 5.5, y: 1.5, w: 4.0, h: 2.8, fill: { color: "F0ECF8" } });
  s.addShape(pres.shapes.RECTANGLE, { x: 5.5, y: 1.5, w: 4.0, h: 0.45, fill: { color: MIDNIGHT } });
  s.addText("Remote Tenant (Monitored)", { x: 5.5, y: 1.5, w: 4.0, h: 0.45, fontSize: 12, fontFace: HEADER_FONT, color: WHITE, bold: true, align: "center", valign: "middle" });

  s.addShape(pres.shapes.RECTANGLE, { x: 5.8, y: 2.2, w: 3.4, h: 0.55, fill: { color: MIDNIGHT } });
  s.addText("Monitored Resources", { x: 5.8, y: 2.2, w: 3.4, h: 0.55, fontSize: 13, fontFace: BODY_FONT, color: WHITE, align: "center", valign: "middle" });

  s.addShape(pres.shapes.RECTANGLE, { x: 5.8, y: 3.0, w: 3.4, h: 0.55, fill: { color: "6A5ACD" } });
  s.addText("Consent Flow (Entra Admin)", { x: 5.8, y: 3.0, w: 3.4, h: 0.55, fontSize: 12, fontFace: BODY_FONT, color: WHITE, align: "center", valign: "middle" });

  // Arrow between tenants
  s.addShape(pres.shapes.LINE, { x: 4.5, y: 2.47, w: 1.0, h: 0, line: { color: MIDNIGHT, width: 2, dashType: "dash" } });
  s.addText("\u2194", { x: 4.5, y: 2.1, w: 1.0, h: 0.5, fontSize: 22, color: MIDNIGHT, align: "center", valign: "middle", bold: true });

  // Key points
  s.addText("Key Concepts", {
    x: 0.8, y: 4.5, w: 2.0, h: 0.4,
    fontSize: 14, fontFace: HEADER_FONT, color: MIDNIGHT, bold: true,
  });
  s.addText([
    { text: "Agent and monitored resources live in different tenants", options: { bullet: true, fontSize: 11, fontFace: BODY_FONT, color: "555555", breakLine: true } },
    { text: "Managed-identity federation bridges trust boundary", options: { bullet: true, fontSize: 11, fontFace: BODY_FONT, color: "555555", breakLine: true } },
    { text: "Entra admin consent required on remote tenant side", options: { bullet: true, fontSize: 11, fontFace: BODY_FONT, color: "555555" } },
  ], { x: 2.8, y: 4.45, w: 6.5, h: 0.9 });
})();

// ── Slide 5: Agent Identity ──
(() => {
  const s = pres.addSlide();
  s.background = { color: MIDNIGHT };
  addFooter(s, 5);
  s.addText("Agent Identity", {
    x: 0.8, y: 0.3, w: 8.4, h: 0.7,
    fontSize: 36, fontFace: HEADER_FONT, color: WHITE, bold: true,
  });
  s.addText("concepts/agent-identity", {
    x: 0.8, y: 0.9, w: 8.4, h: 0.3,
    fontSize: 11, fontFace: "Consolas", color: TEAL, italic: true,
  });

  const items = [
    { title: "UAMI (User-Assigned Managed Identity)", desc: "Default identity for built-in connectors. Scoped to the agent's resource group. No secret management needed.", color: DEEP },
    { title: "Separate Entra App Registration", desc: "Required when the agent needs permissions beyond what UAMI supports — e.g., delegated Graph scopes or multi-tenant app consent.", color: TEAL },
    { title: "OBO (On-Behalf-Of) Patterns", desc: "For non-Entra users. Agent acts on behalf of a user identity when external IdP is federated. Requires token exchange.", color: "4A6FA5" },
  ];

  items.forEach((item, i) => {
    const y = 1.5 + i * 1.3;
    s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: y, w: 8.4, h: 1.1, fill: { color: item.color } });
    s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: y, w: 0.1, h: 1.1, fill: { color: WHITE } });
    s.addText(item.title, {
      x: 1.2, y: y + 0.05, w: 7.8, h: 0.45,
      fontSize: 16, fontFace: HEADER_FONT, color: WHITE, bold: true,
    });
    s.addText(item.desc, {
      x: 1.2, y: y + 0.5, w: 7.8, h: 0.5,
      fontSize: 12, fontFace: BODY_FONT, color: "D0E0F0",
    });
  });
})();

// ── Slide 6: Lab Preview ──
(() => {
  const s = pres.addSlide();
  s.background = { color: WHITE };
  addFooter(s, 6);
  s.addText("Lab Preview", {
    x: 0.8, y: 0.3, w: 6, h: 0.7,
    fontSize: 36, fontFace: HEADER_FONT, color: MIDNIGHT, bold: true,
  });
  s.addShape(pres.shapes.RECTANGLE, { x: 8.0, y: 0.35, w: 1.5, h: 0.5, fill: { color: TEAL } });
  s.addText("60 min", {
    x: 8.0, y: 0.35, w: 1.5, h: 0.5,
    fontSize: 16, fontFace: BODY_FONT, color: WHITE, bold: true, align: "center", valign: "middle",
  });

  s.addText("Wire a Cross-Tenant Connector", {
    x: 0.8, y: 1.1, w: 8.4, h: 0.5,
    fontSize: 20, fontFace: HEADER_FONT, color: MIDNIGHT, italic: true,
  });

  const steps = [
    { num: "1", text: "Set up primary sandbox as agent home tenant with UAMI configured" },
    { num: "2", text: "Configure the second sandbox as the \"remote\" tenant (prerequisite #2)" },
    { num: "3", text: "Create the cross-tenant connector using managed-identity federation" },
    { num: "4", text: "Coordinate the consent step with named Entra admin (prerequisite #8)" },
    { num: "5", text: "Verify agent can read telemetry from the remote tenant's resources" },
  ];

  steps.forEach((step, i) => {
    const y = 1.8 + i * 0.6;
    s.addShape(pres.shapes.OVAL, { x: 0.8, y: y, w: 0.4, h: 0.4, fill: { color: TEAL } });
    s.addText(step.num, {
      x: 0.8, y: y, w: 0.4, h: 0.4,
      fontSize: 14, fontFace: BODY_FONT, color: WHITE, bold: true, align: "center", valign: "middle",
    });
    s.addText(step.text, {
      x: 1.4, y: y, w: 8.0, h: 0.4,
      fontSize: 14, fontFace: BODY_FONT, color: "333333", valign: "middle",
    });
  });

  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 4.7, w: 8.4, h: 0.6, fill: { color: "E8F4F8" } });
  s.addText("Output: one-page topology diagram per attendee for their real environment", {
    x: 1.0, y: 4.7, w: 8.0, h: 0.6,
    fontSize: 13, fontFace: BODY_FONT, color: MIDNIGHT, italic: true, valign: "middle",
  });
})();

// ── Slide 7: Fallback Plan ──
(() => {
  const s = pres.addSlide();
  s.background = { color: LIGHT_BG };
  addFooter(s, 7);
  s.addText("Fallback Plan", {
    x: 0.8, y: 0.3, w: 8.4, h: 0.7,
    fontSize: 36, fontFace: HEADER_FONT, color: MIDNIGHT, bold: true,
  });

  // Two-column: if / then
  // IF column
  s.addShape(pres.shapes.RECTANGLE, { x: 0.5, y: 1.3, w: 4.3, h: 3.5, fill: { color: WHITE } });
  s.addShape(pres.shapes.RECTANGLE, { x: 0.5, y: 1.3, w: 4.3, h: 0.5, fill: { color: "E53935" } });
  s.addText("\u26A0  If Entra Admin Unavailable", {
    x: 0.5, y: 1.3, w: 4.3, h: 0.5,
    fontSize: 14, fontFace: HEADER_FONT, color: WHITE, bold: true, align: "center", valign: "middle",
  });
  s.addText([
    { text: "Hands-on lab cannot proceed — cross-tenant consent requires Entra admin (prerequisite #8).", options: { fontSize: 13, fontFace: BODY_FONT, color: "444444", breakLine: true } },
    { text: "", options: { fontSize: 8, breakLine: true } },
    { text: "This is the most common blocker in L400 delivery.", options: { fontSize: 12, fontFace: BODY_FONT, color: "888888", italic: true } },
  ], { x: 0.8, y: 2.0, w: 3.7, h: 2.5, valign: "top" });

  // THEN column
  s.addShape(pres.shapes.RECTANGLE, { x: 5.2, y: 1.3, w: 4.3, h: 3.5, fill: { color: WHITE } });
  s.addShape(pres.shapes.RECTANGLE, { x: 5.2, y: 1.3, w: 4.3, h: 0.5, fill: { color: "4CAF50" } });
  s.addText("\u2705  Lecture-Only Variant", {
    x: 5.2, y: 1.3, w: 4.3, h: 0.5,
    fontSize: 14, fontFace: HEADER_FONT, color: WHITE, bold: true, align: "center", valign: "middle",
  });
  s.addText([
    { text: "Switch to topology diagram exercise:", options: { fontSize: 13, fontFace: BODY_FONT, color: "444444", breakLine: true } },
    { text: "", options: { fontSize: 8, breakLine: true } },
    { text: "Draw private connectivity paths for your monitored services", options: { bullet: true, fontSize: 12, fontFace: BODY_FONT, color: "555555", breakLine: true } },
    { text: "Identify which services require cross-tenant trust", options: { bullet: true, fontSize: 12, fontFace: BODY_FONT, color: "555555", breakLine: true } },
    { text: "Map NSG / private DNS dependencies", options: { bullet: true, fontSize: 12, fontFace: BODY_FONT, color: "555555", breakLine: true } },
    { text: "Produce one-page topology diagram as take-home artifact", options: { bullet: true, fontSize: 12, fontFace: BODY_FONT, color: "555555" } },
  ], { x: 5.5, y: 2.0, w: 3.7, h: 2.5, valign: "top" });
})();

// ── Slide 8: References + L300 Boundary ──
(() => {
  const s = pres.addSlide();
  s.background = { color: WHITE };
  addFooter(s, 8);
  s.addText("References + L300 Boundary", {
    x: 0.8, y: 0.3, w: 8.4, h: 0.7,
    fontSize: 32, fontFace: HEADER_FONT, color: MIDNIGHT, bold: true,
  });

  s.addText("Documentation Links (Section 7)", {
    x: 0.8, y: 1.1, w: 8.4, h: 0.4,
    fontSize: 16, fontFace: HEADER_FONT, color: DEEP, bold: true,
  });

  const refs = [
    "Azure Observability VNET — sre.azure.com/docs/capabilities/azure-observability-vnet",
    "Cross-Tenant Access — sre.azure.com/docs/capabilities/cross-tenant-access",
    "Agent Identity — sre.azure.com/docs/concepts/agent-identity",
    "Connectors — sre.azure.com/docs/tutorials/connectors/*",
    "Cross-Tenant ADO — sre.azure.com/docs/tutorials/connectors/*",
  ];

  s.addText(refs.map((r, i) => ({
    text: r,
    options: { bullet: true, fontSize: 11, fontFace: BODY_FONT, color: "555555", breakLine: i < refs.length - 1 },
  })), { x: 0.8, y: 1.55, w: 8.4, h: 1.8, valign: "top" });

  // Out of scope
  s.addText("Out of Scope for This Module", {
    x: 0.8, y: 3.4, w: 8.4, h: 0.4,
    fontSize: 16, fontFace: HEADER_FONT, color: "E53935", bold: true,
  });

  const oos = [
    "M12 Config-as-Code — agent IaC PR workflow (separate module)",
    "M13 Capstone drill — production rollout playbook",
    "Custom MCP server development (covered in M5/M8)",
    "FinOps per-task model tier tuning (capstone overlay)",
  ];

  s.addText(oos.map((r, i) => ({
    text: r,
    options: { bullet: true, fontSize: 11, fontFace: BODY_FONT, color: "777777", breakLine: i < oos.length - 1 },
  })), { x: 0.8, y: 3.85, w: 8.4, h: 1.4, valign: "top" });
})();

const outPath = path.join(__dirname, "M11-enterprise-topology.pptx");
pres.writeFile({ fileName: outPath }).then(() => {
  console.log("Created: " + outPath);
}).catch(err => {
  console.error("Error:", err);
  process.exit(1);
});
