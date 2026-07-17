//! Logan native modes: `/caveman`, `/ponytail`, `/modes`, `/whoami`, `/improve`.
//!
//! Modes persist in `~/.logan/modes.toml` and are mirrored into
//! `~/.logan/rules/logan-modes.md` so every session loads them as global rules.
//! Skills live under `~/.logan/skills/{caveman,ponytail,whoami,self-improve,hyperframes-master}/`.

use crate::slash::command::{
    AppCtx, ArgItem, CommandExecCtx, CommandResult, SlashCommand,
};
use std::path::{Path, PathBuf};

// ── shared filesystem helpers ─────────────────────────────────────────────

fn logan_home() -> PathBuf {
    if let Ok(v) = std::env::var("LOGAN_HOME") {
        return PathBuf::from(v);
    }
    #[allow(deprecated)]
    std::env::home_dir()
        .unwrap_or_else(|| PathBuf::from("."))
        .join(".logan")
}

fn modes_path() -> PathBuf {
    logan_home().join("modes.toml")
}

fn rules_path() -> PathBuf {
    logan_home().join("rules").join("logan-modes.md")
}

fn memory_dir() -> PathBuf {
    logan_home().join("memory")
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Intensity {
    Off,
    Lite,
    Full,
    Ultra,
}

impl Intensity {
    fn parse(s: &str) -> Option<Self> {
        match s.trim().to_ascii_lowercase().as_str() {
            "off" | "0" | "false" | "disable" | "disabled" | "stop" | "normal" => {
                Some(Self::Off)
            }
            "on" | "true" | "enable" | "enabled" => Some(Self::Full),
            "lite" | "light" => Some(Self::Lite),
            "full" | "default" => Some(Self::Full),
            "ultra" | "max" => Some(Self::Ultra),
            "" => None,
            _ => None,
        }
    }

    fn as_str(self) -> &'static str {
        match self {
            Self::Off => "off",
            Self::Lite => "lite",
            Self::Full => "full",
            Self::Ultra => "ultra",
        }
    }
}

#[derive(Debug, Clone)]
struct ModesState {
    caveman: Intensity,
    ponytail: Intensity,
}

impl Default for ModesState {
    fn default() -> Self {
        Self {
            caveman: Intensity::Off,
            ponytail: Intensity::Off,
        }
    }
}

fn load_modes() -> ModesState {
    let path = modes_path();
    let Ok(text) = std::fs::read_to_string(&path) else {
        return ModesState::default();
    };
    let mut state = ModesState::default();
    for line in text.lines() {
        let line = line.trim();
        if line.starts_with('#') || line.is_empty() || line.starts_with('[') {
            continue;
        }
        if let Some((k, v)) = line.split_once('=') {
            let k = k.trim();
            let v = v.trim().trim_matches('"').trim_matches('\'');
            if k == "caveman" {
                if let Some(i) = Intensity::parse(v) {
                    state.caveman = i;
                }
            } else if k == "ponytail" {
                if let Some(i) = Intensity::parse(v) {
                    state.ponytail = i;
                }
            }
        }
    }
    state
}

fn save_modes(state: &ModesState) -> Result<(), String> {
    let home = logan_home();
    std::fs::create_dir_all(home.join("rules")).map_err(|e| e.to_string())?;
    std::fs::create_dir_all(home.join("memory")).map_err(|e| e.to_string())?;
    let toml = format!(
        r#"# Logan communication / coding modes
# Author: Yuval Avidani (YUV.AI)
# Toggle: /caveman /ponytail /modes

[modes]
caveman = "{}"
ponytail = "{}"
"#,
        state.caveman.as_str(),
        state.ponytail.as_str()
    );
    std::fs::write(modes_path(), toml).map_err(|e| e.to_string())?;
    write_rules_mirror(state)?;
    Ok(())
}

