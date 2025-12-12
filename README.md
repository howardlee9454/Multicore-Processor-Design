# Multicore-Processor-Design
Dual-Core RISC-V Implementation in Verilog

Design created for ECE 43700 (Purdue University)

This repository contains a dual-core RISC-V processor implemented in synthesizable Verilog. It is intended as a teaching / lab project for ECE 43700 and demonstrates a working multicore datapath, control, memory interface, and the verification scaffolding needed to simulate, test, and synthesize the design.

<!-- Dual-core RISC-V System Architecture SVG (embed in README or open as HTML) -->
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Dual-core RISC-V Architecture Diagram</title>
  <style>
    body { font-family: Inter, -apple-system, system-ui, 'Segoe UI', Roboto, 'Helvetica Neue', Arial; background: #fff; padding: 18px; }
    .note { font-size: 12px; fill: #333; }
  </style>
</head>
<body>
  <!-- SVG diagram sized for README display -->
  <svg xmlns="http://www.w3.org/2000/svg" width="100%" viewBox="0 0 1200 560" preserveAspectRatio="xMidYMid meet">
    <defs>
      <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
        <feDropShadow dx="0" dy="4" stdDeviation="6" flood-color="#000" flood-opacity="0.12"/>
      </filter>
      <style>
        .box { rx:10; ry:10; fill:#fff; stroke:#2b2f3a; stroke-width:1.6; }
        .title { font: 700 16px/1.2 'Segoe UI', Roboto, Arial; fill:#0f1724; }
        .label { font: 600 12px/1.2 'Segoe UI', Roboto, Arial; fill:#0f1724; }
        .sub { font: 400 11px/1.2 'Segoe UI', Roboto, Arial; fill:#334155; }
        .thin { stroke:#9aa3b2; stroke-width:1.2; }
        .arrow { stroke:#0f1724; stroke-width:2; fill:none; marker-end:url(#arrowhead); }
      </style>
      <marker id="arrowhead" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto">
        <path d="M 0 0 L 10 5 L 0 10 z" fill="#0f1724" />
      </marker>
    </defs>

    <!-- Top-level title -->
    <text x="36" y="36" class="title">Dual-core RISC-V System Architecture</text>

    <!-- Left column: Core 0 -->
    <g transform="translate(36,72)">
      <rect class="box" width="300" height="170" filter="url(#shadow)" />
      <text x="16" y="30" class="label">CPU Core 0</text>
      <text x="16" y="48" class="sub">5-stage pipeline (IF → ID → EX → MEM → WB)</text>

      <!-- L1 caches inside core box -->
      <rect x="16" y="66" width="120" height="80" rx="6" ry="6" fill="#f8fafc" stroke="#cbd5e1" />
      <text x="26" y="90" class="label">L1 I-Cache</text>
      <text x="26" y="108" class="sub">(instr fetch)</text>

      <rect x="164" y="66" width="120" height="80" rx="6" ry="6" fill="#f8fafc" stroke="#cbd5e1" />
      <text x="174" y="90" class="label">L1 D-Cache</text>
      <text x="174" y="108" class="sub">(load/store)</text>
    </g>

    <!-- Right column: Core 1 -->
    <g transform="translate(864,72)">
      <rect class="box" width="300" height="170" filter="url(#shadow)" />
      <text x="16" y="30" class="label">CPU Core 1</text>
      <text x="16" y="48" class="sub">5-stage pipeline (IF → ID → EX → MEM → WB)</text>

      <rect x="164" y="66" width="120" height="80" rx="6" ry="6" fill="#f8fafc" stroke="#cbd5e1" />
      <text x="174" y="90" class="label">L1 I-Cache</text>
      <text x="174" y="108" class="sub">(instr fetch)</text>

      <rect x="16" y="66" width="120" height="80" rx="6" ry="6" fill="#f8fafc" stroke="#cbd5e1" />
      <text x="26" y="90" class="label">L1 D-Cache</text>
      <text x="26" y="108" class="sub">(load/store)</text>
    </g>

    <!-- Shared Interconnect / Arbiter box in center top -->
    <g transform="translate(320,56)">
      <rect class="box" width="560" height="88" filter="url(#shadow)" />
      <text x="20" y="30" class="label">Shared Interconnect & Arbiter</text>
      <text x="20" y="48" class="sub">Arbitrates cache misses, handles coherency messaging (if implemented)</text>
    </g>

    <!-- Memory Controller box center middle -->
    <g transform="translate(420,180)">
      <rect class="box" width="360" height="110" filter="url(#shadow)" />
      <text x="20" y="28" class="label">Memory Controller</text>
      <text x="20" y="46" class="sub">Refill, write-back, peripheral bridge, memory timing</text>

      <!-- small peripherals area -->
      <rect x="20" y="56" width="140" height="40" rx="6" ry="6" fill="#fbf8ff" stroke="#c7b2ff" />
      <text x="28" y="80" class="sub">MMIO / Peripherals</text>
    </g>

    <!-- RAM box bottom center -->
    <g transform="translate(420,310)">
      <rect class="box" width="360" height="140" filter="url(#shadow)" />
      <text x="20" y="36" class="label">Main Memory (RAM)</text>
      <text x="20" y="56" class="sub">SRAM model / FPGA BRAM (initialized via .hex or ELF)</text>
      <text x="20" y="76" class="sub">Config: size = e.g., 16KB, latency = 1–3 cycles</text>
    </g>

    <!-- Arrows from cores to interconnect -->
    <path class="arrow" d="M 336 150 L 384 150"/>
    <path class="arrow" d="M 816 150 L 864 150"/>

    <!-- Arrows from interconnect to memory controller -->
    <path class="arrow" d="M 600 200 L 600 180"/>
    <path class="arrow" d="M 560 244 L 560 220"/>

    <!-- Arrow mem controller -> RAM -->
    <path class="arrow" d="M 600 290 L 600 310"/>

    <!-- Small labels near arrows -->
    <text x="420" y="148" class="sub">Cache miss / writeback</text>
    <text x="620" y="240" class="sub">Refill / ACK</text>

    <!-- Footer note -->
    <text x="36" y="540" class="note">Tip: Copy the SVG portion (open this file and copy the &lt;svg ...&gt; ... &lt;/svg&gt; element) directly into your README.md to embed the diagram on GitHub.</text>
  </svg>
</body>
</html>






