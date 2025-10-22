// Athulyam Group — JS placeholder
console.log('Athulyam Group online.');

/* ===== Athulyam Creed / Philosophy ===== */
.creed {
  position: relative;
  padding: 80px 20px;
  background: radial-gradient(1200px 600px at 50% 0%, #001a17 0%, #000 70%);
  border-top: 1px solid #00ffcc22;
  border-bottom: 1px solid #00ffcc22;
  overflow: hidden;
}

.creed::before {
  /* faint aurora glow sweeping behind the text */
  content: "";
  position: absolute;
  inset: -20% -10%;
  background: radial-gradient(circle at 30% 20%, rgba(0,255,204,0.10), transparent 40%),
              radial-gradient(circle at 70% 80%, rgba(0,255,204,0.06), transparent 40%);
  filter: blur(30px);
  pointer-events: none;
}

.creed-inner {
  max-width: 900px;
  margin: 0 auto;
  text-align: center;
}

.creed h2 {
  color: #00ffcc;
  text-transform: uppercase;
  letter-spacing: 2px;
  margin: 0 0 16px;
  text-shadow: 0 0 12px rgba(0,255,204,0.35);
}

.creed-lede {
  color: #8bd9c9;
  font-size: 1.1rem;
  margin: 0 auto 26px;
}

.creed-quote {
  font-size: 1.25rem;
  line-height: 1.6;
  color: #e7fffb;
  margin: 0 auto 26px;
  padding: 16px 18px;
  border-left: 4px solid #00ffcc;
  display: inline-block;
  text-align: left;
  background: rgba(0,255,204,0.06);
  box-shadow: 0 0 18px rgba(0,255,204,0.10) inset, 0 0 18px rgba(0,255,204,0.10);
}

.creed-body {
  color: #9feee0;
  margin: 0 auto 28px;
}

.creed-pillars {
  list-style: none;
  padding: 0;
  margin: 22px auto 0;
  max-width: 760px;
  text-align: left;
}

.creed-pillars li {
  margin: 10px 0;
  padding: 10px 14px;
  background: rgba(0,255,204,0.05);
  border: 1px solid #00ffcc22;
  border-radius: 10px;
  box-shadow: 0 0 12px rgba(0,255,204,0.08);
}

.creed-pillars li span {
  color: #00ffcc;
  font-weight: 700;
}

/* small screens */
@media (max-width: 520px) {
  .creed-quote { font-size: 1.1rem; }
}