fn write_rules_mirror(state: &ModesState) -> Result<(), String> {
    let mut body = String::from(
        r#"# Logan active modes (auto-generated)

Do not edit by hand - use `/caveman`, `/ponytail`, or `/modes`.
Generated for every session as a global rule under `~/.logan/rules/`.

"#,
    );
    match state.caveman {
        Intensity::Off => body.push_str("## Caveman: OFF\nSpeak normally (clear, complete sentences).\n\n"),
        level => {
            body.push_str(&format!(
                "## Caveman: ON ({})\n\nFollow the **caveman** skill at intensity **{}**.\n\
                 Terse smart-caveman prose. Code and errors stay exact. No filler.\n\
                 Skill path: `~/.logan/skills/caveman/SKILL.md`\n\n",
                level.as_str(),
                level.as_str()
            ));
        }
    }
    match state.ponytail {
        Intensity::Off => body.push_str("## Ponytail: OFF\nNormal engineering judgment (still avoid pointless bloat).\n\n"),
        level => {
            body.push_str(&format!(
                "## Ponytail: ON ({})\n\nFollow the **ponytail** skill at intensity **{}**.\n\
                 YAGNI ladder. Shortest working diff. Stdlib/native first.\n\
                 Skill path: `~/.logan/skills/ponytail/SKILL.md`\n\n",
                level.as_str(),
                level.as_str()
            ));
        }
    }
    body.push_str(
        "## Always\n\
         - HyperFrames is the default video stack when the user wants video/motion (skill `hyperframes-master`).\n\
         - Prefer PROFILE.md + MEMORY.md for identity and stack preferences (`/whoami`).\n\
         - Journal non-trivial fixes in IMPROVEMENTS.md (`/improve`).\n",
    );
    std::fs::write(rules_path(), body).map_err(|e| e.to_string())
}

fn read_file_capped(path: &Path, max: usize) -> String {
    match std::fs::read_to_string(path) {
        Ok(s) if s.len() <= max => s,
        Ok(s) => {
            let start = s.len().saturating_sub(max);
            format!("…(truncated)…\n{}", &s[start..])
        }
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => "(missing)\n".into(),
        Err(e) => format!("(error reading {}: {e})\n", path.display()),
    }
}

fn mode_levels_suggestions() -> Vec<ArgItem> {
    ["off", "lite", "full", "ultra"]
        .into_iter()
        .map(|s| ArgItem {
            display: s.into(),
            match_text: s.into(),
            insert_text: s.into(),
            description: format!("Set intensity to {s}"),
        })
        .collect()
}

fn set_mode(which: &str, args: &str) -> CommandResult {
    let mut state = load_modes();
    let trimmed = args.trim();
    if trimmed.is_empty() || trimmed.eq_ignore_ascii_case("status") {
        return CommandResult::Message(format!(
            "Modes · caveman={} · ponytail={}\n\
             Toggle: /{which} off|lite|full|ultra\n\
             Both: /modes\n\
             Persist: {} + {}",
            state.caveman.as_str(),
            state.ponytail.as_str(),
            modes_path().display(),
            rules_path().display(),
        ));
    }
    let Some(level) = Intensity::parse(trimmed) else {
        return CommandResult::Error(format!(
            "Unknown level `{trimmed}`. Use: off | lite | full | ultra"
        ));
    };
    match which {
        "caveman" => state.caveman = level,
        "ponytail" => state.ponytail = level,
        _ => return CommandResult::Error("internal: unknown mode".into()),
    }
    if let Err(e) = save_modes(&state) {
        return CommandResult::Error(format!("Failed to save modes: {e}"));
    }
    let skill_hint = if level == Intensity::Off {
        format!("{which} off for new turns (rules updated). Existing chat may need a short reminder.")
    } else {
        format!(
            "{which} → **{}**. Sticky rule written. Skill: ~/.logan/skills/{which}/SKILL.md\n\
             New sessions load automatically. This session: obey intensity now.",
            level.as_str()
        )
    };
    CommandResult::Message(skill_hint)
}

// ── /caveman ──────────────────────────────────────────────────────────────

