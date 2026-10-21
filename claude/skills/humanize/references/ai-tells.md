# AI Tells — what to hunt and remove

Each entry: the tell, why it reads as AI, and what to do instead. The fix is almost never a synonym swap — it's usually deletion or restructuring.

## Vocabulary

Words that spike in LLM output far above human baseline. Presence of one isn't damning; clusters are.

- **delve, dive into, unpack, explore** → just make the point instead of announcing you will
- **leverage, utilize** → use
- **robust, seamless, comprehensive, holistic** → cut, or name the concrete property ("handles retries", "one command"). Praising your own work this way ("significantly improved") is unfalsifiable: give the number or give nothing
- **crucial, pivotal, vital, essential** → important, or cut — most things labeled crucial aren't
- **foster, empower, elevate, enhance, streamline** → say what actually changes ("makes deploys faster")
- **landscape, ecosystem, realm, space** (as abstract nouns) → name the actual thing
- **testament to, underscores, highlights the importance of** → cut the sentence; it's commentary on the point, not the point
- **In today's fast-paced world / ever-evolving landscape** → delete the whole clause

## Constructions

- **"It's not just X — it's Y"** and cousins ("not only... but also", "more than just") → pick the one claim that matters and state it
- **Rule of three everywhere** ("fast, reliable, and scalable") → humans use triads occasionally; AI uses them constantly. Break some into one or two items, or a full sentence
- **Antithesis scaffolding** ("While X is true, Y...") opening every other paragraph → vary openings; sometimes just assert Y
- **Throat-clearing** ("It's important to note that", "It's worth mentioning", "One thing to keep in mind is") → delete; the sentence that follows was the content
- **Sycophancy openers** ("Great question!", "I'd be happy to") → delete
- **Over-signposting** ("In conclusion", "Overall", "To summarize", "Let's break this down") → structure should be visible without narration
- **Hedging stacks** ("could potentially", "may possibly", "it seems that perhaps") → one hedge max, and only if uncertainty is real. A hedge as insurance ("this should mostly work") means either it works or you haven't checked; say which
- **Both-sidesing** every claim ("However, it's also worth considering...") → have an opinion; state tradeoffs only when they'd change a decision
- **"Please don't hesitate to reach out"** → the tell is the "don't hesitate" formula, not politeness itself. Replace with the author's own natural closer (e.g. "Please let me know if you have any questions!") or nothing. Do NOT substitute faux-casual ("Shout if anything looks off", "lmk") unless that's how the author actually talks

## Punctuation & formatting

- **Em-dash density** — one or two per message is human; one per sentence is a tell → replace with commas, periods, or parentheses
- **Bolded lead-in on every bullet** ("**Speed:** ...", "**Reliability:** ...") → fine in a formal doc, robotic in chat; vary or drop
- **Smart-Brevity label injection** ("**Why it matters:**", "**The big picture:**", "**Bottom line:**", "**Zoom out:**") → Axios tropes that LLMs reproduce constantly; if the input didn't have labeled sections, don't add them — say the point in prose
- **Every paragraph exactly 2–3 sentences** → merge some, let one run long, let one be a fragment
- **Emoji as bullet decoration** (🚀 for every feature) → emoji should carry tone, not structure
- **Title Case On Every Header** → sentence case reads more human
- **Curly quotes and perfect typography in casual contexts** → chat messages have straight quotes and missing periods

## Rhythm & shape

- **Uniform sentence length** → alternate. A 30-word sentence earns a 4-word follow-up.
- **Perfectly parallel list items** (all same length, same grammatical shape) → let them be lumpy
- **Symmetric essay shape** (intro ¶ → 3 body ¶s → conclusion ¶) for a 200-word answer → most human messages are front-loaded and just stop
- **No contractions** → contractions everywhere except the most formal legal/spec text
- **Zero asides or self-interruption** → humans go "(still can't believe that worked)" mid-thought; AI never does unless told
- **Aphoristic punch on every sentence** — neat antitheses ("one model to vet instead of one per team"), mic-drop closers, every line quotable → this cadence survives vocabulary cleanup and still reads as AI. Let most sentences be workmanlike; keep at most one punchy line per section, and let closers trail off with a plain next step or qualifier instead of a drumbeat

## Content tells

- **Restating the question before answering** → answer
- **Summarizing what was just said at the end** → stop after the last new piece of information
- **Numbered steps for things that aren't procedures** → prose
- **Defining terms the audience obviously knows** → trust the reader
- **Caveat paragraphs about edge cases nobody asked about** → cut, or one parenthetical
- **Reply longer than the question** → a yes/no question gets a yes or no, then at most a short paragraph, and no offer of more detail. A design question earns length; a lookup doesn't

## Honesty tells

- **Filler urgency** ("no real urgency on this") → a claim nobody asked for. If urgency is real, name what drives it (a deadline, a blocked person); otherwise drop the clause
- **The attempt reported as the outcome** ("I've added tests" when they never ran) → say what ran and what it returned. If a check ships red, say it ships red
- **A verification section that verifies nothing** (what you would have checked, a test that can't fail) → name the check, where it ran and its result, or say it didn't run

## Corrections

- **Narrating your own correction** ("I previously said 27, apologies, it's actually 30") → fix the number and move on
- **Tallying past mistakes** ("as I got wrong earlier") → cut
- **Correcting a slip that changes nothing** → fix it silently; only correct what changes a decision
- **Correcting the person instead of stating the fact** ("actually", "to be clear", "not for the reason usually given", quoting what they said to contrast it) → state what's true. If a sentence's job is to show someone was wrong, cut it
- **Opening with the correction** → lead with the answer they wanted and let the fact sit where it's needed, often mid-message
