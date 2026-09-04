<!doctype html>
<html lang="de">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1.0,viewport-fit=cover" />
  <title>Buchstaben‑Bingo (Touch)</title>
  <style>
    :root{
      --bg:#ffffff;
      --fg:#0b0b0b;
      --accent:#0077cc;
      --btn-bg: rgba(0,0,0,0.6);
      --btn-fg: #fff;
    }
    html,body{
      height:100%;
      margin:0;
      font-family: system-ui, -apple-system, "Helvetica Neue", Arial;
      background: var(--bg);
      color: var(--fg);
      -webkit-user-select:none;
      user-select:none;
      -webkit-touch-callout:none;
    }
    .wrap{
      height:100%;
      display:flex;
      flex-direction:column;
      align-items:center;
      justify-content:center;
      padding:1rem;
      box-sizing:border-box;
      text-align:center;
    }
    .message{
      font-size:1.4rem;
      margin-bottom:1rem;
      color:#444;
    }
    .letter{
      width:100%;
      max-width:960px;
      height:60vh;
      display:flex;
      align-items:center;
      justify-content:center;
      border-radius:12px;
      background: linear-gradient(180deg, #fff, #f7f9fc);
      box-shadow: 0 6px 18px rgba(0,0,0,0.08);
      font-weight:800;
      user-select:none;
    }
    .letter .char{
      font-size: clamp(6rem, 24vw, 28rem);
      line-height:0.9;
      letter-spacing:0.02em;
      color:var(--fg);
    }
    .hint{
      margin-top:1rem;
      color:#666;
      font-size:1rem;
    }

    /* small round button bottom-right */
    .corner-btn{
      position:fixed;
      right:1rem;
      bottom:1rem;
      width:56px;
      height:56px;
      border-radius:50%;
      display:flex;
      align-items:center;
      justify-content:center;
      background: var(--btn-bg);
      color: var(--btn-fg);
      box-shadow: 0 6px 14px rgba(0,0,0,0.18);
      border: none;
      font-weight:700;
      font-size:0.8rem;
      z-index:1000;
      touch-action: manipulation;
    }
    .small-text{
      font-size:0.85rem;
      color:#333;
    }
    footer{
      position:fixed;
      left:1rem;
      bottom:1rem;
      font-size:0.8rem;
      color:#888;
    }

    /* big tap area styling hint for accessibility */
    .tap-area{
      position:absolute;
      inset:0;
      display:flex;
      align-items:center;
      justify-content:center;
    }

    /* visual feedback on touch */
    .flash {
      animation: flash 220ms ease-out;
    }
    @keyframes flash{
      from{ box-shadow: 0 0 0 0 rgba(0,119,204,0.2);}
      to{ box-shadow: 0 0 0 24px rgba(0,119,204,0);}
    }
  </style>
</head>
<body>
  <div class="wrap" id="app">
    <div class="message" id="topMessage">Bitte berühren</div>

    <div class="letter" id="display">
      <div class="char" id="char"> </div>
    </div>

    <div class="hint" id="hintText">Tippe irgendwo auf den Bildschirm, um einen Buchstaben zu ziehen. Kein Umlaut.</div>

    <button class="corner-btn" id="resetBtn" title="Nächste Runde (reset)">⟳</button>

    <footer>Einfach tippen → Buchstabe erscheint und wird gesprochen</footer>

    <!-- full-screen tap area (for easier touching) -->
    <div class="tap-area" id="tapArea" aria-hidden="false"></div>
  </div>

  <script>
    // Kein Umlaut: A-Z
    const LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");

    // state
    let drawn = new Set();
    let current = null;

    // elements
    const topMessage = document.getElementById('topMessage');
    const charEl = document.getElementById('char');
    const display = document.getElementById('display');
    const tapArea = document.getElementById('tapArea');
    const hintText = document.getElementById('hintText');
    const resetBtn = document.getElementById('resetBtn');

    // initialize
    function showStartScreen(){
      topMessage.textContent = "Bitte berühren";
      charEl.textContent = "";
      hintText.textContent = "Tippe irgendwo auf den Bildschirm, um einen Buchstaben zu ziehen.";
      current = null;
      // clear drawn for new round is done when reset pressed (per spec)
    }

    // draw a random letter not yet drawn; if all drawn, show message and allow reset
    function drawLetter(){
      if(drawn.size >= LETTERS.length){
        topMessage.textContent = "Alle Buchstaben gezogen. Drücke Nächste Runde.";
        return;
      }
      // choose random from remaining
      const remaining = LETTERS.filter(l => !drawn.has(l));
      const idx = Math.floor(Math.random() * remaining.length);
      const letter = remaining[idx];
      drawn.add(letter);
      current = letter;
      topMessage.textContent = "Gewürfelt";
      displayLetter(letter);
      speak(letter);
    }

    // display with visual feedback
    function displayLetter(letter){
      charEl.textContent = letter;
      display.classList.remove('flash');
      // force reflow then add to restart animation
      void display.offsetWidth;
      display.classList.add('flash');
      hintText.textContent = "Berühre erneut für den nächsten Buchstaben.";
    }

    // speak the letter (german voice if available)
    function speak(text){
      if(!('speechSynthesis' in window)) return;
      // cancel ongoing
      window.speechSynthesis.cancel();
      const ut = new SpeechSynthesisUtterance(text);
      // prefer a German voice if present
      const voices = window.speechSynthesis.getVoices();
      // choose voice heuristically
      let chosen = null;
      for(const v of voices){
        const name = (v.name + ' ' + v.lang).toLowerCase();
        if(name.includes('de') || name.includes('german')) { chosen = v; break; }
      }
      if(chosen) ut.voice = chosen;
      // speak single letter as letter name; to increase clarity, use pause between letters is not needed
      ut.rate = 0.9;
      ut.pitch = 1.0;
      window.speechSynthesis.speak(ut);
    }

    // prepare next round (reset draws and show start screen)
    function prepareNextRound(){
      drawn.clear();
      current = null;
      // stop any speech
      if(window.speechSynthesis) window.speechSynthesis.cancel();
      showStartScreen();
    }

    // handle initial touch: if currently showing start screen, draw; otherwise draw next
    function handleTap(){
      // if start text shown and no current letter: draw
      if(current === null){
        drawLetter();
        return;
      }
      // otherwise draw next letter
      drawLetter();
    }

    // event listeners
    tapArea.addEventListener('click', function(e){
      handleTap();
    });

    // Also allow tapping the letter area itself
    display.addEventListener('click', function(e){
      handleTap();
    });

    // Reset button
    resetBtn.addEventListener('click', function(e){
      prepareNextRound();
    });

    // prevent double tap zoom on iOS and hold-to-copy etc.
    document.addEventListener('touchstart', function(){}, {passive:true});

    // On load, show start
    window.addEventListener('load', function(){
      showStartScreen();
      // Safari may not populate voices immediately; call getVoices once to warm up
      if(window.speechSynthesis){
        window.speechSynthesis.getVoices();
      }
    });

    // Accessibility: if voices update later, we still can use them
    window.speechSynthesis && window.speechSynthesis.addEventListener && window.speechSynthesis.addEventListener('voiceschanged', function(){ window.speechSynthesis.getVoices(); });

    // Optional: keyboard support for desktop testing (space = draw, r = reset)
    document.addEventListener('keydown', function(e){
      if(e.code === 'Space'){
        e.preventDefault();
        handleTap();
      }
      if(e.key === 'r' || e.key === 'R'){
        prepareNextRound();
      }
    });
  </script>
</body>
</html>