pub struct CavemanCommand;

impl SlashCommand for CavemanCommand {
    fn name(&self) -> &str {
        "caveman"
    }
    fn aliases(&self) -> &[&str] {
        &["terse", "brief"]
    }
    fn description(&self) -> &str {
        "Token-saving talk mode (caveman) - off|lite|full|ultra"
    }
    fn usage(&self) -> &str {
        "/caveman [off|lite|full|ultra]"
    }
    fn takes_args(&self) -> bool {
        true
    }
    fn arg_placeholder(&self) -> Option<&str> {
        Some("[off|lite|full|ultra]")
    }
    fn suggest_args(&self, _ctx: &AppCtx, _q: &str) -> Option<Vec<ArgItem>> {
        Some(mode_levels_suggestions())
    }
    fn run(&self, _ctx: &mut CommandExecCtx, args: &str) -> CommandResult {
        set_mode("caveman", args)
    }
}

// ── /ponytail ─────────────────────────────────────────────────────────────

pub struct PonytailCommand;

impl SlashCommand for PonytailCommand {
    fn name(&self) -> &str {
        "ponytail"
    }
    fn aliases(&self) -> &[&str] {
        &["yagni", "lazy"]
    }
    fn description(&self) -> &str {
        "Minimal-code mode (ponytail YAGNI) - off|lite|full|ultra"
    }
    fn usage(&self) -> &str {
        "/ponytail [off|lite|full|ultra]"
    }
    fn takes_args(&self) -> bool {
        true
    }
    fn arg_placeholder(&self) -> Option<&str> {
        Some("[off|lite|full|ultra]")
    }
    fn suggest_args(&self, _ctx: &AppCtx, _q: &str) -> Option<Vec<ArgItem>> {
        Some(mode_levels_suggestions())
    }
    fn run(&self, _ctx: &mut CommandExecCtx, args: &str) -> CommandResult {
        set_mode("ponytail", args)
    }
}

// ── /modes ────────────────────────────────────────────────────────────────

pub struct ModesCommand;

impl SlashCommand for ModesCommand {
    fn name(&self) -> &str {
        "modes"
    }
    fn description(&self) -> &str {
        "Show caveman + ponytail mode status"
    }
    fn usage(&self) -> &str {
        "/modes"
    }
    fn run(&self, _ctx: &mut CommandExecCtx, _args: &str) -> CommandResult {
        let state = load_modes();
        CommandResult::Message(format!(
            "## Logan modes\n\n\
             | Mode | Level | Skill |\n\
             | --- | --- | --- |\n\
             | caveman | `{}` | talk less (tokens) |\n\
             | ponytail | `{}` | build less (YAGNI) |\n\n\
             Toggle: `/caveman …` · `/ponytail …`\n\
             Profile: `/whoami` · Learn log: `/improve`\n\
             State: `{}`\n\
             Rules mirror: `{}`\n",
            state.caveman.as_str(),
            state.ponytail.as_str(),
            modes_path().display(),
            rules_path().display(),
        ))
    }
}

// ── /whoami ───────────────────────────────────────────────────────────────

pub struct WhoamiCommand;

impl SlashCommand for WhoamiCommand {
    fn name(&self) -> &str {
        "whoami"
    }
    fn aliases(&self) -> &[&str] {
        &["profile", "identity"]
    }
    fn description(&self) -> &str {
        "Show / update your identity profile (socials, stack, taste)"
    }
    fn usage(&self) -> &str {
        "/whoami [grill|update <note>|show]"
    }
    fn takes_args(&self) -> bool {
        true
    }
    fn session_scoped(&self) -> bool {
        true
    }
    fn arg_placeholder(&self) -> Option<&str> {
        Some("[grill|update <note>|show]")
    }
    fn suggest_args(&self, _ctx: &AppCtx, _q: &str) -> Option<Vec<ArgItem>> {
        Some(vec![
            ArgItem {
                display: "show".into(),
                match_text: "show".into(),
                insert_text: "show".into(),
                description: "Show PROFILE.md + preferences".into(),
            },
            ArgItem {
                display: "grill".into(),
                match_text: "grill".into(),
                insert_text: "grill".into(),
                description: "Interview for identity + stack".into(),
            },
            ArgItem {
                display: "update".into(),
                match_text: "update".into(),
                insert_text: "update ".into(),
                description: "Append a fact to PROFILE".into(),
            },
        ])
    }
    fn run(&self, _ctx: &mut CommandExecCtx, args: &str) -> CommandResult {
        let mem = memory_dir();
        let _ = std::fs::create_dir_all(&mem);
        let profile = mem.join("PROFILE.md");
        let memory = mem.join("MEMORY.md");
        let trimmed = args.trim();

        if trimmed.is_empty() || trimmed.eq_ignore_ascii_case("show") {
            let p = read_file_capped(&profile, 6000);
            let m = read_file_capped(&memory, 4000);
            return CommandResult::Message(format!(
                "## Whoami\n\n### PROFILE.md\n```markdown\n{p}\n```\n\n\
                 ### MEMORY.md (head)\n```markdown\n{m}\n```\n\n\
                 Update: `/whoami grill` · `/whoami update I prefer Next.js` · `/remember …`\n\
                 Paths: `{}` · `{}`",
                profile.display(),
                memory.display()
            ));
        }

        if let Some(rest) = trimmed
            .strip_prefix("update ")
            .or_else(|| trimmed.strip_prefix("update\t"))
        {
            let note = rest.trim();
            if note.is_empty() {
                return CommandResult::Error("Usage: /whoami update <fact>".into());
            }
            let ts = chrono_lite_now();
            let block = format!("\n- ({ts}) {note}\n");
            if !profile.exists() {
                let seed = format!(
                    "# PROFILE\n\n## Identity\n\n## Links\n\n## Tech stack defaults\n\n## Taste\n\n## Ongoing notes\n"
                );
                if let Err(e) = std::fs::write(&profile, seed) {
                    return CommandResult::Error(e.to_string());
                }
            }
            if let Err(e) = append_file(&profile, &block) {
                return CommandResult::Error(e.to_string());
            }
            return CommandResult::Message(format!(
                "Saved to PROFILE.md:\n- {note}\n\nShow: `/whoami`"
            ));
        }

        if trimmed.eq_ignore_ascii_case("grill") {
            // Send a structured prompt so the model runs the whoami skill interview.
            return CommandResult::PassThrough(
                "Run the Logan **whoami** skill interview now (skill: whoami / PROFILE.md). \
                 Grill me in clusters (identity → social links → tech stack defaults including HyperFrames → taste). \
                 One cluster at a time. After each cluster, propose the markdown you will save and ask me to confirm. \
                 Persist to ~/.logan/memory/PROFILE.md and summarize into MEMORY.md ## Preferences. \
                 If PROFILE already has content, show it first and only ask what is missing or outdated."
                    .into(),
            );
        }

        CommandResult::Error(format!(
            "Unknown whoami arg `{trimmed}`. Use: show | grill | update <note>"
        ))
    }
}

// ── /improve ──────────────────────────────────────────────────────────────

pub struct ImproveCommand;

impl SlashCommand for ImproveCommand {
    fn name(&self) -> &str {
        "improve"
    }
    fn aliases(&self) -> &[&str] {
        &["heal", "reflections", "lessons"]
    }
    fn description(&self) -> &str {
        "Self-heal / self-improve visibility - what changed and why"
    }
    fn usage(&self) -> &str {
        "/improve [why|log|open]"
    }
    fn takes_args(&self) -> bool {
        true
    }
    fn session_scoped(&self) -> bool {
        true
    }
    fn arg_placeholder(&self) -> Option<&str> {
        Some("[why|log|open]")
    }
    fn suggest_args(&self, _ctx: &AppCtx, _q: &str) -> Option<Vec<ArgItem>> {
        Some(vec![
            ArgItem {
                display: "why".into(),
                match_text: "why".into(),
                insert_text: "why".into(),
                description: "Explain last decision path".into(),
            },
            ArgItem {
                display: "log".into(),
                match_text: "log".into(),
                insert_text: "log".into(),
                description: "Show reflections + IMPROVEMENTS".into(),
            },
            ArgItem {
                display: "open".into(),
                match_text: "open".into(),
                insert_text: "open".into(),
                description: "Dashboard + next improve actions".into(),
            },
        ])
    }
    fn run(&self, _ctx: &mut CommandExecCtx, args: &str) -> CommandResult {
        let mem = memory_dir();
        let reflections = mem.join("reflections.log");
        let improvements = mem.join("IMPROVEMENTS.md");
        let memory = mem.join("MEMORY.md");
        let modes = load_modes();
        let trimmed = args.trim();

        if trimmed.eq_ignore_ascii_case("why") {
            return CommandResult::PassThrough(
                "Using the **self-improve** skill: explain your last non-trivial decision in this session. \
                 Structure: (1) goal/constraint (2) options considered (3) evidence (4) choice + risk \
                 (5) what would change the decision. Cite files/errors/memory if any. \
                 If nothing non-trivial yet, say so and summarize current plan."
                    .into(),
            );
        }

        if trimmed.eq_ignore_ascii_case("log")
            || trimmed.eq_ignore_ascii_case("reflections")
            || trimmed.is_empty()
            || trimmed.eq_ignore_ascii_case("open")
        {
            let rlog = read_file_capped(&reflections, 3500);
            let impr = read_file_capped(&improvements, 5000);
            let mem_tail = read_file_capped(&memory, 3000);
            return CommandResult::Message(format!(
                "## Improve / heal dashboard\n\n\
                 **Modes:** caveman=`{}` ponytail=`{}`\n\n\
                 ### reflections.log (tail)\n```\n{rlog}\n```\n\n\
                 ### IMPROVEMENTS.md\n```markdown\n{impr}\n```\n\n\
                 ### MEMORY.md (tail)\n```markdown\n{mem_tail}\n```\n\n\
                 Steer: `/improve why` · ask me to journal a lesson · `/whoami` · `/flush`\n\
                 Files: `{}` · `{}`",
                modes.caveman.as_str(),
                modes.ponytail.as_str(),
                reflections.display(),
                improvements.display(),
            ));
        }

        CommandResult::Error(format!(
            "Unknown improve arg `{trimmed}`. Use: (none)|log|why|open"
        ))
    }
}

fn append_file(path: &Path, block: &str) -> std::io::Result<()> {
    use std::io::Write;
    let mut f = std::fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open(path)?;
    f.write_all(block.as_bytes())
}

fn chrono_lite_now() -> String {
    // Avoid extra deps: local ISO-ish via SystemTime.
    use std::time::{SystemTime, UNIX_EPOCH};
    let secs = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0);
    format!("unix:{secs}")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn intensity_parse() {
        assert_eq!(Intensity::parse("ultra"), Some(Intensity::Ultra));
        assert_eq!(Intensity::parse("OFF"), Some(Intensity::Off));
        assert_eq!(Intensity::parse("nope"), None);
    }

    #[test]
    #[serial_test::serial]
    fn save_load_roundtrip() {
        let dir = tempfile::tempdir().unwrap();
        // SAFETY: serial test + unique LOGAN_HOME.
        unsafe {
            std::env::set_var("LOGAN_HOME", dir.path());
        }
        let mut s = ModesState::default();
        s.caveman = Intensity::Full;
        s.ponytail = Intensity::Lite;
        save_modes(&s).unwrap();
        let loaded = load_modes();
        assert_eq!(loaded.caveman, Intensity::Full);
        assert_eq!(loaded.ponytail, Intensity::Lite);
        assert!(rules_path().exists());
        unsafe {
            std::env::remove_var("LOGAN_HOME");
        }
    }
}
